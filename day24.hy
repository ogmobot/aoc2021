#!/usr/bin/env -S hy -B
(require [hy.extra.anaphoric [*]])
(setv substitute hy.extra.anaphoric.recur-sym-replace)

(setv input-symbol ((fn []
    ;(setv val 0)
    (while True
        ;(yield 1)))))
        (yield 'digit)))))
        ;(yield-from ['digit0 'digit1 'digit2 'digit3 'digit4 'digit5 'digit6 'digit7 'digit8 'digit9 'digit10 'digit11 'digit12 'digit13])

(defn base26 [x]
    ; string rep in b26
    (setv result "")
    (while (> x 0)
        (setv result (+ result (get "abcdefghijklmnopqrstuvwxyz" (% x 26))))
        (setv x (// x 26)))
    result)

(defn maybe-simplify [expr]
    (cond [(= (type expr) bool) (if expr 1 0)]
          [(= (type expr) hy.models.Expression)
            (do (setv a (maybe-simplify (get expr 1)))
                (setv b (maybe-simplify (get expr 2)))
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

(defn update-state [state line]
    ;; mutates state into new state, with w, x, y, z as s-expressions
    (setv parts (.split (.strip line)))
    (setv new-expression
        (maybe-simplify
            (if (= (get parts 0) "inp")
                (next input-symbol)
                `(
                    ~(get
                        {"add" '+ "mul" '* "div" '// "mod" '% "eql" '=}
                        (get parts 0))
                    ~(get state (get parts 1))
                    ~(if (in (get parts 2) "wxyz")
                        (get state (get parts 2))
                        (int (get parts 2)))))))
    (assoc state (get parts 1) new-expression))

(defn find-allowed-values [expr targets]
    ;; returns possible pairs of digit, z (below 100) that allow expr
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
    (for [[d expr] (zip digits z-exprs)]
        (setv res (hy.eval (substitute {'digit d 'z z} expr)))
        (.append result res)
        (setv z res)
        (print "z" z))
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
    (for [line lines]
        (update-state state line)
        (if (.startswith line "inp")
            (do
                (.append z-expressions (get state "z"))
                (setv state {"w" (get state "w") "x" 'x "y" 'y "z" 'z}))))
    (.append z-expressions (get state "z"))
    (interact z-expressions))
    ;(for [expr z-expressions]
        ;(print (hy.repr expr))))

(main)
