;;
;; This implements a simple, encapsulated, moustache-light parser.
;;
;; ~ Copyright (c) Simon Johnston 2018.
;;
(module pencil Racket

  (provide
    parse-file
    parse-port
    parse-string
    )

  ;; ---------- Requirements

 (require racket/generator)

  ;; ---------- Implementation

  (define (parse-file file-name)
    (parse-string (file->string file-name)))

  (define (parse-port port)
    (parse-string (port->string port)))

  (define (parse-string str)
    (let* ([tokens (tokenizer-init str)]
           [ps (parser-init tokens)])
          (display (format "parse: ~s" (parse ps)))))

  ;; ---------- Internal types

  (define EOF (gensym))

  (struct parser (
    tokens ; (symbol? string?)
    [tree #:mutable]))

  (struct tokenizer (
    str
    length
    [pos #:mutable]
    [line #:mutable]
    [char #:mutable]))


  ;; ---------- Internal procedures: parser

  (define (parser-init tokens)
    (parser (tokenize tokens) '(begin)))

  (define (parse ps)
    (let next-token ([token ((parser-tokens ps))])
      (unless (eq? (car token) 'eof)
        (set-parser-tree! ps (append (parser-tree ps) (list token)))
        (next-token ((parser-tokens ps)))))
    (parser-tree ps))

  ;; ---------- Internal procedures: tokenizer

  (define (tokenizer-init str [initial-pos 0])
    (tokenizer str (string-length str) initial-pos 0 0))

  (define (tokenize ts)
    (generator ()
      (let read-next ([state 'start] [start (tokenizer-pos ts)])
        (let ([c (next-char ts)]
              [str (tokenizer-str ts)]
              [pos (tokenizer-pos ts)])
         (cond
           [(eq? c EOF)
             (let ([final (list state (substring str start pos))])
               (set-tokenizer-pos! ts EOF)
               (yield final)
               (list 'eof))]

           [(and (eq? c #\{) (not (eq? state 'mayberef)) (not (eq? state 'ref)))
             (read-next 'mayberef (token-reset ts start state))]
           [(and (eq? c #\{) (eq? state 'mayberef))
             (read-next 'ref start)]
           [(and (eq? c #\{) (eq? state 'ref))
             (read-next 'doubleref start)]
           [(and (eq? c #\{) (eq? state 'doubleref))
             (read-next 'tripleref start)]

           [(and (eq? c #\#) (eq? state 'doubleref))
             (read-next 'escaped start)]
           [(and (eq? c #\!) (eq? state 'doubleref))
             (read-next 'comment start)]
           [(and (eq? c #\>) (eq? state 'doubleref))
             (read-next 'partial start)]

           [(and (eq? c #\#) (eq? state 'doubleref))
             (read-next 'section start)]
           [(and (eq? c #\^) (eq? state 'doubleref))
             (read-next 'invsection start)]

           [(and (eq? c #\}) (not (eq? state 'closemaybe)) (not (eq? state 'closeref)))
             (read-next 'closemaybe (token-reset ts start state))]
           [(and (eq? c #\}) (eq? state 'closemaybe))
             (read-next 'closeref start)]
           [(and (eq? c #\}) (eq? state 'closeref))
             (read-next 'closedouble start)]
           [(and (eq? c #\}) (eq? state 'closedouble))
             (read-next 'closetriple start)]

           [(and (eq? c #\/) (eq? state 'doubleref))
             (read-next 'closesection start)]

           [(and (or (char-alphabetic? c) (char-whitespace? c)) (eq? state 'text))
             (read-next state start)]
           [(or (char-alphabetic? c) (char-whitespace? c))
             (read-next 'text (token-reset ts start state))]

;           [(and (char-whitespace? c) (eq? state 'whitespace))
;             (read-next 'whitespace start)]
;           [(char-whitespace? c)
;             (read-next 'whitespace (token-reset ts start state))]
           [else (read-next state start)])))))

  (define (token-reset ts start state1)
    (push-back ts)
    (let ([ppos (tokenizer-pos ts)])
      (yield (list state1
                   (substring (tokenizer-str ts) start ppos)
                   (tokenizer-line ts)
                   start))
      ppos))

  ;; ---------- Internal procedures: reader

  (define (push-back ts [back-chars 1])
    (unless (eq? (tokenizer-pos ts) 0)
      ; TODO: reset line/char reference
      (set-tokenizer-pos! ts (max (- (tokenizer-pos ts) back-chars) 0))))

  (define (next-char ts)
    (if (>= (tokenizer-pos ts) (tokenizer-length ts))
        EOF
        (let ([c (string-ref (tokenizer-str ts) (tokenizer-pos ts))])
             ; TODO: set line/char reference
             (set-tokenizer-pos! ts (+ (tokenizer-pos ts) 1))
             (cond
               [(eq? c #\newline)
                (set-tokenizer-line! ts (+ (tokenizer-line ts) 1))
                (set-tokenizer-char! ts -1)]
               [(eq? c #\return)
                (set-tokenizer-char! ts -1)]
               [else
                (set-tokenizer-char! ts (+ (tokenizer-char ts) 1))])
             c)))

  (define (peek-ahead ts [ahead-chars 0])
    (if (>= (tokenizer-pos ts) (tokenizer-length ts))
        EOF
        (string-ref (tokenizer-str ts) (+ (tokenizer-pos ts) ahead-chars))))

  ;; ---------- Submodule: main

  (module+ main

;    (let* ([ts (tokenizer-init "hi   ")]
;           [eof? (lambda (v) (and (list? v) (symbol? (car v)) (eq? (car v) 'eof)))])
;      (for/list ([t (in-producer (tokenize ts) eof?)])
;        (displayln (format "token: ~s" t))))

    (parse-string "hi  {{#worlds}}\n{{world}}{{/worlds}} {{!a comment}} ")
  )
)
