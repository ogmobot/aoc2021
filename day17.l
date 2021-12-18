#!/usr/bin/pil

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

(de lower-bound-t (u x)
    (/ (+ 1 u u (sqrt (- (** (+ 1 u u) 2) (* 8 x)))) 2)) # helper function

(de bounds-y (u lower-coord upper-coord)
    # u is initial velocity
    # returns a list of times for which particle can hit target
    (filter
        '((x) (let (middle (** (- (* 2 x) (+ 1 u u)) 2))
            (and (>= (- (** (+ 1 u u) 2) (* lower-coord 8)) middle)
                 (<= (- (** (+ 1 u u) 2) (* upper-coord 8)) middle))))
        (range
            (lower-bound-t u upper-coord)
            (+ 1 (lower-bound-t u lower-coord)))))

(de bounds-checker-x (u lower-coord upper-coord)
    # returns a function f such that
    # (f t) == T if this could hit x-coord of target at time t
    #       == NIL otherwise
    # (can't use ranges like y, because sometimes there's no upper limit)
    (fill '((x)
        (let (x-value
            (if (<= u x)
                (/ (* (+ u 1) u) 2)
                (/ (- (* (+ 1 u u) x) (* x x)) 2)))
            (and (<= lower-coord x-value)
                 (>= upper-coord x-value))))
        '(u lower-coord upper-coord)))

# (lower-bound-t 0 -10) ~ 4
# (lower-bound-t 0  -5) ~ 3
# (bounds-y 2 -10 -5) == (7)
# (bounds-y 3 -10 -5) == (9)
# (bounds-y 0 -10 -5) == (4 5)

(let (inputtext (in "input17.txt" (line)))
    (let (target (get-target inputtext))
        # part 1
        (println ('((n) (/ (* (+ n 1) n) 2)) (find-particle target 1 1)))
        # part 2
        (println (length (find-particle target 1 2)))))

#(bye)

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
