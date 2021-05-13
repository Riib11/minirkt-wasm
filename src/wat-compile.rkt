#lang racket
(require "grammar.rkt" "wat-grammar.rkt")
(provide (all-defined-out))

;;
;; MiniRkt -> Wat struct
;;

;; Prgm -> WatPrgm
(define (prgm->watprgm prgm)
  (match prgm
    [(Prgm ds e)
     (map defn->watdecl
          (cons (Defn 'main (list) e) ds))]
    ))

;; Defn -> List WatDecl
(define (defn->watdecl d)
  (match d
    [(Defn f xs e)
     (WatFunc f xs (expr->watinsts e))]
    ))

;; Expr -> List WatInst
(define (expr->watinsts e)
  (match e
    [(Eof) 'TODO]
    [(Empty) 'TODO]
    [(Int i) (list (WatConst i))]
    [(Bool b) 'TODO]
    [(Char c) 'TODO]
    [(String s) 'TODO]
    [(Prim0 op)
     (match op
       ['read-byte 'TODO]
       ['peek-byte 'TODO]
       ['void 'TODO]
       ['collect-garbage 'TODO])]
    [(Prim1 op e)
     (match op
       ['add1 (append (expr->watinsts e)
                      (list (WatConst 1))
                      (list 'i32.add))]
       ['sub1 (append (expr->watinsts e)
                      (list (WatConst 1))
                      (list 'i32.sub))]
       ['zero? (append (expr->watinsts e)
                       (list 'i32.eqz))]
       ['char? 'TODO]
       ['integer->char 'TODO]
       ['char->integer 'TODO]
       ['write-byte 'TODO]
       ['eof-object? 'TODO]
       ['box 'TODO]
       ['car 'TODO]
       ['cdr 'TODO]
       ['unbox 'TODO]
       ['string-length 'TODO]
       ['empty? 'TODO])]
    [(Prim2 op e1 e2)
     (match op
       ['+ (append (expr->watinsts e1)
                   (expr->watinsts e2)
                   (list 'i32.add))]
       ['- (append (expr->watinsts e1)
                   (expr->watinsts e2)
                   (list 'i32.sub))]
       ['eq? (append (expr->watinsts e1)
                     (expr->watinsts e2)
                     (list 'i32.eq))]
       ['cons 'TODO]
       ['string-ref 'TODO]
       ['make-string 'TODO])]
    [(Prim3 op e1 e2 e3)
     (match op
       ['string-set! 'TODO])]
    [(If e1 e2 e3) (WatIf (expr->watinsts e1)
                          (expr->watinsts e2)
                          (expr->watinsts e3))]
    [(Begin es) 'TODO]
    [(Let x e1 e2) 'TODO]
    [(Var x) (list (WatGet x))]
    [(App x es) (append* (list (WatCall x))
                         (map expr->watinsts es))]
    ))

;;
;; printing
;;

;; WatPrgm -> (List String)
(define (print-watprgm watprgm)
  (string-append "(module\n" (unlines (map print-watdecl watprgm)) "\n)"))

;; WatDecl -> (List String)
(define (print-watdecl watdecl)
  (match watdecl
    [(WatFunc f xs insts)
     (string-append
      "(func (export \"" (symbol->string f) "\") "
      (unwords (map (lambda (x) (string-append "(param " (id->string x) " i32) ")) xs))
      "(result i32)\n"
      (unlines (map unwords (map print-watinst insts)))
      "\n)")]))

;; WatInst -> (List String)
(define (print-watinst watinst)
  (match watinst
    [(WatGet x) (list (string-append "get_local " (id->string x)))]
    [(WatConst i) (list (string-append "i32.const " (int->string i)))]
    [(WatIf c insts1 insts2) (append (list "if ") (print-watinst c) insts1 (list " else ") insts2 (list " end"))]
    [(WatCall f) (list (string-append "call " (id->string f)))]
    [inst (list (id->string inst))]))
  
;;
;; utilities
;;

(define (unwords strs)
  (match strs
    [(list) ""]
    [(list s) s]
    [(cons s ss) (string-append s " " (unwords ss))]))

(define (unlines strs)
  (match strs
    [(list) ""]
    [(list s) s]
    [(cons s ss) (string-append s "\n" (unlines ss))]))

(define (id->string x) (string-append "$" (symbol->string x)))
(define (int->string i) (number->string i))