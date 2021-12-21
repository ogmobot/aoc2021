#!/usr/bin/guile
;!#
(use-modules (ice-9 textual-ports))
(use-modules (ice-9 format))

(define (iterate-apply f args n)
    (if (= n 0) args
        (iterate-apply f (apply f args) (- n 1))))

;;; part 1 (single universe)

(define (make-die)
    (define internal-counter 0)
    (lambda ()
        (set! internal-counter (+ internal-counter 1))
        (+ (remainder (- internal-counter 1) 100) 1)))

(define (player-step turn-number p die)
    (let* ((die-result (+ (die) (die) (die))) ;; it's German for "the the the"
           (position (remainder (+ (car p) die-result) 10)))
        (cons
            position
            (+ (cdr p) position 1))))

(define (game-step turn-number die player-1 player-2)
    ;; each player is a cons pair (position . score).
    (let ((current-player-index (remainder turn-number 2)))
        (list
            (+ 1 turn-number)
            die
            ; player 1
            (if (= 0 current-player-index)
                (player-step turn-number player-1 die)
                player-1)
            ; player 2
            (if (= 1 current-player-index)
                (player-step turn-number player-2 die)
                player-2))))

(define (game-until-winner turn-number die player-1 player-2)
    (if (or (>= (cdr player-1) 1000) (>= (cdr player-2) 1000))
        (list turn-number die player-1 player-2)
        (apply game-until-winner (game-step turn-number die player-1 player-2))))

(define (puzzle-result turn-number die player-1 player-2)
    (* 3 turn-number (min (cdr player-1) (cdr player-2))))

;;; part 2 (multiverse)

;; the state of the game, "multiverse", is a 4-dimensional array (10x10x21x21):
;;  - p1's position (number of multiverses)
;;  - p2's position (number of multiverses)
;;  - p1's score
;;  - p2's score
;; When a universe would advance to a score above 21, it becomes a win instead.
;; The die is rolled *three times* per turn.

(define (multi-player-step turn-number multiverse orig-p1wins orig-p2wins)
    (let ((current-player-index (remainder turn-number 2))
          (result (make-array 0 10 10 21 21))
          (p1wins orig-p1wins) (p2wins orig-p2wins))
        (for-each (lambda (pos1)
            (for-each (lambda (pos2)
                (for-each (lambda (score1)
                    (for-each (lambda (score2)
                        (for-each (lambda (die-roll f)
                            (if (= 0 current-player-index)
                                ; player 1 (1st and 3rd dims)
                                (let* ((new-pos (remainder (+ pos1 die-roll) 10))
                                       (new-score (+ score1 new-pos 1)))
                                    (if (>= new-score 21)
                                        (set! p1wins (+ p1wins
                                            (* f (array-ref multiverse
                                                pos1 pos2 score1 score2))))
                                        (array-set!
                                            result
                                            (+
                                                (array-ref result
                                                    new-pos pos2 new-score score2)
                                                (* f (array-ref multiverse
                                                    pos1 pos2 score1 score2)))
                                            new-pos pos2 new-score score2)))
                                ; player 2 (2nd and 4th dims)
                                (let* ((new-pos (remainder (+ pos2 die-roll) 10))
                                       (new-score (+ score2 new-pos 1)))
                                    (if (>= new-score 21)
                                        (set! p2wins (+ p2wins
                                            (* f (array-ref multiverse
                                                pos1 pos2 score1 score2))))
                                        (array-set!
                                            result
                                            (+
                                                (array-ref result
                                                    pos1 new-pos score1 new-score)
                                                (* f (array-ref multiverse
                                                    pos1 pos2 score1 score2)))
                                            pos1 new-pos score1 new-score)))))
                            '(3 4 5 6 7 8 9)
                            '(1 3 6 7 6 3 1)))
                        '(0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20)))
                    '(0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20)))
                '(0 1 2 3 4 5 6 7 8 9)))
            '(0 1 2 3 4 5 6 7 8 9))
        (list (+ 1 turn-number) result p1wins p2wins)))

(define (multi-game-over? multiverse)
    (let ((result #t))
        (array-for-each
            (lambda (x) (if (> x 0) (set! result #f)))
            multiverse)
        result))

(define (multi-game-all turn-number multiverse p1wins p2wins)
    (if (multi-game-over? multiverse)
        (max p1wins p2wins)
        (apply multi-game-all
            (multi-player-step turn-number multiverse p1wins p2wins))))
        

;;; main function

(let* ((input-file (call-with-input-file "input21.txt" get-string-all))
       (input-nums (map
            (lambda (s) (string->number s))
            (string-tokenize input-file char-set:digit)))
       (p1start (cadr input-nums))
       (p2start (cadddr input-nums)))
    ;; part 1
    (let* ((player-1 (cons (- p1start 1) 0))
           (player-2 (cons (- p2start 1) 0))
           (die (make-die))
           (state (list 0 die player-1 player-2)))
        (let ((final-state (apply game-until-winner state)))
            ;(format #t "~a~%" final-state)
            (format #t "~a~%" (apply puzzle-result final-state))))
    ;; part 2
    (let ((multiverse (make-array 0 10 10 21 21))
          (player-1 (- p1start 1))
          (player-2 (- p2start 1)))
        ;; arrays are passed by reference
        ;; (is it sacreligious to write stateful programes in scheme?)
        (array-set! multiverse 1 player-1 player-2 0 0)
        (let ((result (multi-game-all 0 multiverse 0 0)))
            (format #t "~a~%" result))))
