#!/usr/bin/picolisp

(de triangular (n)
    (/ (* (+ n 1) n) 2))

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
        (T (hits-target? (update particle) target))))

(de update (particle)
    (let ((x y vx vy) particle)
    (list
        (+ x vx)
        (+ y vy)
        (cond ((> vx 0) (- vx 1))
              ((< vx 0) (+ vx 1))
              (T        vx))
        (- vy 1))))

(de find-particle (target vx upper-limit part?)
    # part?=1: finds first vy-value that goes thru the target
    # part?=2: finds all such vy-values
    (let ((left-x right-x bottom-y top-y) target)
        (cond
            ((> vx upper-limit) NIL)
            (T
                (let (possibles (filter
                    '((vy) (hits-target? (list 0 0 vx vy) target))
                    (range (abs bottom-y) (- (abs bottom-y)))))
                    (if (= part? 1)
                        (if (= 0 (length possibles))
                            (find-particle target (+ 1 vx) upper-limit 1)
                            (car possibles))
                        (append
                            possibles
                            (find-particle target (+ 1 vx) upper-limit 2))))))))

(let (inputtext (in "input17.txt" (line)))
    (let (target (get-target inputtext))
        (let ((left-x right-x bottom-y top-y) target)
            # part 1
            (println
                (triangular
                    (find-particle target 1 right-x 1)))
            # part 2
            (println (length (find-particle target 1 right-x 2))))))

#(setq target (get-target (in "input17.txt" (line))))

(bye)
