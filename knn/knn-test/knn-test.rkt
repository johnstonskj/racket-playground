#lang racket

(require "../knn-lib/data.rkt")
(require math/statistics)

(define dataset
  (load-data-set "simple-test.json" 'json (list (make-feature "height") (make-classifier "class"))))

(define stats (feature-statistics dataset "height"))
(displayln (statistics-min stats))
(displayln (statistics-max stats))
(displayln (statistics-mean stats))
(displayln (statistics-variance stats))
(displayln (statistics-stddev stats))
(displayln (statistics-skewness stats))
(newline)

(write-snapshot dataset (current-output-port))
(newline)

(require "../knn-lib/knn.rkt")

(classify (hash "height" 199 "class" "m") dataset 5)