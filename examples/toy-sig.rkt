#lang racket

(define-signature toy-factory^
  (build-toys
   toy?
   toy-color))

(provide toy-factory^)