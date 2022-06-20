#lang racket

(define example%
  (class object%

    (init-field thing)
    
    (init-field [another (some-init-fun thing)])

    (super-new)

    (define/public (wot)
      (displayln another))))

(define (some-init-fun t)
  (displayln t)
  "?")

(define o (make-object example% "a"))
(send o wot)

; ---------------------------------------------------

(define base%
  (class object%

    (init-field name)

    (super-new)

    (define/pubment (foo)
      (displayln (format "base:foo: ~a" name))
      (inner (void) foo))))

(define derived%
  (class base%

    (super-new [name "DX"])
    
    (define/augment (foo)
      (displayln "derived:foo"))))

(define wrapper%
  (class base%

    (init-field wrapped)
    
    (super-new [name "WP"])
    
    (define/augment (foo)
      (send wrapped foo))))

(define silly%
  (class base%

    (super-new [name ":-)"])
    
    (define/augment (foo)
      (displayln "this is not foo"))))


(displayln "-----")
(send (make-object base% "FOO") foo)

(displayln "-----")
(send (make-object derived%) foo)

(displayln "-----")
(send (make-object wrapper% (make-object silly%)) foo)
