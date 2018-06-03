#lang scribble/manual

@(require racket/sandbox
          scribble/eval
          (for-label "../private/simple-bitmap.rkt"
                     racket
                     racket/contract
                     math/array))

@(define bitmap-eval (make-base-eval
                        '(require racket/list "private/simple-bitmap.rkt")
                        ))

@title[#:tag "example" #:version "0.1"]{simple-bitmap}
@author[(author+email "Simon Johnston" "johnstonskj@gmail.com")]

@defmodule[simple-bitmap #:use-sources ("private/simple-bitmap.rkt")]

A Sample package and module implementing a basic data structure and an example
procedure. The source is included in the @racket[racket-playground] repository on
@hyperlink[
  "https://github.com/johnstonskj/racket-playground/tree/master/simple-bitmap"
  "GitHub"].

@examples[ #:eval bitmap-eval
  (define bm (make-bitmap 16 8))
  (bitmap-height bm)
  (bitmap-width bm)
  (pixel-ref bm 2 2)
  (pixel-set! bm 2 2 1)
  (pixel-ref bm 2 2)
]

@;{============================================================================}
@section[#:tag "bitmap:types"]{Types and Predicates}

This module only provides a single @italic{abstract} type, @racket[bitmap] that
is actually defined in terms of a 2-dimensional @racket[Mutable-Array] of
@racket[Integer] pixels. These individual integers, representing the
@racket[color] of the pixel, are addressable but not promoted as a type in
themselves.

@defproc[#:kind "predicate"
         (bitmap? [a any]) Boolean]{
Returns @racket[#t] if the argument is a bitmap.
}

@;{============================================================================}
@section[#:tag "bitmap:construct"]{Construction}

@defproc[#:kind "constructor"
         (make-bitmap
           [height exact-positive-integer?]
           [width exact-positive-integer?])
         bitmap?]{
Returns a new @racket[bitmap] with the given @racket[height] and @racket[width],
with every pixel set to zero.
}

@;{============================================================================}
@section[#:tag "bitmap:access"]{Accessors}

@defproc[(bitmap-height
           [bm bitmap?])
         exact-positive-integer?]{
Returns the height (number of rows) of the provided @racket[bitmap].
}

@defproc[(bitmap-width
           [bm bitmap?])
         exact-positive-integer?]{
Returns the width (number of columns) of the provided @racket[bitmap].
}

@defproc[(bitmap-print
           [bm bitmap?])
         void?]{
Prints the current @racket[bitmap].
}

@;{============================================================================}
@section[#:tag "bitmap:pixels"]{Pixel Operations}

@defproc[(pixel-ref
           [bm bitmap?]
           [x (and/c exact-nonnegative-integer? (</c (bitmap-width bm)))]
           [y (and/c exact-nonnegative-integer? (</c (bitmap-height bm)))])
         integer?]{
Retrieve the color of the @racket[pixel] at the given @racket[x] and @racket[y]
coordinates.
}

@defproc[(pixel-set!
           [bm bitmap?]
           [x (and/c exact-nonnegative-integer? (</c (bitmap-width bm)))]
           [y (and/c exact-nonnegative-integer? (</c (bitmap-height bm)))]
           [color integer?])
         void?]{
Set the color of the @racket[pixel] at the given @racket[x] and @racket[y]
coordinates.
}

@;{============================================================================}
@section[#:tag "bitmap:transforms"]{Transformations}

@defproc[(bitmap-fill!
          [bm bitmap?]
          [x (and/c exact-nonnegative-integer? (</c (bitmap-width bm)))]
          [y (and/c exact-nonnegative-integer? (</c (bitmap-height bm)))]
          [color integer?])
        void?]{
A flood-fill operation that will replace the color of the pixel at the given
coordinates with the specified @racket[color] and any adjacent pixels of the
same color until all have been replaced.

@examples[ #:eval bitmap-eval
  (define bm (make-bitmap 7 8))
  (for ([row (range 4)])
       (pixel-set! bm row 3 1))
  (for ([col (range 4)])
       (pixel-set! bm 3 col 1))
  (bitmap-print bm)
  (bitmap-fill! bm 2 2 9)
  (bitmap-print bm)
]

}
