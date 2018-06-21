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
      (-> string? symbol? (non-empty-listof string?) (non-empty-listof string?) data-set/c)]

    [data-set/c
      (-> any/c boolean?)]

    [features
      (-> data-set/c (listof string?))]

    [classifiers
      (-> data-set/c (listof string?))]

    [partition-count
      (-> data-set/c exact-nonnegative-integer?)]

    [data-count
      (-> data-set/c exact-nonnegative-integer?)]

    [partition
      (-> data-set/c exact-nonnegative-integer? (vectorof vector?))]

    [feature-vector
      (-> data-set/c exact-nonnegative-integer? string? vector?)]

    [feature-statistics
      (-> data-set/c exact-nonnegative-integer? string? vector?)]

    [partition-equally
      (-> data-set/c exact-positive-integer? (listof string?))]

    [partition-for-test
      (-> data-set/c (real-in 1.0 50.0) (listof string?) data-set/c)]

    [standardize
      (-> data-set/c (non-empty-listof string?) data-set/c)]

    [fuzzify
      (-> data-set/c (non-empty-listof string?) data-set/c)]

    [write-snapshot
      (-> data-set/c output-port? void?)]

    [read-snapshot
      (-> input-port? data-set/c)]))

;; ---------- Requirements

(require "notimplemented.rkt" json)

;; ---------- Implementation

(define (load-data-set name format feature-names classifier-names)
  (let* ([feature-set (list->set feature-names)]
         [classifier-set (list->set classifier-names)]
         [all (set-union feature-set classifier-set)])
    (cond
      [(eq? format 'json) (load-json-data name all feature-names classifier-names)]
      [else (raise-argument-error 'load-data-set "'json" 1 name format feature-names classifier-names)]
      )))

(define (data-set/c a)
  (data-set? a))

(define (features ds)
  (data-set-features ds))

(define (classifiers ds)
  (data-set-classifiers ds))

(define (partition-count ds)
  (data-set-partition-count ds))

(define (data-count ds)
  (data-set-data-count ds))

(define (partition ds index)
  (data-set-partitions ds)) ; TODO: vector of vectors

(define (feature-vector ds partition feature-name)
  (when (>= partition (data-set-partition-count ds))
    (raise-argument-error 'feature-vector (format "< ~s" (data-set-partition-count ds)) 1 data-set partition feature-name))
  (when (not (hash-has-key? (data-set-name-index ds) feature-name))
    (raise-argument-error 'feature-vector (format "one of: ~s" (hash-keys (data-set-name-index ds))) 2 data-set partition feature-name))
  (let ([feature-index (hash-ref (data-set-name-index ds) feature-name)]
        [partition (data-set-partitions ds)])
    (vector-ref partition feature-index)))

(define (feature-statistics ds partition feature-name)
  (raise-not-implemented))

;; ---------- Implementation (Partitioning)

(define (partition-equally ds k [entropy-classifiers '()])
  (raise-not-implemented))

(define (partition-for-test ds test-percent [entropy-classifiers '()])
  (raise-not-implemented))

;; ---------- Implementation (Feature Transformation)

  (define (standardize data-set features)
    ; z_{ij} = x_{ij}-μ_j / σ_j
    (raise-not-implemented))

  (define (fuzzify data-set features)
    (raise-not-implemented))

;; ---------- Implementation (Snapshots)

(define (write-snapshot ds out)
  (write `(,(data-set-name-index ds)
           ,(data-set-features ds)
           ,(data-set-classifiers ds)
           ,(data-set-statistics ds)
           ,(data-set-data-count ds)
           ,(data-set-partition-count ds)
           ,(data-set-partitions ds))
          out))

(define (read-snapshot in)
  (let ([values (read in)])
    (apply data-set values)))

;; ---------- Internal types

(struct data-set (
  name-index
  features
  classifiers
  statistics
  data-count
  partition-count
  partitions))

;; ---------- Internal procedures

(define (load-json-data file-name all-names feature-names classifier-names)
  (let* ([file (open-input-file file-name)]
         [data (read-json file)]
         [rows (length data)]
         [all-names (set->list all-names)]
         [partition (make-vector (length all-names))])
        (for ([i (length all-names)])
          (vector-set! partition i (make-vector rows)))
        (for ([row rows])
          (let ([rowdata (list-ref data row)])
            (for ([i (length all-names)])
              (let ([feature (list-ref all-names i)]
                    [column (vector-ref partition i)])
                (vector-set! column row (hash-ref rowdata (string->symbol feature)))))))
        (data-set (make-hash (for/list ([i (length all-names)]) (cons (list-ref all-names i) i)))
                  feature-names
                  classifier-names
                  '() ; statistics.
                  rows
                  1 ; for now.
                  partition)))
