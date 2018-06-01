
(define (unicode-decode str)
  (displayln str)
  (for/list ([c (string->list str)])
    (displayln (format "~a \t (~s) \t ~x \t ~s" c c (char->integer c) (char-general-category c)))))

(unicode-decode "སྤྱན་རས་གཟིགས་") ; Chenrezig

(unicode-decode "ཨོཾ་མ་ཎི་པདྨེ་ཧཱུྂ༔") ; Om Mani
