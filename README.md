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

**Syntax Highlight**: `( ... -- ... )` (a function's stack signature, showing what data it adds to or removes from the stack)

Day 03: FORTRAN
---------------
FORTRAN is the oldest language I used this year, and I was dreading to use it as a result. However, the language was actually pretty easy to write. So many languages are descended from FORTRAN that its imperative style felt pretty natural, especially in contrast to the more unfamiliar styles of APL and Factor. (I suspect it also helped that I was writing in FORTRAN 95, a version of the language with 38 years' worth of improvements to the original -- such as the ability to use `==` instead of `.EQ.` I was surprised to learn that I didn't need to download a FORTRAN compiler -- my system already had gfortran installed.

The puzzle itself was a little annoying but I managed to hack out an answer without too much trouble.

**FORTRAN**: You recognise its grandkids so well that you feel you've known it your whole life.

**Syntax Highlight**: `rewind(...)` (reset file position; I suspect older versions of FORTRAN literally rewound an input tape)

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

Day 07: Rust
------------
Another "better version of C" language. I feel like my solution to this problem is not the way that Rust was designed to be written! Perhaps this style of program (i.e. composition of many methods) is the result of having learned OCaml the day before. Still, it seems like a pretty neat solution to me, all things considered. The importance that Rust places on memory safety and correctness means that many methods produce results with an error union type (i.e. either a value of that type, or `null`) -- you have to call `.unwrap()` to extract the actual value you want.

I've seen it pointed out that the solution to part 1 is guaranteed to be within one unit of the median of the given numbers, and the solution to part 2 is guaranteed to be within one unit of their arithmetic mean. (I've also read rumours that the input is a valid Intcode program...)

**Rust**: A version of C with methods and memory safety.

**Syntax Highlight**: `.unwrap()` (call this on the result of a method to get the value it returned)

Day 08: Raku
------------
Aka Perl 6. One of the most distinctive features of Raku (and Perl) is the sigils preceding each variable; `$` for a single value, `@` for an array, `%` for a map, `&` for, uh, a subroutine? While the sigils make it easier to track the types of each variable, they certainly make the language look confusing from a distance. The language has C-like syntax and is pretty straightforward to write in. I can see how Perl got to be such a popular language for scripting.

This puzzle was a nice one. I figured out how the segments for each digit related to each other on the train home from work.

**Raku**: A scripting language for when your `$@%&` keys aren't getting enough use.

**Syntax Highlight**: `$_` (the argument passed to an anonymous function -- an anonymous argument?)

Day 09: Go
----------
Aka Golang. The fourth "better version of C" language I used. I didn't like this language as much as I thought I would. Unlike a lot of the other C-like languages, Go doesn't introduce function methods as a way of modifying data. Hence, we have `xs = append(xs, x)` instead of `xs.append(x)`, and we have `strings.Trim(line, "\n")` instead of line.trim("\n"). The one feature I found was pretty interesting was the idea of channels, which allow coroutines to communicate with each other (or "goroutines", as the language prefers to call them). If I had to write a program with lots of parallel parts, I don't think Go would be the worst choice. That said, I also don't think it would be my first choice.

**Go**: A version of C with support for parallelism.

**Syntax Highlight**: `<-` (write to a channel with `ch <- data` or read from a channel with `data = (<- ch)`)

Day 10: C++
-----------
The fifth "better version of C" language I used. Its standard libraries have so many different types! My solution used `std::map`, `std::vector`, `std::stack`, `std::string` and `std::ifstream`, to say nothing of the constants and functions included in the libraries. C programs are, in theory, compatible with C++; but I discovered while writing this program that the languages have diverged at least a little bit. The values defined within an `enum` can be used without qualifiers in C, but require namespace identifiers in C++.

C++ is supposedly such a big language that most good C++ programmers use only a tiny fraction of the language. I suspect that just knowing what functions are in the standard library, and how to use them, would make it possible to hack together complex programs very quickly.

**C++**: A version of C with objects, templates, and a huge standard library.

**Syntax Highlight**: `std::endl` (the standard library is so extensive it includes a standard end-of-line character)

Day 11: Julia
-------------
Julia's syntax reminds me of the syntax of Lua and other scripting languages, but it tends to run much faster than those. Apparently it has a keyword to call subroutines from C or FORTRAN shared libraries, which makes sense if its primary goal is numerical processing. I've read that there are some issues with the language implementation (and perhaps some of the language's community), but luckily I didn't encounter any in my solution.

I used a one-dimensional array to represent two-dimensional data in this problem, and probably should have taken the time to learn Julia's syntax for multidimensional arrays.

**Julia**: For when you need FORTRAN but you'd rather write Python.

**Syntax Highlight**: `@time` (annotates a function call and measures how long the call takes)

Day 12: Scala
-------------
I was surprised at how much I enjoyed writing Scala. In some ways it feels a bit like OCaml (immutable data, pattern matching). It seems to have taken a lot of good ideas from other langauges and put them together; we have anonymous functions and variables, advanced pattern-matching, method composition (which I admittedly went a bit overboard on), tail-call optimisation and static typing. I'd like to use this language more in the future.

**Scala**: A collage of good ideas.

**Syntax Highlight**: `def f() = ...` (defining a function has the same syntax as assigning a variable)


