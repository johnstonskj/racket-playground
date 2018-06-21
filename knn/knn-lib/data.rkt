#lang racket

(struct data-set (
  features
  classifiers
  statistics
  partitioned-data))

(struct feature-stat (
  min
  max
  count
  total))

(define (load-data-set name format row-name)
  (data-set #f #f #f #f))

(define (load-json-data file-name row-name)
  'null)

(define (features ds)
  (data-set-features ds))

(define (classifiers ds)
  (data-set-classifiers ds))

(define (partition-equally ds k entropy-features)
  'null)

(define (partition-for-test ds pc entropy-features)
  'null)
