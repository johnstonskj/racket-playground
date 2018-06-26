#lang racket
;;
;; Some simple statistical functions over sequences. Thinking about performance.
;; see https://docs.racket-lang.org/math/stats.html
;; and file:///Applications/Racket%20v6.12/doc/reference/flonums.html
;; and https://docs.racket-lang.org/guide/parallelism.html
;; ~ Simon Johnston 2018.
;;

(provide
  (contract-out
    ; Create a statistics structure over a sequence of numbers
    [statistics (-> sequence? stats?)]
    ;
    [mean (-> stats? real?)]
    [median (-> stats? real?)]
    [variance (-> stats? real?)]
    [standard-deviation (-> stats? real?)])
  μ
  Var
  σ)

;; ---------- Requirements

(require data/heap)

;; ---------- Implementation

(define (statistics vs)
  (for/fold ([st (init-stats)])
            ([v vs])
            (compute v st)))

(define (mean st)
  (stats-m st))

(define μ mean)

(define (variance st)
  ;;  https://en.wikipedia.org/wiki/Algorithms_for_calculating_variance
  (if (> (stats-n st) 1)
      (/ (stats-s st) (- (stats-n st) 1))
      0.0))

(define Var variance)

(define (standard-deviation st)
  ;;  https://www.johndcook.com/blog/standard_deviation/
  (sqrt (variance st)))

(define σ standard-deviation)

(define (median st)
  ;;  https://en.wikipedia.org/wiki/Median
  (if (even? (stats-n st))
      (/ (+ (- (heap-min (stats-hmax st))) (heap-min (stats-hmin st))) 2.0)
      (- (heap-min (stats-hmax st)))))

;; ---------- Internal types

(struct stats (
  n    ; number of values
  m    ; calculated mean
  s    ; calculated for variance
  hmin ; min heap (median)
  hmax ; max heap (median)
  ))

;; ---------- Internal procedures

(define (init-stats)
  (stats 0 0.0 0.0 (make-heap <=) (make-heap <=)))

(define/contract (compute v st)
  (-> number? stats? stats?)
  (update-heaps v st)
  (let ([n (+ (stats-n st) 1)])
       (if (eq? n 1)
           (stats n v 0.0 (stats-hmin st) (stats-hmax st))
           (let* ([v-m (- v (stats-m st))]
                  [m (+ (stats-m st) (/ v-m n))]
                  [s (+ (stats-s st) (* v-m (- v m)))])
             (stats n m s (stats-hmin st) (stats-hmax st))))))

(define (update-heaps v st)
  (heap-add! (stats-hmax st) (- v))
  (if (even? (stats-n st))
      (when (not (eq? (heap-count (stats-hmin st)) 0))
        (when (> (heap-min (stats-hmax st)) (heap-min (stats-hmin st)))
          (let ([lmin (- (heap-pop! (stats-hmax st)))]
                [lmax (heap-pop! (stats-hmin st))])
               (heap-add! (stats-hmax st) (- lmax))
               (heap-add! (stats-hmin st) lmin))))
      (let ([lmin (- (heap-pop! (stats-hmax st)))])
           (heap-add! (stats-hmin st) lmin)))
  st)

(define (heap-pop! h)
  (let ([min (heap-min h)])
       (heap-remove-min! h)
       min))

;; Skewness
;;  https://en.wikipedia.org/wiki/Skewness
;;  https://www.johndcook.com/blog/skewness_kurtosis/
;; Regression
;;  https://www.johndcook.com/blog/running_regression/
;; Kurtosis
;;  https://en.wikipedia.org/wiki/Kurtosis
