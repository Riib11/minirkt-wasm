#lang racket
(provide compile)
(require "grammar.rkt" "parse.rkt" "wat-grammar.rkt" "wat-compile.rkt")


(define (compile src)
  (print-watprgm (prgm->watprgm (parse src))))