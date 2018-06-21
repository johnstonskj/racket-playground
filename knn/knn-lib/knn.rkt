#lang racket
;;
;; Based upon the article:
;;   https://spin.atomicobject.com/2013/05/06/k-nearest-neighbor-racket/
;;
;; Algorith details:
;;   http://www.scholarpedia.org/article/K-nearest_neighbor
;;
;; ~ Simon Johnston 2018.
;;


(provide
  (contract-out

    [classify
      (-> hash? data-set/c exact-positive-integer?)]

    [cross-train
      (-> data-set/c exact-positive-integer? mutable-array?)]

    [make-confusion-matrix
      (-> (non-empty-listof string?) mutable-array?)]))

;; ---------- Requirements

(require "data.rkt"
         "notimplemented.rkt"
         math/array)

;; ---------- Implementation

; returns ?
(define (classify data-item data-set k)
  (raise-not-implemented))

; returns confusion matrix
(define (cross-train partitioned-data-set k)
  (raise-not-implemented))

(define (make-confusion-matrix classifier-values)
  (let ([Ω (vector-length classifier-values)])
       (array->mutable-array (make-array Ω Ω 0))))

;; ---------- Internal procedures

(define (record-result C true-ω predicted-ω)
  (array-set! C (vector true-ω predicted-ω) (+ (array-ref C true-ω predicted-ω) 1)))
