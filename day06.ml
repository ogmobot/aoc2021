#!/usr/bin/ocaml
let count x xs = List.fold_left
    (fun counter elt -> if (elt == x) then counter+1 else counter)
    0
    xs

let freqtable xs = List.map
    (fun value -> count value xs)
    [0;1;2;3;4;5;6;7;8]

let rec iterate f x n = match n with
      0 -> x
    | m -> iterate f (f x) (m-1)

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
]

let t = open_in "input06.txt"
    |> input_line
    |> String.split_on_char ','
    |> List.map int_of_string
    |> freqtable;;
let iters_1 = 80 and iters_2 = 256;;

let u = (iterate update t iters_1)
and v = (iterate update t iters_2) in
    Format.printf "%d\n%d\n"
        (List.fold_left (+) 0 u) (List.fold_left (+) 0 v);;

(*  The nearest touchstone to OCaml I'm familiar with is Haskell (at least in
    terms of syntax). I think pattern matching is one of the strengths of these
    two languages, so I'm glad I found a way to squeeze it into this solution.
    The `|>` operator is fun, too. Odd that I couldn't find an `iterate`
    function out of the box. (Maybe I wasn't looking hard enough...)
    I'm sure there's a neater way of writing the update table function. Perhaps
    I'll see if I can find a way to refactor it later.
*)
