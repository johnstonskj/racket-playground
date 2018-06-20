#lang racket

;; Import the parser and lexer generators.
(require parser-tools/yacc
         parser-tools/lex
         (prefix-in : parser-tools/lex-sre))

(define-tokens value-tokens
  (null
   bool
   int
   float
   decimal
   timestamp
   stringssymbol
   blob
   clob
   struct
   list
   sexp
   identifier
   comment))
(define-empty-tokens op-tokens
  (LB  ; {
   RB  ; }
   LBB ; {{
   RBB ; }}
   LSQ ; [
   RSQ ; ]
   LP  ; (
   RP  ; )
   COLON ; :
   ANNOT ; ::
   SCOM  ; //
   LCOM  ; /*
   RCOM  ; */
   ))

;; A hash table to store variable values in for the calculator
(define symbols (make-hash))

(define-lex-abbrevs
 (lower-letter (:/ "a" "z"))

 (upper-letter (:/ #\A #\Z))

 ;; (:/ 0 9) would not work because the lexer does not understand numbers.  (:/ #\0 #\9) is ok too.
 (digit (:/ "0" "9")))

(define textlexer
  (lexer
   [(eof) 'EOF]
   ;; recursively call the lexer on the remaining input after a tab or space.  Returning the
   ;; result of that operation.  This effectively skips all whitespace.
   [(:or #\tab #\space #\newline #\return) (textlexer input-port)]
   ["{{" 'LBB]
   ["}}" 'RBB]
   ["{" 'LB]
   ["}" 'RB]
   ["[" 'LSQ]
   ["]" 'RSQ]
   ["(" 'LP]
   [")" 'RP]
   ["::" 'COLON]
   [":" 'ANNOT]
   ["//" 'SCOM]
   ["/*" 'LCOM]
   ["*/" 'RCOM]
   ["sin" (token-FNCT sin)]
   [(:+ (:or lower-letter upper-letter)) (token-VAR (string->symbol lexeme))]
   [(:+ digit) (token-NUM (string->number lexeme))]
   [(:: (:+ digit) #\. (:* digit)) (token-NUM (string->number lexeme))]))


(define calcp
  (parser

   (start start)
   (end newline EOF)
   (tokens value-tokens op-tokens)
   (error (lambda (a b c) (void)))

   (precs (right =)
          (left - +)
          (left * /)
          (left NEG)
          (right ^))

   (grammar

    (start [() #f]
           ;; If there is an error, ignore everything before the error
           ;; and try to start over right after the error
           [(error start) $2]
           [(exp) $1])

    (exp [(NUM) $1]
         [(VAR) (hash-ref vars $1 (lambda () 0))]
         [(VAR = exp) (begin (hash-set! vars $1 $3)
                             $3)]
         [(FNCT OP exp CP) ($1 $3)]
         [(exp + exp) (+ $1 $3)]
         [(exp - exp) (- $1 $3)]
         [(exp * exp) (* $1 $3)]
         [(exp / exp) (/ $1 $3)]
         [(- exp) (prec NEG) (- $2)]
         [(exp ^ exp) (expt $1 $3)]
         [(OP exp CP) $2]))))

;; run the calculator on the given input-port
(define (calc ip)
  (port-count-lines! ip)
  (letrec ((one-line
	    (lambda ()
	      (let ((result (calcp (lambda () (calcl ip)))))
		(when result
                  (printf "~a\n" result)
                  (one-line))))))
    (one-line)))

(calc (open-input-string "x=1\n(x + 2 * 3) - (1+2)*3"))
