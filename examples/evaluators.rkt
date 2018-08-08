#lang racket

(require racket/sandbox)

(module helpers racket/base
  (define (hello me) (displayln me)))

(define (salute who) (format "Hello ~a" who))

(define (read-file) (open-input-file "/Users/simonjo/.zshrc"))

(define (take-time) (sleep 10))

(define tree-evaluator
  (parameterize ([sandbox-output 'string]
                 [sandbox-propagate-exceptions #t]
                 [sandbox-eval-limits '(2.0 5)])
  (make-evaluator 'racket/base
                  '(displayln "started"))))
(displayln "*")

(tree-evaluator '(define (hello how who) (how who)))
(displayln "*")

(tree-evaluator `(hello ,salute "me"))
(displayln "*")

(tree-evaluator `(,read-file))

;(tree-evaluator `(,take-time))
;(displayln "*")

;(displayln (get-output tree-evaluator))
;(displayln "*")

