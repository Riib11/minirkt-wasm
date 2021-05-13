#lang racket
(provide (all-defined-out))
(require "grammar.rkt" "parse.rkt")

;;
;; type WatPrgm = (List WatDecl)
;;
;;
;; type WatDecl = (WatFunc Id (List Id) (List WatInst))
;;
;; type WatInst = (WatGet Id) | 'i32.add | 'i32.sub
;;

;; WatPrgm

;; WatDecl
(struct WatFunc (f xs insts) #:prefab)
(struct WatExport (f) #:prefab)

;; WatInst
(struct WatGet (x) #:prefab)
(struct WatConst (i) #:prefab)
(struct WatCall (x) #:prefab)
(struct WatIf (cond insts1 insts2) #:prefab)

