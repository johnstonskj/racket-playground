#lang racket

(require racket/random math/statistics)

;; ------------------------------------------------------------

(define/contract
  (euclidean-distance point-a point-b)
  (->i ([x (or/c (listof number?) (vectorof number?))]
        [y (or/c (listof number?) (vectorof number?))])
       #:pre/name (x y) "point's have different number of values"
       (and
        (equal? (list? x) (list? y))
        (if (list? x)
            (equal? (length x) (length y))
            (equal? (vector-length x) (vector-length))))
       [d number?])
  (sqrt
   (for/sum ([a point-a][b point-b])
     (expt (- a b) 2))))

;; ------------------------------------------------------------

(define (random-data count #:weights [w '(1)])
  (for/list ([i (range 100)]) (* (random 1 100) (random-ref w))))

(define (sample-data-range values (σl 1) (σh 1))
  (let* ([m (mean values)]
         [σ (stddev values)]
         [l (- m (* σ σl))]
         [h (+ m (* σ σh))])
    (cons l h)))

(define (sample-data values (σl 1) (σh 1))
  (let ([low-high (sample-data-range values σl σh)])
    (filter (λ (v) (and (> v (car low-high)) (< v (cdr low-high)))) values)))

;; ------------------------------------------------------------
;; ------------------------------------------------------------

(define values (random-data 100 #:weights '(1 1 5 5 25 25 50 50 50 50)))

(displayln (format "  min: ~a" (apply min values)))
(displayln (format "  max: ~a" (apply max values)))
(displayln (format " mean: ~a" (exact->inexact (mean values))))
(displayln (format "  var: ~a" (exact->inexact (variance values))))
(displayln (format "    σ: ~a" (exact->inexact (stddev values))))
(displayln (format " skew: ~a" (exact->inexact (skewness values))))
(displayln (format " kurt: ~a" (exact->inexact (kurtosis values))))
;                    ^^^^  actually this is the excess kurtosis.

(define sample (sample-data values (- 3 (kurtosis values)) (kurtosis values)))

(displayln (format "sample range: ~a..~a" (apply min sample) (apply max sample)))
(displayln (format " sample size: ~a/~a" (length sample) (length values)))
