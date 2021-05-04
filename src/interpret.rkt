#lang racket
(provide interpret)
(require "grammar.rkt")

;;
;; type Result = Val | 'err
;;
;; type Val = Integer | Boolean | Character | String | Eof
;;            | Void | '() | (cons Val Val) | (box Val)
;;
;; type Env = (List (List Id Val))
;;
;; type Defns = (List (List Id Defn))
;;

;; interpret : Prgm -> Result
(define (interpret p)
  (match p
    [(Prgm ds e)
     (interpret-expr
      (map (lambda (d) (match d [(Defn f _ _) (list f d)])) ds)
      (list)
      e)]))

;; interpret expression [e] in environment [env] with definitions [defns]
(define (interpret-expr defns env e)
  (match e
    ;; primitive values
    [(Int i) i]
    [(Bool b) b]
    [(Char c) c]
    [(Eof) eof]
    [(Empty) '()]
    ;; primitive nullary operations
    [(Prim0 op0)
     (match op0
       ['void (void)]
       ['read-byte (read-byte)]
       ['peek-byte (peek-byte)]
       ['collect-garbage (collect-garbage)])]
    ;; primitive unary operations
    [(Prim1 op1 a)
     (match (interpret-expr defns env a)
       ['err 'err]
       [v
        (match op1
          ['add1 #:when (integer? v) (+ 1 v)]
          ['add1 #:when (integer? v) (+ 1 v)]
          ['sub1 #:when (integer? v) (- 1 v)]
          ['zero? #:when (integer? v) (zero? v)]
          ['char? (char? v)]
          ['integer->char #:when (integer? v) (integer->char v)]
          ['char->interger #:when (char? v) (char->integer v)]
          ['write-byte #:when (byte? v) (write-byte v)]
          ['eof-object? (eof-object? v)]
          ['box (box v)]
          ['car #:when (pair? v) (car v)]
          ['cdr #:when (pair? v) (cdr v)]
          ['unbox #:when (box? v) (unbox v)]
          ['string-length #:when (string? v) (string-length v)]
          ['empty? (empty? v)]
          [_ 'err])])]
    ;; primitive binary operations
    [(Prim2 op2 e1 e2)
     (match (interpret-expr* defns env (list e1 e2))
       [vs #:when (memq 'err vs) 'err]
       [(list v1 v2)
        (match op2
          ['+ #:when (and (integer? v1) (integer? v2)) (+ v1 v2)]
          ['- #:when (and (integer? v1) (integer? v2)) (- v1 v2)]
          ['eq? (eq? v1 v2)]
          ['cons (cons v1 v2)]
          ['string-ref (and (string? v1) (exact-nonnegative-integer? v2)) (string-ref v1 v2)]
          ['make-string (and (exact-nonnegative-integer? v1) (char? v2)) (make-string v1 v2)]
          [_ 'err]
       )])]
    ;; primitive ternary operations
    [(Prim3 op3 e1 e2 e3)
     (match (interpret-expr* defns env (list e1 e2 e3))
       [vs #:when (memq 'err vs) 'err]
       [(list v1 v2 v3)
        (match op3
          ['string-set! #:when (and (string? v1) (integer? v2) (char? v3)) (string-set! v1 v2 v3)]
          [_ 'err])])]
    ;; conditional
    [(If e1 e2 e3)
     (match (interpret-expr* defns env (list e1 e2 e3))
       [vs #:when (memq 'err vs) 'err]
       [(list v1 v2 v3) #:when (boolean? v1) (if v1 v2 v3)]
       [_ 'err])]
    ;; block
    [(Begin es)
     (match (interpret-expr* defns env es)
       ['err 'err]
       [vs (last vs)])]
    ;; local binding
    [(Let x e1 e2)
     (match (interpret-expr defns env e1)
       ['err 'err]
       [v (interpret-expr defns (extend env x v) e)])]
    ;; variable
    [(Var x) (lookup env x)]
    ;; application
    [(App f es)
     (match (interpret-expr* defns env es)
       ['err 'err]
       [vs
        (match (lookup-defn defns f)
          [(Defn f xs e)
           ; check arity
           (if (= (length xs) (length vs))
               (interpret-expr defns (zip xs vs) defns)
               'err)]
          [_ 'err])])]))

;; interpret-expr* : Defns Env (List Expr) -> (List Expr) | 'err
;; interpret a list of expressions [es], yielding either a list of values,
;; or ['err] if at least of the expressions evaluated to ['err]
(define (interpret-expr* defns env es)
  (match (map (lambda (e) (interpret-expr defns env e)) es)
    [vs #:when (memq 'err vs) 'err]
    [vs vs]))

;; lookup : Env Id -> Val | 'err
;; lookup identifier [x] in environment [env]
(define (lookup env x)
  (match (assq (assq x env))
    [#f 'err]
    [v v]))

;; extend : Env Id Val -> Env
;; extend environment [env] with binding of variable [x] to value [v]
(define (extend env x v)
  (cons (list x v) env))

;; lookup-defn : Defns Id -> Defn | 'err
;; lookup identifier [x] from definitions [defns]
(define (lookup-defn defns x)
  (match (assq x defns)
    [#f 'err]
    [defn defn]))

;; zip : List List -> List
;; zip together two lists
(define (zip xs ys)
  (match (list xs ys)
    [(list (cons x xs) (cons y ys)) (cons (list x y) (zip xs ys))]
    [ _    (list)]))
