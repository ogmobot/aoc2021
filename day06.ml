let count x xs = List.fold_left
    (fun counter elt -> if (elt == x) then counter+1 else counter)
    0
    xs
;;

let freqtable xs = List.map
    (fun value -> count value xs)
    [0;1;2;3;4;5;6;7;8]
;;

let rec iterate f x n = match n with
      0 -> x
    | m -> iterate f (f x) (m-1)
;;

let update table = [
    List.nth table 1;
    List.nth table 2;
    List.nth table 3;
    List.nth table 4;
    List.nth table 5;
    List.nth table 6;
    (List.nth table 7) + (List.nth table 0);
    List.nth table 8;
    List.nth table 0;
];;

(* let inputstring = "3,4,3,1,2";; *)
let inputstring = input_line (open_in "input06.txt");;
let vals = List.map int_of_string (String.split_on_char ',' inputstring);;
let t = freqtable vals;;
let iters_1 = 80;;
let iters_2 = 256;;

let u = (iterate update t iters_1)
and v = (iterate update t iters_2) in
    Format.printf "Part 1: %d\nPart 2: %d\n"
        (List.fold_left (+) 0 u)
        (List.fold_left (+) 0 v);;
