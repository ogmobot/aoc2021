#!/usr/bin/clojure
(require '[clojure.string :as str])

(defn dofreqsubs [fstable pairfreqs]
    (if (= 0 (count pairfreqs))
        {}
        (let [[pair amount] (first pairfreqs)]
            (merge-with +
                (apply merge (map #(hash-map % amount) (fstable pair)))
                (dofreqsubs fstable (rest pairfreqs))))))

(defn make-substable [lines]
    (if (> (count lines) 0)
        (merge
            (apply hash-map (str/split (first lines) #" -> "))
            (make-substable (rest lines)))
        nil))

(defn make-frequency-substable [substable]
    (if (= 0 (count substable))
        {}
        (let [[k v] (first substable)]
            (merge
                {(seq k)
                    (list
                        (list (first k) (first v))
                        (list (first v) (second k)))}
            (make-frequency-substable (rest substable))))))

(defn make-pair-frequencies [string]
    (frequencies (partition 2 1 string)))

(defn determine-freqs [pairfreqs lastchar]
    (if (= 0 (count pairfreqs))
        {lastchar 1}
        (merge-with +
            {(first (first (first pairfreqs))) (second (first pairfreqs))}
            (determine-freqs (rest pairfreqs) lastchar))))

(defn main []
    (let [file-contents (slurp "input14.txt")
          [initial-string _ & subs-list] (str/split file-contents #"\n")
          initial-freqs (make-pair-frequencies initial-string)
          substable (make-substable subs-list)
          fstable (make-frequency-substable substable)
          results (iterate (partial dofreqsubs fstable) initial-freqs)]
        ;; part 1
        (let [freqs (determine-freqs (nth results 10) (last initial-string))]
            (println (- (apply max (vals freqs)) (apply min (vals freqs)))))
        ;; part 2
        (let [freqs (determine-freqs (nth results 40) (last initial-string))]
            (println (- (apply max (vals freqs)) (apply min (vals freqs)))))))

(main)

;;; Clojure is one of the weirder LISPs I've used. Apparently it can't into
;;; tail call optimisation, so it introduces a `recur` keyword that interacts
;;; with `loop` in a way I'd describe as "the poor man's TCO". My original
;;; naive approach to this problem required enough recursion to overflow the
;;; stack, so I had to use it; but luckily I was able to purge it from the
;;; program once I had updated it for Part 2 of the problem.
;;; All that said, it was nice to have functions like `iterate` and
;;; `frequencies` out of the box (even if CAR and CDR are sadly absent).
;;; Anonymous functions are also far less verbose than those of most LISPs,
;;; as is accessing hashmaps.
