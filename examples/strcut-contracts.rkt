#lang racket

(module cars racket
  (provide
   (contract-out
    (struct car ([model string?] [year integer?]))))

  (struct car (model year)))

(require 'cars)

(car "ford" 1990)

(car 1990 "ford")