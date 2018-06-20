#lang racket/base

;;
;; Support for the Amazon Open Source Ion data language.
;; See: https://amzn.github.io/ion-docs/
;; Based on the core Racket json module. Released under MIT license.
;;
;; Author: Simon Johnston

;; -----------------------------------------------------------------------------
;; DEPENDENCIES

;; racket/contract must come before provide
(require syntax/readerr
         racket/contract)

;; -----------------------------------------------------------------------------
;; SERVICES

(provide
  ;; Parameter
  ion-null ;; Parameter

  ;; Any -> Boolean
  ionexpr?

  (contract-out
    [write-ion
      (->* (any/c) ;; ionexpr? but dependent on #:null arg
           (output-port? ;; (current-output-port)
           #:null any/c ;; (ion-null)
           #:encode (or/c 'control 'all)) ;; -> 'control
        any)]
    [read-ion
      (->* (input-port?)
           (#:null any/c) ;; (ion-null)
           any)] ;; -> ionexpr?
    [ionexpr->string
      (->* (any/c) ;; ionexpr? but dependent on #:null arg
           (#:null any/c ;; (ion-null)
           #:encode (or/c 'control 'all)) ;; 'control
           any)] ;; -> string?
    [ionexpr->bytes
      (->* (any/c) ;; ionexpr? but dependent on #:null arg
           (#:null any/c ;; (ion-null)
           #:encode (or/c 'control 'all)) ;; 'control
           any)] ;; -> bytes?
    [string->ionexpr
      (->* (string?)
           (#:null any/c) ;; (ion-null)
           any)] ;; -> ionexpr?
    [bytes->ionexpr
      (->* (bytes?)
           (#:null any/c) ;; (ion-null)
           any)] ;; -> ionexpr?
  ))

;; -----------------------------------------------------------------------------
;; CUSTOMIZATION

;; The default translation for a Ion `null' value
(define ion-null (make-parameter 'null))

;; -----------------------------------------------------------------------------
;; PREDICATE

(define (ionexpr? x #:null [jsnull (ion-null)])
  (let loop ([x x])
    (or (exact-integer? x)
        (inexact-rational? x)
        (boolean? x)
        (string? x)
        (eq? x jsnull)
        (and (list? x) (andmap loop x))
        (and (hash? x) (for/and ([(k v) (in-hash x)])
                         (and (symbol? k) (loop v)))))))

(define (inexact-rational? x) ; not nan or inf
  (and (inexact-real? x) (rational? x)))

;; -----------------------------------------------------------------------------
;; GENERATION  (from Racket to Ion)

(define (write-ion x [o (current-output-port)]
                    #:null [jsnull (ion-null)] #:encode [enc 'control])
  (write-ion* 'write-ion x o jsnull enc))

(define (write-ion* who x o jsnull enc)
  (define (escape m)
    (define ch (string-ref m 0))
    (case ch
      [(#\backspace) "\\b"]
      [(#\newline) "\\n"]
      [(#\return) "\\r"]
      [(#\page) "\\f"]
      [(#\tab) "\\t"]
      [(#\\) "\\\\"]
      [(#\") "\\\""]
      [else
       (define (u-esc n)
         (define str (number->string n 16))
         (define pad (case (string-length str)
                       [(1) "000"] [(2) "00"] [(3) "0"] [else ""]))
         (string-append "\\u" pad str))
       (define n
         (char->integer ch))
       (if (n . < . #x10000)
           (u-esc n)
           ;; use the (utf-16 surrogate pair) double \u-encoding
           (let ([n (- n #x10000)])
             (string-append (u-esc (+ #xD800 (arithmetic-shift n -10)))
                            (u-esc (+ #xDC00 (bitwise-and n #x3FF))))))]))
  (define rx-to-encode
    (case enc
      ;; FIXME: This should also encode (always) anything that is represented
      ;; with a \U in Racket (since the Ion thing should be two \u sequences,
      ;; so there should never be a \U in the output of this function); but I
      ;; don't know if there's a known specification to what gets a \U
      [(control) #rx"[\0-\37\\\"\177]"]
      [(all)     #rx"[\0-\37\\\"\177-\U10FFFF]"]
      [else (raise-type-error who "encoding symbol" enc)]))
  (define (write-ion-string str)
    (write-bytes #"\"" o)
    (write-string (regexp-replace* rx-to-encode str escape) o)
    (write-bytes #"\"" o))
  (let loop ([x x])
    (cond [(or (exact-integer? x) (inexact-rational? x)) (write x o)]
          [(eq? x #f)     (write-bytes #"false" o)]
          [(eq? x #t)     (write-bytes #"true" o)]
          [(eq? x jsnull) (write-bytes #"null" o)]
          [(string? x) (write-ion-string x)]
          [(list? x)
           (write-bytes #"[" o)
           (when (pair? x)
             (loop (car x))
             (for ([x (in-list (cdr x))]) (write-bytes #"," o) (loop x)))
           (write-bytes #"]" o)]
          [(hash? x)
           (write-bytes #"{" o)
           (define first? #t)
           (for ([(k v) (in-hash x)])
             (unless (symbol? k)
               (raise-type-error who "legal ion key value" k))
             (if first? (set! first? #f) (write-bytes #"," o))
             ;; use a string encoding so we get the same deal with
             ;; `rx-to-encode'
             (write-ion-string (symbol->string k))
             (write-bytes #":" o)
             (loop v))
           (write-bytes #"}" o)]
          [else (raise-type-error who "legal ion value" x)]))
  (void))

;; -----------------------------------------------------------------------------
;; PARSING (from Ion to Racket)

(define (read-ion [i (current-input-port)] #:null [jsnull (ion-null)])
  (read-ion* 'read-ion i jsnull))

(define (read-ion* who i jsnull)
  ;; Follows the specification.
  ;;
  (define (err fmt . args)
    (define-values [l c p] (port-next-location i))
    (raise-read-error (format "~a: ~a" who (apply format fmt args))
                      (object-name i) l c p #f))
  (define (skip-whitespace) (regexp-match? #px#"^\\s*" i))
  ;;
  ;; Reading a string *could* have been nearly trivial using the racket
  ;; reader, except that it won't handle a "\/"...
  (define (read-string)
    (define result (open-output-bytes))
    (let loop ()
      (define esc
        (let loop ()
          (define c (read-byte i))
          (cond
            [(eof-object? c) (err "unterminated string")]
            [(= c 34) #f]               ;; 34 = "
            [(= c 92) (read-bytes 1 i)] ;; 92 = \
            [else (write-byte c result) (loop)])))
      (cond
        [(not esc) (bytes->string/utf-8 (get-output-bytes result))]
        [(case esc
           [(#"b") #"\b"]
           [(#"n") #"\n"]
           [(#"r") #"\r"]
           [(#"f") #"\f"]
           [(#"t") #"\t"]
           [(#"\\") #"\\"]
           [(#"\"") #"\""]
           [(#"/") #"/"]
           [else #f])
         => (λ (m) (write-bytes m result) (loop))]
        [(equal? esc #"u")
         (let* ([e (or (regexp-try-match #px#"^[a-fA-F0-9]{4}" i)
                       (err "bad string \\u escape"))]
                [e (string->number (bytes->string/utf-8 (car e)) 16)])
           (define e*
             (if (<= #xD800 e #xDFFF)
                 ;; it's the first part of a UTF-16 surrogate pair
                 (let* ([e2 (or (regexp-try-match #px#"^\\\\u([a-fA-F0-9]{4})" i)
                                (err "bad string \\u escape, ~a"
                                     "missing second half of a UTF16 pair"))]
                        [e2 (string->number (bytes->string/utf-8 (cadr e2)) 16)])
                   (if (<= #xDC00 e2 #xDFFF)
                       (+ (arithmetic-shift (- e #xD800) 10) (- e2 #xDC00) #x10000)
                       (err "bad string \\u escape, ~a"
                            "bad second half of a UTF16 pair")))
                 e)) ; single \u escape
           (write-string (string (integer->char e*)) result)
           (loop))]
        [else (err "bad string escape: \"~a\"" esc)])))
  ;;
  (define (read-list what end-rx read-one)
    (skip-whitespace)
    (if (regexp-try-match end-rx i)
        '()
        (let loop ([l (list (read-one))])
          (skip-whitespace)
          (cond [(regexp-try-match end-rx i) (reverse l)]
                [(regexp-try-match #rx#"^," i) (loop (cons (read-one) l))]
                [else (err "error while parsing a ion ~a" what)]))))
  ;;
  (define (read-hash)
    (define (read-pair)
      (define k (read-ion))
      (unless (string? k) (err "non-string value used for ion object key"))
      (skip-whitespace)
      (unless (regexp-try-match #rx#"^:" i)
        (err "error while parsing a ion object pair"))
      (list (string->symbol k) (read-ion)))
    (apply hasheq (apply append (read-list 'object #rx#"^}" read-pair))))
  ;;
  (define (read-ion [top? #f])
    (skip-whitespace)
    (cond
      [(and top? (eof-object? (peek-char i))) eof]
      [(regexp-try-match #px#"^true\\b"  i) #t]
      [(regexp-try-match #px#"^false\\b" i) #f]
      [(regexp-try-match #px#"^null\\b"  i) jsnull]
      [(regexp-try-match
        #rx#"^-?(?:0|[1-9][0-9]*)(?:\\.[0-9]+)?(?:[eE][+-]?[0-9]+)?" i)
       => (λ (bs) (string->number (bytes->string/utf-8 (car bs))))]
      [(regexp-try-match #rx#"^[\"[{]" i)
       => (λ (m)
            (let ([m (car m)])
              (cond [(equal? m #"\"") (read-string)]
                    [(equal? m #"[")  (read-list 'array #rx#"^\\]" read-ion)]
                    [(equal? m #"{")  (read-hash)])))]
      [else (err "bad input")]))
  ;;
  (read-ion #t))

;; -----------------------------------------------------------------------------
;; CONVENIENCE FUNCTIONS

(define (ionexpr->string x #:null [jsnull (ion-null)] #:encode [enc 'control])
  (define o (open-output-string))
  (write-ion* 'ionexpr->string x o jsnull enc)
  (get-output-string o))

(define (ionexpr->bytes x #:null [jsnull (ion-null)] #:encode [enc 'control])
  (define o (open-output-bytes))
  (write-ion* 'ionexpr->bytes x o jsnull enc)
  (get-output-bytes o))

(define (string->ionexpr str #:null [jsnull (ion-null)])
  ;; str is protected by contract
  (read-ion* 'string->ionexpr (open-input-string str) jsnull))

(define (bytes->ionexpr bs #:null [jsnull (ion-null)])
  ;; bs is protected by contract
  (read-ion* 'bytes->ionexpr (open-input-bytes bs) jsnull))
