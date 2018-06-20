#lang racket

(define (get-read-port)
  (if (eq? (vector-length (current-command-line-arguments)) 0)
      (current-input-port)
      (let ([file-name (vector-ref (current-command-line-arguments) 0)])
        (open-input-file file-name))))

(define ns (make-base-namespace))

(define (port-display symbol port)
  (displayln (format "~s: ~s" symbol (eval `(,symbol ,port) ns))))

(let ([port (get-read-port)])
  (port-display 'input-port? port)
  (port-display 'input-port? port)
  (port-display 'file-stream-port? port)
  (port-display 'terminal-port? port)
  (port-display 'file-stream-buffer-mode port)
  (port-display 'file-position* port)
  (port-display 'port-counts-lines? port)
  (port-display 'port-count-lines-enabled port)
  (port-count-lines! port)
  (port-display 'port-counts-lines? port)
  (let-values ([(line col pos) (port-next-location port)])
    (displayln line)
    (displayln col)
    (displayln pos)))
