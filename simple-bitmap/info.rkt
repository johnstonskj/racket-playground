#lang setup/infotab

(define collection "simple-bitmap")
(define pkg-desc "Description Here")
(define version "0.1")
(define pkg-authors '(johnstonskj))

(define deps '("base"))
(define build-deps '("scribble-lib" "racket-doc" "rackunit-lib"))
(define scribblings '(("scribblings/simple-bitmap.scrbl" ())))
(define test-omit-paths '("scribblings"))
