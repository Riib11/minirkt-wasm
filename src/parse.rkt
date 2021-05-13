#lang racket
(provide parse)
(require "grammar.rkt")

;; parse : S-Expr -> Prgm
(define (parse s)
  (match s
    [(list (and ds (list 'define _ _)) ...)
     (Prgm (map parse-defn ds) (Int 0))]
    [(list (and ds (list 'define _ _)) ... e)
     (Prgm (map parse-defn ds) (parse-expr e))]))

;; parse-defn : S-Expr -> Defn
(define (parse-defn s)
  (match s
    ;; define function with arguments
    [(list 'define (list (? symbol? f) (? symbol? xs) ...) e)
     (Defn f xs (parse-expr e))]
    ;; define constant (has no arguments)
    [(list 'define (? symbol? f) e)
     (Defn f (list) (parse-expr e))]
    ;; error
    [_ (error "parse error in [parse-defn]:" s)]))

;; parse-expr : S-Expr -> Expr
(define (parse-expr s)
  (match s
    ;; primitive values
    [(? integer?) (Int s)]
    [(? boolean?) (Bool s)]
    [(? char?) (Char s)]
    [(? string?) (String s)]
    ['eof (Eof)]
    ;; symbols
    [(? symbol?) (Var s)]
    [(list 'quote (list)) (Empty)]
    ;; primitive operators
    [(list (? (op? ops0) op0))          (Prim0 op0)]
    [(list (? (op? ops1) op1) e)        (Prim1 op1 (parse-expr e))]
    [(list (? (op? ops2) op2) e1 e2)    (Prim2 op2 (parse-expr e1) (parse-expr e2))]
    [(list (? (op? ops3) op3) e1 e2 e3) (Prim3 op3 (parse-expr e1) (parse-expr e2) (parse-expr e3))]
    ;; blocks
    [(list 'begin es ...) (Begin es)]
    [(list 'if e1 e2 e3) (If (parse-expr e1) (parse-expr e2) (parse-expr e3))]
    [(list 'let (list (list (? symbol? x) e1)) e2)
     (Let x (parse-expr e1) (parse-expr e2))]
    ;; application
    [(cons (? symbol? f) es)
     (App f (map parse-expr es))]
    ;; error
    [_ (error "parse error in [parse-expr]:" s)]))

;; primitive operators
(define (op? ops) (lambda (x) (memq x ops)))
(define ops0 '(read-byte peek-byte void))
(define ops1 '(add1 sub1 zero? char? write-byte eof-object? integer->char char->integer box unbox empty? car cdr integer-length char-alphabetic? char-whitespace? char-upcase char-downcase char-titlecase string-length string?))
(define ops2 '(+ - eq? cons string-ref make-string))
(define ops3 '(string-set!))
