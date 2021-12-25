#!/usr/bin/env -S hy -B
(require [hy.extra.anaphoric [*]])
(setv substitute hy.extra.anaphoric.recur-sym-replace)

(defn d-iter []
    (iter ['d0  'd1  'd2  'd3  'd4  'd5  'd6
           'd7  'd8  'd9 'd10 'd11 'd12 'd13]))
(defn z-iter []
    (iter ['z0  'z1  'z2  'z3  'z4  'z5  'z6
           'z7  'z8  'z9 'z10 'z11 'z12 'z13]))

(defn deepest-= [expr]
    ; finds a (= a b) expression that contains no other such expressions
    (if (= (type expr) hy.models.Expression)
        (do 
            (setv deepest-left (deepest-= (get expr 1)))
            (setv deepest-right (deepest-= (get expr 2)))
            (if (and (= (get expr 0) '=)
                     (= deepest-left None)
                     (= deepest-right None))
                expr
                (if (= deepest-left None)
                    deepest-right
                    deepest-left)))
        None))

(defn min-value [expr]
    (cond
        [(= (type expr) int) expr]
        [(in expr ['d0  'd1  'd2  'd3  'd4  'd5  'd6
                   'd7  'd8  'd9 'd10 'd11 'd12 'd13]) 1]
        [(= (type expr) hy.models.Expression)
            (do (setv a (get expr 1)
                      b (get expr 2))
                (cond
                    [(= '+ (get expr 0))
                        (+ (min-value a) (min-value b))]
                    [(= '% (get expr 0))
                        0]
                    ;; don't actually need more than this for this puzzle
                    [True None]))]
        [True None]))

(defn max-value [expr]
    (cond
        [(= (type expr) int) expr]
        [(in expr ['d0  'd1  'd2  'd3  'd4  'd5  'd6
                   'd7  'd8  'd9 'd10 'd11 'd12 'd13]) 9]
        [(= (type expr) hy.models.Expression)
            (do (setv a (get expr 1)
                      b (get expr 2))
                (cond
                    [(= '+ (get expr 0))
                        (+ (max-value a) (max-value b))]
                    [(= '% (get expr 0))
                        (- (max-value b) 1)]
                    ;; don't actually need more than this for this puzzle
                    [True None]))]
        [True None]))

(defn maybe-simplify [expr bindings]
    (cond [(in expr bindings) (get bindings expr)]
          [(= (type expr) bool) (if expr 1 0)]
          [(= (type expr) hy.models.Expression)
            (do (setv a (maybe-simplify (get expr 1) bindings)
                      b (maybe-simplify (get expr 2) bindings))
                ;(print "a=" (hy.repr a) "b=" (hy.repr b))
                (cond
                    [(and (= (type a) int) (= (type b) int))
                        (hy.eval `(~(get expr 0) ~a ~b))]
                    [(= '* (get expr 0))
                        (if (or (= a 0) (= b 0))
                            0
                            (if (= a 1) b
                                (if (= b 1) a
                                    `(* ~a ~b))))]
                    [(= '+ (get expr 0))
                        (if (= a 0) b
                            (if (= b 0) a
                                `(+ ~a ~b)))]
                    [(= '// (get expr 0))
                        (if (= b 1)
                            a
                            `(// ~a ~b))]
                    [(= '% (get expr 0))
                        (if (and (= (type a) int) (= (type b) int) (> b a))
                            a
                            `(% ~a ~b))]
                    [(= '= (get expr 0))
                        (if (= (type a) (type b) int)
                            (if (= a b) 1 0)
                            `(= ~a ~b))]
                    [True expr]))]
          [True expr]))

(defn cond-simplify [expr]
    (setv deepest (deepest-= expr))
    (if deepest
        ; given that 1 <= di <= 9, this might be simplifiable
        (do (setv min-a (min-value (get deepest 1))
                  max-a (max-value (get deepest 1))
                  min-b (min-value (get deepest 2))
                  max-b (max-value (get deepest 2)))
            (if (and min-a max-a min-b max-b
                    (or (> min-a max-b)
                        (< max-a min-b)))
                (maybe-simplify expr {deepest 0})
                `(if ~deepest
                    ~(maybe-simplify expr {deepest 1})
                    ~(maybe-simplify expr {deepest 0}))))
        expr))

(defn update-state [state line d-symbols]
    ;; mutates state into new state, with w, x, y, z as s-expressions
    (setv parts (.split (.strip line)))
    (setv new-expression
        (maybe-simplify
            (if (= (get parts 0) "inp")
                (next d-symbols)
                `(
                    ~(get
                        {"add" '+ "mul" '* "div" '// "mod" '% "eql" '=}
                        (get parts 0))
                    ~(get state (get parts 1))
                    ~(if (in (get parts 2) "wxyz")
                        (get state (get parts 2))
                        (int (get parts 2)))))
            {}))
    (assoc state (get parts 1) new-expression))

(defn sub-all-digits [z-exprs digits]
    (setv z 0)
    (setv result [])
    (for [[d expr d-symbol z-symbol] (zip digits z-exprs (d-iter) (z-iter))]
        (setv res (hy.eval (substitute {d-symbol d z-symbol z} expr)))
        (.append result res)
        (setv z res))
    result)

(defn verify [z-exprs n]
    (= 0
        (get
            (sub-all-digits z-exprs (map (fn [digit] (int digit)) (str n)))
            -1)))

(defn main []
    (with [f (open "input24.txt")]
        (setv lines (.readlines f)))
    (setv z-expressions [])
    (setv state {"w" 0 "x" 0 "y" 0 "z" 0})
    (setv z-symbols (z-iter))
    (setv d-symbols (d-iter))
    (for [line lines]
        (update-state state line d-symbols)
        (if (.startswith line "inp")
            (do
                (.append z-expressions (cond-simplify (get state "z")))
                (assoc state "z" (next z-symbols)))))
    (.append z-expressions (cond-simplify (get state "z")))
    (setv z-expressions (list (rest z-expressions)))
    (for [expr z-expressions]
        (print (hy.repr expr)))
    ;; see comments below for where these numbers came from
    (setv part1 99691891979938
          part2 27141191213911)
    (print (if (verify z-expressions part1) part1 "no solution for part 1"))
    (print (if (verify z-expressions part2) part2 "no solution for part 2")))

(main)

;;; Program output:
;   '(+ (* z0 26) d0)
;   '(+ (* z1 26) (+ d1 3))
;   '(+ (* z2 26) (+ d2 8))
;   '(if (= (+ (% z3 26) -5) d3) (// z3 26) (+ (* (// z3 26) 26) (+ d3 5)))
;   '(+ (* z4 26) (+ d4 13))
;   '(+ (* z5 26) (+ d5 9))
;   '(+ (* z6 26) (+ d6 6))
;   '(if (= (+ (% z7 26) -14) d7) (// z7 26) (+ (* (// z7 26) 26) (+ d7 1)))
;   '(if (= (+ (% z8 26) -8) d8) (// z8 26) (+ (* (// z8 26) 26) (+ d8 1)))
;   '(+ (* z9 26) (+ d9 2))
;   '(if (= (% z10 26) d10) (// z10 26) (+ (* (// z10 26) 26) (+ d10 7)))
;   '(if (= (+ (% z11 26) -5) d11) (// z11 26) (+ (* (// z11 26) 26) (+ d11 5)))
;   '(if (= (+ (% z12 26) -9) d12) (// z12 26) (+ (* (// z12 26) 26) (+ d12 8)))
;   '(if (= (+ (% z13 26) -1) d13) (// z13 26) (+ (* (// z13 26) 26) (+ d13 15)))

;;; Therefore, given z0 == 0 and letting B=26:
;   z1 = d0
;   z2 = B.z1 + (d1+3)
;      = B.d0 + (d1+3)
;   z3 = B.z2 + (d2+8)
;      = BB.d0 + B(d1+3) + (d2+8)
;   z4 = { z3/B = B.d0 + (d1+3) if d2+8 == d3+5
;        { z3 + (d3+5) otherwise
;   (Assume d2+8 == d3+5, since we need to approach zero => d3 == d2+3)
; > (so part1: d2=6, d3=9 or part2: d2=1, d3=4)
;   z5 = B.z4 + (d4+13)
;      = BB.d0 + B(d1+3) + (d4+13)
;   z6 = B.z5 + (d5+9)
;      = BBB.d0 + BB(d1+3) + B(d4+13) + (d5+9)
;   z7 = B.z6 + (d6+6)
;      = BBBB.d0 + BBB(d1+3) + BB(d4+13) + B(d5+9) + (d6+6)
;   z8 = { z7/B = BBB.d0 + BB(d1+3) + B(d4+13) + (d5+9) if d6+6 == d7+14
;        { ignore otherwise
;   (=> d6 == d7+8)
; > (so part1 and part2: d6=1, d7=9)
;   z9 = { z8/B = BB.d0 + B(d1+3) + (d4+13) if d5+9 == d8+8
;   (=> d5+1 == d8)
; > (so part1: d5=8, d8=9 or part2: d5=1, d8=2)
;   z10 = B.z9 + (d9+2)
;       = BBB.d0 + BB(d1+3) + B(d4+13) + (d9+2)
;   z11 = { z10/B = BB.d0 + B(d1+3) + (d4+13) if d9+2 == d10
;   (=> d9+2 == d10
; > (so part1: d9=7, d10=9 or part2: d9=1, d10=3)
;   z12 = { z11/B = B.d0 + (d1+3) if d4+13 == d11+5
;   (=> d4+8 == d11)
; > (so part1 and part2: d4=1, d11=9)
;   z13 = { z12/B = d0 if d1+3 == d12+9
;   (=> d1 == d12+6)
; > (so part1: d1=9, d12=3 or part2: d1=1, d12=7)
;   z14 = { z13/B = 0 if d0 == d13+1
;   (=> d0 == d13+1)
; > (so part1: d0=9, d13=8 or part2: d0=2, d13=1)

; putting it all together:
; part1 = 99691891979938
; part2 = 27141191213911

;;; It *looks* like I'm writing Lisp, but it *feels* like I'm writing Python.
