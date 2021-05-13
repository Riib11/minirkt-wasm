#lang racket
(require "grammar.rkt" "parse.rkt" "wat-grammar.rkt" "wat-compile.rkt" "compile.rkt")

(define (main fn)
  (let ((in-port (open-input-file fn)))
    (begin
      (read-line in-port) ; ignore `#lang racket`
      (let ((tgt (compile (port->list read in-port))))
        (let ((out-port (open-output-file (string-append fn ".wat")
                                          #:mode 'text
                                          #:exists 'replace)))
          (begin
            (display tgt out-port)
            (close-output-port out-port)
            (close-input-port in-port)))))))

(define (test)
  (let ((p (open-input-file "../demo/examples/test.rkt")))
    (begin
      (read-line p) ; ignore `#lang racket`
      (displayln (compile (port->list read p)))
      (close-input-port p))))

(display "file to compile: ")
(main (symbol->string (read)))