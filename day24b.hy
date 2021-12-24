#!/usr/bin/env -S hy -B

(defn base26 [x]
    (setv result "")
    (while (> x 0)
        (setv result (+ result (get "abcdefghijklmnopqrstuvwxyz" (% x 26))))
        (setv x (// x 26)))
    result)

(defn super-equals [a b]
    (if (= b 0) (return (= a b)))
    (print "checking equality of" a "and" b)
    (if (= a b)
        (print "equality SUCCEEDED")
        (print "equality FAILED - off by" (abs (- a b))))
    (int (= a b)))
(defn interpret [state line digits]
    (setv parts (.split line))
    (setv new-val
        (if (= (get parts 0) "inp")
            (.pop digits 0)
            (hy.eval `(
                ~(get
                    {"add" '+ "mul" '* "div" '// "mod" '% "eql" 'super-equals}
                    (get parts 0))
                ~(get state (get parts 1))
                ~(if (in (get parts 2) "wxyz")
                    (get state (get parts 2))
                    (int (get parts 2)))))))
    (assoc state (get parts 1) new-val))

(defn main []
    (with [f (open "input24.txt")]
        (setv lines (.readlines f)))
    (setv state {"w" 0 "x" 0 "y" 0 "z" 0})
    ; pairs 0D 1C 23 4B 58 67 9A
    ;             a b c c d e f f e g g d b a
    ;             0 1 2 3 4 5 6 7 8 9 A B C D
    (setv digits [9 9 6 9 1 8 9 1 9 7 9 9 3 8])
    (for [line lines]
        ;(if (.startswith line "inp")
            ;(print (base26 (get state "z"))))
        (interpret state line digits))
    ;(print (base26 (get state "z")))

    ;             a b c c d e f f e g g d b a
    ;             0 1 2 3 4 5 6 7 8 9 A B C D
    (setv digits [2 7 1 4 1 1 9 1 2 1 3 9 1 1])
    (for [line lines]
        (if (.startswith line "inp")
            (print (base26 (get state "z"))))
        (interpret state line digits))
    (print (base26 (get state "z"))))
    ; TODO make the computer do the work instead of me

(main)
