#!/usr/bin/picolisp

(de get-target (text)
    # minx maxx miny maxy
    (let (nums (mapcar '((x)
            (if (member x (chop "0123456789-")) x " ")) text))
        (mapcar format (filter '((x) x) (split nums " ")))))

(de on-target? (particle target)
    (let ((left-x right-x bottom-y top-y) target
          (x y vx vy) particle)
        (and
            (<= x right-x) (>= x left-x)
            (<= y top-y)   (>= y bottom-y))))

(de dead? (particle target)
    (let ((left-x right-x bottom-y top-y) target
          (x y vx vy) particle)
        (or
            (> x right-x)
            (< y bottom-y))))

(de hits-target? (particle target)
    (cond
        ((dead?      particle target) NIL)
        ((on-target? particle target)   T)
        (T           (hits-target? (update particle) target))))

(de update (particle)
    (let ((x y vx vy) particle)
    (list
        (+ x vx)
        (+ y vy)
        (cond ((> vx 0) (- vx 1))
              ((< vx 0) (+ vx 1))
              (T        vx))
        (- vy 1))))

(de find-particle (target vx part?)
    # part?=1: finds first vy-value that goes thru the target for any vx
    # part?=2: finds all such vy-values
    (let ((left-x right-x bottom-y top-y) target)
        (if (<= vx right-x)
            (let (possibles (filter
                '((vy) (hits-target? (list 0 0 vx vy) target))
                (range (abs bottom-y) (- (abs bottom-y)))))
                (if (= part? 1)
                    (if (= 0 (length possibles))
                        (find-particle target (+ 1 vx) 1)
                        (car possibles))
                    (append
                        possibles
                        (find-particle target (+ 1 vx) 2)))))))

(let (inputtext (in "input17.txt" (line)))
    (let (target (get-target inputtext))
        # part 1
        (println ('((n) (/ (* (+ n 1) n) 2)) (find-particle target 1 1)))
        # part 2
        (println (length (find-particle target 1 2)))))

(bye)

#{
PicoLisp certainly feels... minimal. There don't seem to be any checks for
the number of arguments passed to a function (omitted arguments evaluate to
NIL), nor whether a symbol at the start of an S-expression evaluates to a
function (attempting to eval a non-existant function segfaults). The
requirement for T and NIL to be capitalised also tripped me up a few times
-- symbols evaluate to themselves, and all non-NIL symbols are truthy, so
`(if nil "true" "false")` evaluates to "true". Perhaps I should start every
file with `(setq nil NIL) (setq t T)`...
Other than the minimalism, it feels pretty close to other LISPs I've used.
This program risks overflowing the stack for large inputs, since the
`find-particle` function is a weird mix of recursive and iterative. I might
have to rewrite that function to make this work with the big-boy input.
}#
