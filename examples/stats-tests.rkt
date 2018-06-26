#lang racket


(define data (vector 36 43 14 21 13 45 47 28 19 47 2 14 38 25 50 43 46 41 37 42 21 37 41 0 6 5 7 38 28 18 28 47 27 38 13 48
24 43 7 18 24 42 32 4 11 7 41 42 38 50 32 48 45 9 36 7 44 32 49 18 45 49 19 28 13 41 27 25 17 11 15 10
4 32 34 47 34 21 14 49 6 13 30 48 42 29 8 6 39 39 28 3 36 31 47 30 3 25 0 17))

(displayln data)

; (require "stats.rkt")
;
; (define data-stats (statistics data))
;
; (displayln (format "n: ~s" (vector-length data)))
; (displayln (format "μ: ~s" (μ data-stats)))
; (displayln (format "m: ~s" (median data-stats))) ; returning 29.0, expecting 28.5
; (displayln (format "V: ~s" (Var data-stats)))
; (displayln (format "σ: ~s" (σ data-stats)))
; (newline)

(require math/statistics)

(define stats (update-statistics* empty-statistics data))
(displayln (statistics-min stats))
(displayln (statistics-max stats))
(displayln (statistics-count stats))
(displayln (statistics-mean stats))
(displayln (statistics-variance stats))
(displayln (statistics-stddev stats))
(displayln (statistics-skewness stats))
