#lang at-exp racket

(module rackex/base racket

  (provide document-class & textit)

  (define current-document (make-parameter '()))
  
  (define (document-class class-name) (display ""))

  (define (& t . tt) (display t) (display (apply string-append tt)))

  (define (textit t) (format "~a" t))
)

(require 'rackex/base)

@document-class[]{article}

@&{here is some @textit{italic} text}

(displayln "")
