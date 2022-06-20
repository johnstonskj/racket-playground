#lang racket

(require racket/unit
         "toy-sig.rkt"
         "toy-unit.rkt")

(define (maker color)
  (define-values/invoke-unit (simple-factory@-maker color)
    (import)
    (export toy-factory^))
  (void))

(build-toys 10)