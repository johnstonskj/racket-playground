;;
;; This implements a very simple bitmap as a test for flood-fill
;; ~ Simon Johnston 2018.
;;
(module simple-bitmap racket

  (provide
    (contract-out

      ; make a new mutable bitmap object
      [make-bitmap (-> exact-positive-integer? exact-positive-integer? bitmap?)]

      ; is this a bitmap?
      [bitmap? (-> any/c boolean?)]

      ; return the height, in pixels, of the bitmap
      [bitmap-height (-> bitmap? exact-positive-integer?)]

      ; return the width, in pixels, of the bitmap
      [bitmap-width (-> bitmap? exact-positive-integer?)]

      ; pretty print a bitmap (one day)
      [bitmap-print (-> bitmap? void?)]

      ; a simple flood fill algorithm
      [bitmap-fill! (->i ([bm bitmap?]
                          [x (bm) (and/c exact-nonnegative-integer? (</c (bitmap-width bm)))]
                          [y (bm) (and/c exact-nonnegative-integer? (</c (bitmap-height bm)))]
                          [color integer?])
                         [result void?])]

      ; get the color of a given pixel
      [pixel-ref (->i ([bm bitmap?]
                       [x (bm) (and/c exact-nonnegative-integer? (</c (bitmap-width bm)))]
                       [y (bm) (and/c exact-nonnegative-integer? (</c (bitmap-height bm)))])
                      [result integer?])]

      ; set the color of a given pixel
      [pixel-set! (->i ([bm bitmap?]
                        [x (bm) (and/c exact-nonnegative-integer? (</c (bitmap-width bm)))]
                        [y (bm) (and/c exact-nonnegative-integer? (</c (bitmap-height bm)))]
                        [color integer?])
                       [result void?])]
    ))

;; ---------- Requirements

  (require math/array)

;; ---------- Implementation

  (define (bitmap? a)
    (and (mutable-array? a) (= (array-dims a) 2)))

  (define (make-bitmap height width)
    (array->mutable-array (make-array (vector height width) 0)))

  (define (bitmap-width bm)
    (vector-ref (array-shape bm) 1))

  (define (bitmap-height bm)
    (vector-ref (array-shape bm) 0))

  (define (bitmap-print bm)
    (for ([row (range (bitmap-height bm))])
         (for ([col (range (bitmap-width bm))])
              (display (pixel-ref bm row col)))
         (displayln "")))

  (define (pixel-ref bm x y)
    (array-ref bm (vector x y)))

  (define (pixel-set! bm x y color)
    (array-set! bm (vector x y) color))

  (define (bitmap-fill! bm x y color)
    (bitmap-filler bm x y color (pixel-ref bm x y)))

;; ---------- Internal procedures

  (define (bitmap-filler bm x y fill-color replace-color)
    (when (equal? (pixel-ref bm x y) replace-color)
      (pixel-set! bm x y fill-color)
      (when (> x 0)
        (bitmap-filler bm (- x 1) y fill-color replace-color))
      (when (< x (- (bitmap-width bm) 1))
        (bitmap-filler bm (+ x 1) y fill-color replace-color))
      (when (> y 0)
        (bitmap-filler bm x (- y 1) fill-color replace-color))
      (when (< y (- (bitmap-height bm) 1))
        (bitmap-filler bm x (+ y 1) fill-color replace-color))))
)
