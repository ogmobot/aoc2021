#!/usr/bin/pil

(de get-target (text)
    # minx maxx miny maxy
    (let (nums (mapcar '((x)
            (if (member x (chop "0123456789-")) x " ")) text))
        (mapcar format (filter '((x) x) (split nums " ")))))

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
    # (can't use ranges, because sometimes there's no upper limit)
    (fill '((x)
        (let (x-value
            (if (<= u x)
                (/ (* (+ u 1) u) 2)
                (/ (- (* (+ 1 u u) x) (* x x)) 2)))
            (and (<= lower-coord x-value)
                 (>= upper-coord x-value))))
        '(u lower-coord upper-coord)))

(de all-trajectories-y (target)
    # returns a list of length (* 2 bottom-y).
    # each element of the list is a range of pairs (time . uy)
    (let ((left-x right-x bottom-y top-y) target)
        (apply append (mapcar
            '((uy)
                (mapcar
                    '((x) (cons uy x))
                    (bounds-y uy bottom-y top-y)))
            (range (- bottom-y) bottom-y)))))

(de all-trajectories-x (target candidates)
    # candidates is a list of pairs (uy . t)
    # returns a list of pairs (ux . uy), with duplicates
    (let ((left-x right-x bottom-y top-y) target)
        (apply append (mapcar
            '((ux)
                (mapcar '((p) (cons ux (car p)))
                    (filter
                        '((p) ((bounds-checker-x ux left-x right-x) (cdr p)))
                        candidates)))
            (range 0 right-x)))))

(let (inputtext (in "input17.txt" (line))
      target (get-target inputtext)
      trajs  (uniq (all-trajectories-x target (all-trajectories-y target))))
    # part 1
    (println ('((n) (/ (* (+ n 1) n) 2)) (apply max (mapcar cdr trajs))))
    # part 2
    (println (length trajs)))

# old implementation ~0.47 seconds
# new implementation ~0.05 seconds
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
}#
