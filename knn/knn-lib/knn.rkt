#lang racket

; https://spin.atomicobject.com/2013/05/06/k-nearest-neighbor-racket/
; http://www.scholarpedia.org/article/K-nearest_neighbor

(require "data.rkt"
         math/array)

; returns ?
(define (classify data-item data-set k)
  'null)

; returns confusion matrix
(define (cross-train partitioned-data-set k)
  'null)

(define (make-confusion-matrix classifier-values)
  (let ([Ω (vector-length classifier-values)])
       (array->mutable-array (make-array Ω Ω 0))))

(define (record-result C true-ω predicted-ω)
  (array-set! C (vector true-ω predicted-ω) (+ (array-ref C true-ω predicted-ω) 1)))
