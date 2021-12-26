Advent of Code 2021
===================
A few of my thoughts on the 25 languages I used this year. Before the event started, I wrote up a list of ~34 languages to try (and got them installed on my machine). Then, on each day of the event, I read the puzzle and chose a language to solve it in. Here are some of my thoughts on the languages I used and the solutions I wrote. At the end of each language, I've included a one-sentence summary and a piece of syntax or function I though was interesting.

Day 01: APL
-----------
It turns out there are a few different implementations of APL; I used GNU APL (which I later learned lacks some features of other variations). I had used J in the past (a close descendant of APL), so I knew the day 1 puzzle was exactly the kind of problem that APL is good at solving. The toughest part of writing the program was trying to find a way to type the symbols I needed (and how to search for them on Google). I ended up copying and pasting a lot of them from the wiki.

**APL**: Cool language, but I think I'll stick to ASCII.

**Syntax Highlight**: `⍎` (the "execute" primitive function; evaluates a string as APL code)

Day 02: Factor
--------------
This is a variant of Forth with a huge set of libraries included. (Even the most simple operations, like `+`, require `USING math ;`.) It's the first time I've written a program in a Forth-type language. In some ways it feels like composing functions together in a language with first-class functions, but instead of `((compose f g h) x)` it's `x h g f`, and the stack provides a way to store intermediate values between function calls.

The day 2 puzzle itself was pretty straightforward, although I've seen programs similar to mine which use complex numbers instead of arrays.

**Factor**: A nice introduction to stack-based languages. (GForth for 2022???)

**Syntax Highlight**: `( -- )` (function signature, showing what data the function removes or adds to the stack)

Day 03: FORTRAN
---------------
FORTRAN is the oldest language I used this year, and I was dreading to use it as a result. However, the language was actually pretty easy to write. So many languages are descended from FORTRAN that its imperative style felt pretty natural, especially in contrast to the more unfamiliar styles of APL and Factor. (I suspect it also helped that I was writing in FORTRAN 95, a version of the language with 38 years' worth of improvements to the original -- such as the ability to use `==` instead of `.EQ.` I was surprised to learn that I didn't need to download a FORTRAN compiler -- my system already had gfortran installed.

The puzzle itself was a little annoying but I managed to hack out an answer without too much trouble.

**FORTRAN**: You recognise its grandkids so well that you feel you've known it your whole life.

**Syntax Highlight**: `rewind(11)` (reset file position; I suspect older versions of FORTRAN literally rewound an input tape)

Day 04: Java
------------
The last time I wrote in Java was when I was completing an undergraduate course at university. My vague memory of the language was that it was overly verbose and very annoying to use. Coming back to it a decade later, some parts of the "Java way of doing things" caused the same annoyance -- for example, each source file necessarily contains a single class, which must share its name with that of the file -- but the language itself isn't so bad. I discovered that static classes could be embedded within other classes, which was the only way I could write an object-based solution to the problem without needing a second source file. I also had fun crafting variable names that were lengthy the the point of silliness.

**Java**: Annoying, verbose and arbitrarily restrictive; but it could be worse.

**Syntax Highlight**: `public static void main(String args[])` (for a Java program to run at all, the sole class contained within the program file must have this exact method defined; I find everything about this annoying)

Day 05: D
---------
D, aka Dlang, is the second language I used (after Java) that tries to be a better version of C. The language's "Uniform Function Call Syntax" can make function calls look like methods or properties, which can be nice so long as everything is named sensibly. Pushing elements to an array uses the `~=` operator, which I hadn't seen before. Nothing too offensive about this language, but nothing very special either.

**D**: A version of C that lets you pretend functions are methods.

**Syntax Highlight**: `.writeln` (could this be a method that every data type implements? No, it's a function from the `std.stdio` library)

Day 06: OCaml
-------------
The successor to ML and Caml, OCaml was a fun language to learn. Its syntax is pretty different to that of other languages I've used, particularly for function definition, locally scoped variables, composing functions, and pattern-matching.

My method of solving part 1 of this puzzle turned out to be the "optimised" version that allowed it to solve part 2 without any further changes. As a result, my rank for that day jumped from ~14000 to ~10000 between the two parts of the problem.

**OCaml**: Functional programming like never before.

**Syntax Highlight**: `|>` ("pipes" the result of one function into another)


