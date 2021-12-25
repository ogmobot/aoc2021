#!/usr/bin/env -S hy -B
(require [hy.extra.anaphoric [*]])
(setv substitute hy.extra.anaphoric.recur-sym-replace)

(defn d-iter []
    (iter ['d0  'd1  'd2  'd3  'd4  'd5  'd6
           'd7  'd8  'd9 'd10 'd11 'd12 'd13]))
(defn z-iter []
    (iter ['z0  'z1  'z2  'z3  'z4  'z5  'z6
           'z7  'z8  'z9 'z10 'z11 'z12 'z13]))

(defn base26 [x]
    ; string rep in b26
    (setv result "")
    (while (> x 0)
        (setv result (+ (get "abcdefghijklmnopqrstuvwxyz" (% x 26)) result))
        (setv x (// x 26)))
    result)

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

(defn maybe-simplify [expr bindings]
    (cond [(in expr bindings) (get bindings expr)]
          [(= (type expr) bool) (if expr 1 0)]
          [(= (type expr) hy.models.Expression)
            (do (setv a (maybe-simplify (get expr 1) bindings))
                (setv b (maybe-simplify (get expr 2) bindings))
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
        `(if ~deepest
            ~(maybe-simplify expr {deepest 1})
            ~(maybe-simplify expr {deepest 0}))
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

(defn find-allowed-values [expr targets]
    ;; returns possible pairs of d, z (below 100) that allow expr
    ;; to reach one of the targets
    (setv solutions [])
    (for [digit (range 9 0 -1)]
        (for [z (range 1000)]
            (setv result (hy.eval (substitute {'digit digit 'z z} expr)))
            (if (in result targets)
                (.append solutions [digit z]))))
    solutions)

(defn solve [z-exprs]
    (setv abs-targets [0])
    (setv tmp-targets [0])
    (for [index (range (- (len z-exprs) 1) -1 -1)]
        (setv res (find-allowed-values (get z-exprs index) tmp-targets))
        (print "index" index ":" (hy.repr res))
        (setv tmp-targets (list (map (fn [pair] (get pair 1)) res)))))

(defn sub-all-digits [z-exprs digits]
    (setv z 0)
    (setv result [])
    (for [[d expr d-symbol z-symbol] (zip digits z-exprs (d-iter) (z-iter))]
        (setv res (hy.eval (substitute {d-symbol d z-symbol z} expr)))
        (.append result res)
        (setv z res))
    result)

(defn interact [z-exprs]
    (setv digits [9 9 9 9 9 9 9 9 9 9 9 9 9 9])
    (while True
        (print (.join "\t" (map str (range 14))))
        (print (.join "\t" (map str digits)))
        (print (.join "\t" (map base26 (sub-all-digits z-exprs digits))))
        (setv parts (.split (input "> ")))
        (assoc digits (int (get parts 0)) (int (get parts 1)))))

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
        (print (hy.repr expr))))
    ;(interact z-expressions))

;;; This is looking a lot nicer now. Work backwards from the printed statements
;;; to get
;;; (e.g. from (if (= (+ (% z13 26) -1) d13)
;;;                 (// z13 26)
;;;                 (+ (* (// z13 26) 26) (+ d13 15))))
;;; to "d13 must equal (+ (% z13 26) -1) == last digit z13 - 1"

;;; Or, using interact mode, make the last letter of each string match up

(main)

;;; It *looks* like I'm writing Lisp, but it *feels* like I'm writing Python.
