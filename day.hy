#!/home/ogmobot/.local/bin/hy -B

(setv inputfile (open "input.txt"))

(.readline inputfile) ;; discard first line

(print
    (reduce *
        (map
            (fn [line]
                (reduce + (map int (.split line ","))))
            inputfile)))
