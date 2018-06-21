#lang racket
;;
;; A simple structure for managing data sets.
;;
;; Feature transformation details:
;;   http://www.scholarpedia.org/article/K-nearest_neighbor
;;
;; ~ Simon Johnston 2018.
;;

(provide
  (contract-out

    [load-data-set
      (-> string? symbol? string? data-set/c)]

    [data-set/c
      (-> any/c boolean?)]

    [features
      (-> data-set/c vector?)]

    [classifiers
      (-> data-set/c vector?)]

    [partition-equally
      (-> data-set/c exact-positive-integer? (listof string?))]

    [partition-for-test
      (-> data-set/c (real-in 0.0 99.0) (listof string?))]

    [standardize
      (-> data-set/c (non-empty-listof string?) data-set/c)]

    [fuzzify
      (-> data-set/c (non-empty-listof string?) data-set/c)]))


;; ---------- Requirements

(require "notimplemented.rkt")

;; ---------- Implementation

(define (load-data-set name format row-name)
  (cond
    [(eq? format 'json) (load-json-data name row-name)]
    [else (raise-argument-error 'load-data-set "'json" 1 name format row-name)]
    ))

(define (data-set/c a)
  (data-set? a))

(define (features ds)
  (data-set-features ds))

(define (classifiers ds)
  (data-set-classifiers ds))

;; ---------- Implementation (Partitioning)

(define (partition-equally ds k [entropy-classifiers (list)])
  (raise-not-implemented ))

(define (partition-for-test ds pc [entropy-classifiers (list)])
  (raise-not-implemented))

;; ---------- Implementation (Feature Transformation)

  (define (standardize data-set features)
    ; z_{ij} = x_{ij}-μ_j / σ_j
    (raise-not-implemented))

  (define (fuzzify data-set features)
    (raise-not-implemented))

;; ---------- Internal types

(struct data-set (
  features
  classifiers
  statistics
  data-partitions))

;; ---------- Internal procedures

(define (load-json-data file-name row-name)
  (raise-not-implemented))
