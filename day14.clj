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
                {(list (first k) (second k))
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
