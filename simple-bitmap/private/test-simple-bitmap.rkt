;;
;; Test suite for module simple-bitmap.
;; ~ Simon Johnston 2018.
;;
(module test-simple-bitmap racket

  (require rackunit
           math/array
           "simple-bitmap.rkt")

  ;; ---------- Test Cases: make-bitmap

  (test-case
    "make-bitmap bad arguments"
    (check-exn exn:fail:contract?
      (λ () (make-bitmap 0 2)))
    (check-exn exn:fail:contract?
      (λ () (make-bitmap -1 2)))
    (check-exn exn:fail:contract?
      (λ () (make-bitmap 2 0)))
    (check-exn exn:fail:contract?
      (λ () (make-bitmap 2 -1))))

  (test-case
    "bitmap? values"
    (check-false (bitmap? 1))
    (check-false (bitmap? 'bitmap))
    (check-false (bitmap? (array #[#[0 0] #[0 0]])))
    (check-true (bitmap? (make-bitmap 2 2))))

  (test-case
    "bitmap-height"
    (check-exn exn:fail:contract?
      (λ () (bitmap-height void)))
    (check-eq? 2 (bitmap-height (make-bitmap 2 4))))

  (test-case
    "bitmap-width"
    (check-exn exn:fail:contract?
      (λ () (bitmap-width void)))
    (check-eq? 4 (bitmap-width (make-bitmap 2 4))))

  (test-case
    "pixel-ref"
    (check-exn exn:fail:contract?
      (λ () (pixel-ref void 0 0)))
    (check-exn exn:fail:contract?
      (λ () (pixel-ref (make-bitmap 2 4) -1 0)))
    (check-exn exn:fail:contract?
      (λ () (pixel-ref (make-bitmap 2 4) 0 3)))
    (check-exn exn:fail:contract?
      (λ () (pixel-ref (make-bitmap 2 4) -1 0)))
    (check-exn exn:fail:contract?
      (λ () (pixel-ref (make-bitmap 2 4) 5 0)))
    (check-eq? 0 (pixel-ref (make-bitmap 2 4) 0 0)))

  (test-case
    "pixel-set!"
    (check-exn exn:fail:contract?
      (λ () (pixel-set! void 0 0 1)))
    (check-exn exn:fail:contract?
      (λ () (pixel-set! (make-bitmap 2 4) -1 0 1)))
    (check-exn exn:fail:contract?
      (λ () (pixel-set! (make-bitmap 2 4) 0 3 1)))
    (check-exn exn:fail:contract?
      (λ () (pixel-set! (make-bitmap 2 4) -1 0 1)))
    (check-exn exn:fail:contract?
      (λ () (pixel-set! (make-bitmap 2 4) 5 0 1)))
    (check-exn exn:fail:contract?
      (λ () (pixel-set! (make-bitmap 2 4) 5 0 "color")))
    (check-eq? 9 (let ([bm (make-bitmap 2 4)])
                       (pixel-set! bm 1 1 9)
                       (pixel-ref bm 1 1))))

  (test-case
    "bitmap-fill!"
    (check-exn exn:fail:contract?
      (λ () (bitmap-fill! (make-bitmap 2 4) 1 1 "color")))
    (let ([bm (make-bitmap 7 7)])
      (for ([row (range 4)])
           (for ([col (range 4)])
                (pixel-set! bm row col 1)))
      (bitmap-fill! bm 2 2 9)
      (for ([row (range 4)])
           (for ([col (range 4)])
                (check-eq? 9 (pixel-ref bm row col))))))

  ;; ---------- Internal procedures

)
