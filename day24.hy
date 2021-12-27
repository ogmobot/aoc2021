#!/usr/bin/env -S hy -B
(require [hy.extra.anaphoric [*]])
(setv substitute hy.extra.anaphoric.recur-sym-replace)

(defn d-iter []
    (iter ['d0  'd1  'd2  'd3  'd4  'd5  'd6
           'd7  'd8  'd9 'd10 'd11 'd12 'd13]))
(defn z-iter []
    (iter ['z0  'z1  'z2  'z3  'z4  'z5  'z6
           'z7  'z8  'z9 'z10 'z11 'z12 'z13 'z14]))

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

(defn quotient-remainder [expr divisor]
    ;; Simplifies one of two kinds of expression
    ;;   (+ (* a divisor) b) => returns [a b]
    ;;   d => returns [0 a]
    ;; Otherwise returns None.
    (if (and (= (type expr) hy.models.Expression)
             (= (get expr 0) '+)
             (= (type (get expr 1)) hy.models.Expression)
             (= (get (get expr 1) 0) '*)
             (= (get (get expr 1) 2) divisor))
        [(get (get expr 1) 1) (get expr 2)]
        (if (in expr (list (d-iter)))
            [0 expr]
            None)))

(defn div-simplify [expr]
    ;; simplifies (// a b) or (% a b) by evaluating (quotient-remainder a b)
    (if (= (type expr) hy.models.Expression)
        (do
            (setv qr (quotient-remainder (get expr 1) (get expr 2)))
            (cond
                [(= qr None) expr]
                [(= (get expr 0) '//) (get qr 0)]
                [(= (get expr 0) '%)  (get qr 1)]
                [True expr]))
        expr))

(defn simplify-constraint [expr]
    ;; tries to simplify a constraint using div-simplify
    ;; makes assumptions about the input!
    (if (= (type expr) hy.models.Expression)
        (do (setv a (get expr 1)
                  b (get expr 2))
            (cond
                [(= (get a 0) '+)
                    (if (= (get b 0) '+)
                        ;; subtract the smallest operand from both sides
                        (do (setv +a (get a 2)
                                  +b (get b 2)
                                  new-a `(+ ~(get a 1) ~(- +a (min +a +b)))
                                  new-b `(+ ~(get b 1) ~(- +b (min +a +b))))
                            (simplify-constraint
                                `(=
                                    ~(maybe-simplify new-a {})
                                    ~(maybe-simplify new-b {}))))
                        ;; else subtract second operand of + from both sides
                        (simplify-constraint `(= ~(get a 1) (+ ~b ~(- (get a 2))))))]
                [(or (= (get a 0) '%) (= (get a 0) '//))
                    (simplify-constraint `(= ~(div-simplify a) ~b))]
                [True expr]))
        expr))

(defn get-constraints [z-exprs z-val]
    ;; makes big assumptions about the input!
    (setv z-symbol (z-iter)
          bindings {(next z-symbol) z-val}
          constraints [])
    (for [z-expr z-exprs]
        (do
            (setv z-expr (substitute bindings z-expr)
                  next-z-expr
                (if (= (get z-expr 0) 'if)
                    ;; make this condition true
                    (do 
                        (.append constraints (simplify-constraint (get z-expr 1)))
                        (get z-expr 2)) ; i.e. value when true
                    ;; else
                    z-expr))
            (assoc bindings (next z-symbol)
                (div-simplify
                    (maybe-simplify
                        (substitute bindings next-z-expr) bindings)))))
    constraints)

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
    (setv z-expressions (list (rest z-expressions))
          constraints (get-constraints z-expressions 0))
    (list (map (fn [x] (print (hy.repr x))) constraints))
    (setv part1 99691891979938
          part2 27141191213911)
    (print (if (verify z-expressions part1) part1 "no solution for part 1"))
    (print (if (verify z-expressions part2) part2 "no solution for part 2")))

(main)

;;; It *looks* like I'm writing Lisp, but it *feels* like I'm writing Python.
