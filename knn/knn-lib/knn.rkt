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
      (-> hash? data-set/c exact-positive-integer? list?)]

    [partition-and-classify
      (-> data-set/c (real-in 1.0 50.0) exact-positive-integer? list?)]

    [cross-train
      (-> data-set/c exact-positive-integer? array?)]))

;; ---------- Requirements

(require "data.rkt"
         "notimplemented.rkt"
         math/array)

;; ---------- Implementation

(define (classify data-item data-set k)
  (reduce
    (take
      (sort
        (for/list ([index (data-count data-set)])
          (classify-distance data-item data-set 0 index))
        #:key first <)
      k)))

(define (partition-and-classify data-set partition-pc k)
  (let* ([partitioned (partition-for-test data-set partition-pc)]
         [training (partition partitioned 0)]
         [testing (partition partitioned 1)])
    (raise-not-implemented)))

(define (cross-train partitioned-data-set k)
  (raise-not-implemented))

(define (make-confusion-matrix classifier-values)
  (let ([Ω (vector-length classifier-values)])
       (array->mutable-array (make-array Ω Ω 0))))

;; ---------- Internal procedures

(define (classify-distance sample data-set partition-index value-index)
  (list
    (sqrt
      (apply +
        (for/list ([feature (features data-set)])
          (let ([fvector (feature-vector data-set partition-index feature)])
            (expt (- (hash-ref sample feature) (vector-ref fvector value-index)) 2)))))
    value-index
    (for/list ([classifier (classifiers data-set)])
      (let ([cvector (feature-vector data-set partition-index classifier)])
        (vector-ref cvector value-index)))))

(define (reduce results)
  (second
    (first
      (sort
        (hash-map
          (foldl (lambda (e ht)
                 (hash-update ht (list-ref e 2) add1 (lambda () 0)))
                 (hash)
                 results)
          (lambda (k v) (list v k)))
      #:key first >))))

(define (record-result C true-ω predicted-ω)
  (array-set! C (vector true-ω predicted-ω) (+ (array-ref C true-ω predicted-ω) 1)))
