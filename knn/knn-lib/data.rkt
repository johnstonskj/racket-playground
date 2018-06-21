#lang racket

(provide
  load-data-set
  features
  classifiers
  partition-equally
  partition-for-test)

;; ---------- Requirements

(require "notimplemented.rkt")

;; ---------- Implementation

(define (load-data-set name format row-name)
  (data-set #f #f #f #f))

(define (features ds)
  (data-set-features ds))

(define (classifiers ds)
  (data-set-classifiers ds))

(define (partition-equally ds k [entropy-classifiers (list)])
  (raise-not-implemented ))

(define (partition-for-test ds pc [entropy-classifiers (list)])
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
