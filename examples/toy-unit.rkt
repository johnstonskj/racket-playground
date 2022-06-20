#lang racket

(require "toy-sig.rkt")

(define simple-factory@-maker
  (lambda (color)
    (unit
      (import)
      (export toy-factory^)
 
      (printf "Factory started.\n")
      
      (define-struct toy (color) #:transparent)
      
      (define (build-toys n)
        (for/list ([i (in-range n)])
          (make-toy color))))))
 
(provide simple-factory@-maker)