#!/usr/bin/clojure
(require '[clojure.string :as str])

(defn dosubs [substable string]
    ;; naive approach
    (loop [index 0
           acc ""]
        (if (= (inc index) (count string))
            (str acc (get string index))
            (recur
                (inc index)
                (str
                    acc
                    (get string index)
                    (substable (subs string index (+ index 2))))))))

(defn dofreqsubs [fstable pairfreqs]
    ;; scalable approach
    (loop [pairs (keys pairfreqs)
           acc {}]
        (if (= 0 (count pairs))
            acc
            (recur
                (rest pairs)
                (let [pair (first pairs)
                    amount (pairfreqs pair)]
                    (merge-with + acc
                        (apply merge (map #(hash-map % amount) (fstable pair)))))))))

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
                                ;; Note -- this assumes nothing like
                                ;; XX -> X
                                ;; occurs in the input.
                                (list
                                    (list (first k) (first v))
                                    (list (first v) (second k)))})))))))

(defn make-pair-frequencies [string]
    (frequencies (partition 2 1 string)))

(defn determine-freqs [pairfreqs lastchar]
    ;; e.g. (A B A B) => {(A B) 2, (B A) 1} => first letters 2*A 1*B + lastchar
    (loop [pairfreqs pairfreqs
           acc {}]
        (if (= 0 (count pairfreqs))
            (merge-with + acc {lastchar 1})
            (recur
                (rest pairfreqs)
                (merge-with + acc
                    {(first (first (first pairfreqs))) (second (first pairfreqs))})))))

(defn main []
    (let [file-contents (slurp "input14.txt")
          [initial-string _ & subs-list] (str/split file-contents #"\n")
          substable (make-substable subs-list)]
        ;; part 1
        (let [result-string (->
                        (iterate (partial dosubs substable) initial-string)
                        (nth 10))
              freqs (frequencies result-string)]
            (println (- (apply max (vals freqs)) (apply min (vals freqs)))))
        ;; part 2
        (let [initial-freqs (make-pair-frequencies initial-string)
              fstable (make-frequency-substable substable)
              result-table (->
                        (iterate (partial dofreqsubs fstable) initial-freqs)
                        (nth 40))
              freqs (determine-freqs result-table (last initial-string))]
            (println (- (apply max (vals freqs)) (apply min (vals freqs)))))))

(main)
