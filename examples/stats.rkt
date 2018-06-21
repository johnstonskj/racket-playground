#lang racket
;;
;; Some simple statistical functions over sequences. Uses a nice streaming
;; approach that doesn't require large sums (and therefore unstable
;; numerical performance).
;;   See: https://www.johndcook.com/blog/standard_deviation/
;; ~ Simon Johnston 2018.
;;

(provide
  (contract-out
    ; Create a statistics structure over a sequence of numbers
    [statistics (-> sequence? stats?)]
    ;
    [mean (-> stats? real?)]
    [variance (-> stats? real?)]
    [standard-deviation (-> stats? real?)])
  μ
  Var
  σ)
;; ---------- Implementation

(define (statistics vs)
  (for/fold ([st (stats 0 0.0 0.0)])
            ([v vs])
            (compute v st)))

(define (mean st)
  (stats-m st))

(define μ mean)

(define (variance st)
  (if (> (stats-n st) 1)
      (/ (stats-s st) (- (stats-n st) 1))
      0.0))

(define Var variance)

(define (standard-deviation st)
  (sqrt (variance st)))

(define σ standard-deviation)

;; ---------- Internal types

(struct stats (n m s))

;; ---------- Internal procedures

(define/contract (compute v st)
  (-> number? stats? stats?)
  (let ([n (+ (stats-n st) 1)])
       (if (eq? n 1)
           (stats n v 0.0)
           (let* ([v-m (- v (stats-m st))]
                  [m (+ (stats-m st) (/ v-m n))]
                  [s (+ (stats-s st) (* v-m (- v m)))])
             (stats n m s)))))
