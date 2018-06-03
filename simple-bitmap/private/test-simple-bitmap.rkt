;;
;; Test suite for module simple-bitmap.
;; ~ Simon Johnston 2018.
;;
(module test-simple-bitmap racket

  (require rackunit
           math/array
           ; Package under test
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
    "make-bitmap success"
    (let ([bm (make-bitmap 2 4)])
         (check-true (and (mutable-array? bm) (= (array-dims bm) 2)))
         (check-eq? 2 (vector-ref (array-shape bm) 0))
         (check-eq? 4 (vector-ref (array-shape bm) 1))))

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
      ; create a walled-off corner
      (for ([row (range 4)])
           (pixel-set! bm row 3 1))
      (for ([col (range 4)])
           (pixel-set! bm 3 col 1))
      ; flood-fill within the corner
      (bitmap-fill! bm 2 2 9)
      ; ensure all the correct pixels are now set
      (for ([row (range 3)])
           (for ([col (range 3)])
                (check-eq? 9 (pixel-ref bm row col))))
      (check-eq? 1 (pixel-ref bm 2 3))
      (check-eq? 0 (pixel-ref bm 2 4))))

)
