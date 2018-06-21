#lang racket

(provide
  standardize
  fuzzify)

;; ---------- Requirements

(require "data.rkt" "notimplemented.rkt")

;; ---------- Implementation (Feature Transformation)

(define (standardize data-set features)
  ; z_{ij} = x_{ij}-μ_j / σ_j
  (raise-not-implemented))

(define (fuzzify data-set features)
  (raise-not-implemented))

;; ---------- Internal procedures
