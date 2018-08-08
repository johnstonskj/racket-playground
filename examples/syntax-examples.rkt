#lang racket
(define-syntax (raise-me stx)
  (syntax-case stx ()
    [(_ caller)
     #'(raise-me caller #f)]
    [(_ caller message)
     (with-syntax ([src (syntax-source stx)]
                   [line (syntax-line stx)]
                   [column (syntax-column stx)])
       #'(raise (make-exn:fail:unsupported
                 (format "~a:~a:~a Procedure ~a not implemented.~a"
                         src line column
                         (cond
                           [(string? caller) caller]
                           [(symbol? caller) (symbol->string caller)]
                           [else "(unknown)"])
                         (if (string? message) (format " Also: ~a" message) ""))
                 (current-continuation-marks))))]))


;(raise-me 99)

(raise-me "hi" "oops")

(define (vtable value funcs)
  (if (hash-has-key? funcs value)
      ((hash-ref funcs value))
      (error "whoops")))

(define-syntax (decision stx)
  (syntax-case stx ()
    [(_ evaluator conditions ...)
     (cond
       [(string? (syntax->datum #'evaluator))
         #'(λ (individual)
             (vtable (hash-ref individual evaluator)
                     (make-hash (list (quote conditions) ...))))]
       [(and (identifier? #'evaluator) (list? (identifier-binding #'evaluator)))
         #'(λ (individual)
             (let ([value (evaluator individual)])
               (cond)))]
       [(identifier? #'evaluator)
         #'(λ (individual)
             (let ([value (hash-ref individual (symbol->string (quote evaluator)))])
               (cond)))]
       [else
        #'(displayln evaluator)])]))

(define d1 (decision "size"
                     [1 'small]
                     [2 'medium]))

(displayln (d1 (hash "size" 1)))
