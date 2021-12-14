#!/usr/bin/clojure
(require '[clojure.string :as str])

(defn dofreqsubs [fstable pairfreqs]
    (loop [pairs (keys pairfreqs)
           acc {}]
        (if (= 0 (count pairs))
            acc
            (recur
                (rest pairs)
                (let [pair (first pairs)
                    amount (pairfreqs pair)]
                    (merge-with + acc
                        (apply merge
                            (map #(hash-map % amount) (fstable pair)))))))))

(defn make-substable [lines]
    (if (> (count lines) 0)
        (merge
            (apply hash-map (str/split (first lines) #" -> "))
            (make-substable (rest lines)))
        nil))


(defn make-frequency-substable [substable]
    (let [sub-keys (keys substable)]
        (loop [index 0
               acc {}]
            (if (= index (count sub-keys))
                acc
                (recur
                    (inc index)
                    (let [k (nth sub-keys index)
                          v (substable k)]
                        (merge acc
                            {(list (first k) (second k))
                                (list
                                    (list (first k) (first v))
                                    (list (first v) (second k)))})))))))

(defn make-pair-frequencies [string]
    (frequencies (partition 2 1 string)))

(defn determine-freqs [pairfreqs lastchar]
    (loop [pairfreqs pairfreqs
           acc {}]
        (if (= 0 (count pairfreqs))
            (merge-with + acc {lastchar 1})
            (recur
                (rest pairfreqs)
                (merge-with + acc
                    {(first (first (first pairfreqs)))
                     (second (first pairfreqs))})))))

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
