#lang setup/infotab

(define collection "simple-bitmap")
(define pkg-desc "Description Here")
(define version "0.1")
(define pkg-authors '(simonjo))

(define deps '("base"))
(define build-deps '("scribble-lib" "racket-doc" "rackunit-lib"))
(define scribblings '(("scribblings/simple-bitmap.scrbl" ())))
