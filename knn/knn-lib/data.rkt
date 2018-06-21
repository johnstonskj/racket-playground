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
      (->* (string? symbol?) ((listof string?) (listof string?)) data-set/c)]

    [data-set/c
      (-> any/c boolean?)]

    [features
      (-> data-set/c (listof symbol?))]

    [classifiers
      (-> data-set/c (listof symbol?))]

    [partition-count
      (-> data-set/c positive-integer?)]

    [partition-equally
      (-> data-set/c exact-positive-integer? (listof string?))]

    [partition-for-test
      (-> data-set/c (real-in 1.0 99.0) (listof string?))]

    [standardize
      (-> data-set/c (non-empty-listof string?) data-set/c)]

    [fuzzify
      (-> data-set/c (non-empty-listof string?) data-set/c)]))


;; ---------- Requirements

(require "notimplemented.rkt" json)

;; ---------- Implementation

(define (load-data-set name format [feature-names '()] [classifier-names '()])
  (cond
    [(eq? format 'json) (load-json-data name)]
    [else (raise-argument-error 'load-data-set "'json" 1 name format feature-names classifier-names)]
    ))

(define (data-set/c a)
  (data-set? a))

(define (features ds)
  (data-set-features ds))

(define (classifiers ds)
  (data-set-classifiers ds))

(define (partition-count ds)
  (data-set-partition-count ds))

;; ---------- Implementation (Partitioning)

(define (partition-equally ds k [entropy-classifiers (list)])
  (raise-not-implemented ))

(define (partition-for-test ds test-percent [entropy-classifiers (list)])
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
  partition-count
  partitions))

;; ---------- Internal procedures

(define (load-json-data file-name)
  (let* ([file (open-input-file file-name)]
         [data (read-json file)]
         [rows (length data)]
         [features (if (> rows 0)(hash-keys (list-ref data 0))(list))]
         [partition (make-vector (length features))])
        (for ([i (length features)])
          (vector-set! partition i (make-vector rows)))
        (for ([row rows])
          (let ([rowdata (list-ref data row)])
            (for ([i (length features)])
              (let ([feature (list-ref features i)]
                    [column (vector-ref partition i)])
                (vector-set! column row (hash-ref rowdata feature))))))
        (data-set features '() '() 1 partition)))
