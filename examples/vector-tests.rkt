#lang racket
(define test-vec (make-vector 135 9))
(displayln test-vec)

(define (vector-split-list v nth rem)
  (displayln (format ". ~a -> ~a,~a" (vector-length v) nth rem))
  (if (> (vector-length v) 0)
    (let ([at (if (> rem 0) (add1 nth) nth)])
      (let-values ([(head rest) (vector-split-at v at)])
        (cons head (vector-split-list rest nth (sub1 rem)))))
    '()))

;(displayln (vector-split-list test-vec 3 0))

;(displayln (vector-split-list test-vec 4 1))

(define (vector-split-equal v n)
  (let ([nth (exact-floor (/ (vector-length v) n))]
        [rem (remainder (vector-length v) n)])
    (displayln (format "~a -> ~a,~a" n nth rem))
    (vector-split-list v nth rem)))

(displayln (vector-split-equal test-vec 3))

(displayln (vector-split-equal test-vec 4))
