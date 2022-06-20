#lang racket

(module fields racket

  (provide (all-defined-out))

  (require syntax/parse)
  (require (for-syntax racket/base racket/bool racket/syntax syntax/parse))

  (define-syntax (define-syntax-literals stx)
    (syntax-parse stx
      [(_ name:id (lit:id ...))
       (with-syntax ([set-id (format-id #'name "~a/set" #'name)]
                     [cls-id (format-id #'name "~a/class" #'name)]
                     [cls-description (format "~a literals" #'name)]
                     [cls-var (format-id #'name "x:~a/class" #'name)]
                     [pred-id (format-id #'name "~a?" #'name)])
         #`(begin
             #,@(for/list ([literal (syntax->list #'(lit ...))])
                  #`(define #,literal (quote #,literal)))
             (begin-for-syntax
               (define-literal-set set-id (lit ...))
               (define-syntax-class cls-id
                 #:description cls-description
                 #:literal-sets (set-id)
                 (pattern (~or lit ...))))
             (define-syntax (pred-id stx)
               (syntax-parse stx
                 [(_ cls-var) #'#t]
                 [else #'#f]))))]))

  (define-syntax-literals kw-required (required optional))

  (define-syntax-literals kw-container (list-of set-of map-of none))

  (define-syntax (field stx)
    (syntax-parse stx
      #:literal-sets (kw-required/set kw-container/set)
      [(_ index:nat name:id type:id)
       #'(field index name required none type)]
      
      [(_ index:nat name:id ?required:kw-required/class type:id)
       #'(field index name ?required none type)]
      
      [(_ index:nat name:id ?container:kw-container/class type:id)
       #'(field index name required ?container type)]
      
      [(_ index:nat name:id ?container:kw-container/class type:id type2:id)
       #:fail-when (not (equal? (format "~a" (syntax->datum #'?container)) "map-of"))
                   "specification of a second type requires a container map-of"
       #'(field index name required ?container type type2)]
      
      [(_ index:nat
          name:id
          ?required:kw-required/class
          ?container:kw-container/class
          major-type:id
          (~optional minor-type:id #:defaults ([minor-type #'#f])))
       #:fail-when (and (equal? (format "~a" (syntax->datum #'?container)) "map-of")
                        (false? (syntax->datum #'minor-type)))
                   "map-of requires a second type to be specified"
       #`(begin
           (unless (and (procedure? major-type)
                        (= (procedure-arity major-type) 1)
                        (or (false? minor-type)
                            (and (procedure? minor-type)
                                 (= (procedure-arity minor-type) 1))))
             (error "type-predicate must be a predicate procedure"))
           ;; TODO: check map-of
           (displayln (format
                       "field ~a (~a) is a ~a ~a ~a"
                       (quote name)
                       index
                       (quote ?required)
                       (if (not (equal? ?container none))
                           (format "~a ~a"
                                   (quote ?container)
                                   (object-name major-type))
                           (object-name major-type))
                       (if (equal? ?container map-of)
                           (format "-> ~a" (object-name major-type))
                           ""))))]
    ))
  )

(require 'fields)

(field 1 foo integer?)

(field 1 foo required integer?)

(field 1 foo optional integer?)

(field 1 foo list-of integer?)

(field 1 foo map-of string? string?)

(field 1 foo optional list-of integer?)

