#lang racket
(provide (all-defined-out))

;;
;; type Prgm = (Prgm (List Defn) Expr)
;;
;; type Defn = (Defn Id (List Id) Expr)
;;
;; type Expr = (Eof)
;;           | (Empty)
;;           | (Int Integer)
;;           | (Bool Boolean)
;;           | (Char Character)
;;           | (String)         
;;           | (Prim0 Op0)
;;           | (Prim1 Op1 Expr)
;;           | (Prim2 Op2 Expr Expr)      
;;           | (Prim3 Op3 Expr Expr Expr)     
;;           | (If Expr Expr Expr)
;;           | (Begin (List Expr))
;;           | (Let Id Expr Expr)
;;           | (Var Id)
;;           | (App Id (List Expr))
;;
;; type Id   = Symbol
;;
;; type Op0  = 'read-byte | 'peek-byte | 'void | 'collect-garbage
;;
;; type Op1  = 'add1 | 'sub1 | 'zero?
;;           | 'char? | 'integer->char | 'char->integer
;;           | 'write-byte | 'eof-object?
;;           | 'box | 'car | 'cdr | 'unbox
;;           | 'string-length | 'string?
;;           | 'empty?
;;
;; type Op2  = '+ | '- | 'eq? | 'cons | 'string-ref | 'make-string
;;
;; type Op3  = 'string-set!        
;;

(struct Prgm   (ds e)       #:prefab)
(struct Defn   (id xs e)    #:prefab)
(struct Eof    ()           #:prefab)
(struct Empty  ()           #:prefab)
(struct Int    (i)          #:prefab)
(struct Bool   (b)          #:prefab)
(struct Char   (c)          #:prefab)
(struct String (s)          #:prefab)   
(struct Prim0  (p)          #:prefab)
(struct Prim1  (p e)        #:prefab)
(struct Prim2  (p e1 e2)    #:prefab)
(struct Prim3  (p e1 e2 e3) #:prefab)
(struct If     (e1 e2 e3)   #:prefab)
(struct Begin  (es)         #:prefab)
(struct Let    (x e1 e2)    #:prefab)
(struct Var    (x)          #:prefab)
(struct App    (f es)       #:prefab)