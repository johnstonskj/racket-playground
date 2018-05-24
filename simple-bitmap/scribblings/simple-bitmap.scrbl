#lang scribble/manual

@(require
          (for-label "../private/simple-bitmap.rkt"
                     racket
                     racket/contract
                     math/array))

@title[#:tag "example" #:version "0.1"]{simple-bitmap}
@author{Simon Johnston}

@defmodule[simple-bitmap #:use-sources ("private/simple-bitmap.rkt")]

A Sample package and module implementing a basic data structure.

@;{==================================================================================================}
@section[#:tag "bitmap:types"]{Types}

@defproc[#:kind "predicate"
         (bitmap? [a any]) Boolean]{
Returns a true if the argument is a bitmap.
}

@;{==================================================================================================}
@section[#:tag "bitmap:construct"]{Construction}

@defproc[#:kind "constructor"
         (make-bitmap
           [width exact-positive-integer?]
           [height exact-positive-integer?])
         bitmap?]{
Returns a bitmap.
Analogous to @racket[make-array], the bitmaps returned by @racket[make-bitmap]
are mutable 2-dimensional arrays.
}
