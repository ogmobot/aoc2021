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

Day 13: Haskell
---------------
I've written a little bit of Haskell in the past, but I forgot how pedantic the compiler is. I suspect the syntax was originally inspired by ML-like languages, given it shares some similarities with OCaml. Technically, writing a signature for every function wasn't necessary, but it helped me to keep track of what each function was doing. The hardest part of writing this program was taking the results of the *nasty, impure* input routines and feeding them into my *shining, pure* functions. I got there in the end, but it was a bit of a struggle. Haskell's lazy evaluation also meant I couldn't really test the functions until I got output working, but the type system helped to pre-emptively squash bugs.

**Haskell**: Pure functional programming (with, *sigh*, a bridge to the impure real world included).

**Syntax Highlight**: `f :: a -> a -> a` (function signatures with arbitrary types, currying by default)

Day 14: Clojure
---------------
The first LISP I used for the event. Clojure is a dialect of LISP with some syntax choices that differentiate it from more traditional LISPs -- stuff like `[]` for vectors, `{}` for hash tables, and `#(%)` for anonymous functions and arguments. I discovered it came witha  lot of handy functions right out of the box, like `merge-with`, `frequencies` and `partition`. Apparently tail-call optimisation isn't possible for Clojure, but it uses a tail-call-like combination of `loop` and `recur` to achieve a similar effect. I'm not sure I'd use Clojure over Common Lisp, but I wouldn't hesitate to recommend it to, say, someone working with the JVM and looking to branch out.

**Clojure**: A batteries-included LISP for the JVM.

**Syntax Highlight**: `recur` (a band-aid for the language's lack of tail-call optimisation)

Day 15: Elixir
--------------
Elixir is apparently built on top of BEAM, the virtual machine for Erlang (which I've never used). Using modules to encapsulate different functions and variables is a neat idea, which I'd probably appreciate even more if I ever wrote something that needed them. We see the return the `|>` operator previously seen in OCaml, and I really liked the destructuring bind within function arguments (as seen in e.g. `def neighbours({x, y}, size)`).

**Elixir**: Probably a good option for concurrency.

**Syntax Highlight**: `defmodule` (modules group functions together)

Day 16: C
---------
Good old C. Given the input required parsing bits at a time, this seemed like an appropriate language to use. The problem itself practically demanded I used the fixed-width integer types of `<stdint.h>`, but I'd like to be in the habit of always using them anyway.

This problem is basically parsing and evaluating a compressed abstract syntax tree. Given LISPs deal entirely with ASTs, I thought it fitting to add a function that would emit a LISP program that evaluates the tree. Perhaps one day I'll re-implement this program in a LISP so I can call `eval` directly...

**C**: The *lingua franca* of programming languages (and hella fast).

**Syntax Highlight**: `void *` (a memory location not associated with a type -- use with extreme care)

Day 17: PicoLisp
----------------
The second LISP I used for the event. This is a very minimalist implementation of LISP. It's so minimal it doesn't check whether symbols are valid function names (if not, segfault) it doesn't check whether a function's been passed enough arguments (default value is NIL), and it doesn't support arrays or floating-point numbers (really!). Other than that, the language is a pretty decent, standard LISP. One unusual feature is using `quote` instead of `lambda`; so where Common Lisp would have `(mapcar (lambda (x) (f x)) xs)`, PicoLisp instead has `(mapcar '((x) (f x)) xs)`. Doesn't really feel very different to write, but it saves some space.

I used a fair bit of Maths on this problem to get a solution that runs fast. The lack of floating-point numbers (and my refusal to get fixpoint numbers working) made it a bit tough.

**PicoLisp**: A LISP in one megabyte or less.

**Syntax Highlight**: `NIL` (PicoLisp is case-sensitive, so `NIL`, a special, false-y value, is not the same as `nil`, an ordinary, truth-y value; this tripped me up a few times)

Day 18: Kotlin
--------------
I wanted to like Kotlin, but I didn't enjoy it as much as I thought I would. Maybe it was the difficult problem I was trying to solve, or the slow compiler, or just rolling my own object class. There's nothing wrong with the language, *per se*; the syntax is familiar, it has static typing etc.; but its insistence on type safety made the slow process of solving the problem slower than I would have liked.

I know there's probably a nice way of finding the next left-or-right leaf given a specific leaf node, but I found it easier to just walk the tree and store the leaves in an array. It means the operation is O(n) instead of O(log n) but that wasn't a problem for an input this size.

**Kotlin**: A Python-wannabe for the JVM.

**Syntax Highlight**: `?:` (the "Elvis" operator [look at it sideways] -- the right operand provides a default value for when the left operand is null)

Day 19: Nim
-----------
Nim's syntax feels very Python-esque, which I'm sure was an intentional decision. I like the distinction the language makes between (pure) `func`tions and `proc`edures, and of course the language, being both typed and compiled, tends to produce much faster programs than Python. Would I use it instead of Python? Well... maybe. Right now, Python interpreters are much more widespread than Nim compilers. I'm also a little leery of Nim ignoring underscores and capitalisation in symbol names. Still, I like the language, and I imagine it'd be very easy for a Python programmer to learn.

My method for solving the day 19 problem is dumb brute force -- I doubt I would have got away with this so easily if I had used an interpreted language. It might be possible to get a big speedup by computing the vectors or triangles associated with each point cloud, and matching those under rotation, instead of simply trying to match every possible pair of points.

**Nim**: Python but fast.

**Syntax Highlight**: `a_Bc` (symbol names ignore underscores, capitalisation and whitespace [yes, you can write symbol names that contain whitespace])

Day 20: J
---------
Despite the relative brevity of this program, it's very verbose for the standards of J. I've seen another J program which solves this problem in about 6 lines; my program is a few times bigger than that. There are, no doubt, a tonne of built-in words I could have used instead of defining my own. I also kept track of all states of the universe instead of just one -- I could probably shorten my code and runtime simultaneously by changing that.

Apparently a lot of the people solving this problem initially got tripped up by the fact that rules[0] == 1 and rules[511] == 0, but this was literally the first thing I checked after getting the input. (In fact, my program assumes this will be the case and won't correcty run the example input).

**J**: APL for people with normal keyboards.

**Syntax Highlight**: `^:` (applies a function *n* times; or determines and applies the inverse function, if *n* is negative; or finds a fixed point of the function, if *n* is infinity!)

Day 21: Guile Scheme
--------------------
The third LISP I used for the event. In retrospect it might have been better to use something else; it feels almost sacreligious to be constantly mutating state in LISP. There's probably a nice way to get a functional solution to the problem, but I didn't look for one very hard. I figured you don't get very many opportunities to use four-dimensional arrays in Advent of Code, so that's what I used to get my solution. In looking through my solution to this problem, I've discovered this was the one language I forgot to write comments about in the program file itself. This is fine; it seems like a pretty standard LISP.

**Guile Scheme**: It's just LISP.

**Syntax Highlight**: `set!` (functions that mutate state conventionally end with `!` to warn you)

Day 22: Crystal
---------------
Perhaps ironically, I'm currently more familiar with Crystal than with Ruby. The syntax (and lack of parentheses) is nice, albeit a little confusing sometimes. I was unreasonably pleased to discover integers have a `.succ` method, meaning I could replace `.map { |x| -> x.zrange.end + 1 }` with a mere `.map &.zrange.end.succ`. I'm pretty sure Ruby's syntax was the first to use `|` to name locally-scoped variables in `for` loops and the like, so that's a nice feature.

The line-sweep (plane-sweep?) algorithm to solve this problem was one I had heard of before, but not implemented. I suspect there's a way to combine my `lengthsweep` and `areasweep` functions into one, so that not as much code is duplicated. (Also, I originally wrote a dumb solution for part 1 which was just "dump everything into a hash map", knowing full well I'd have to implement a real solution to part 2 anyway.)

**Crystal**: Ruby but fast.

**Syntax Highlight**: `|x|` (names the variable used in a block, as in `(0..10).each do |val| ... end`)

Day 23: Zig
-----------
One last "better version of C" language. Writing in Zig definitely feels a lot like writing in C, except it's a lot better at memory safety (while also not being super pedantic about it). It has a big standard library, optional types, bounds-checked arrays, and the compiler literally has a C compiler built in. If you wanted to write a program which needed to inter-operate with a lot of C source files or objects, Zig would probably be a good choice of language. That said, the language is still a work-in-progress; the last time I wrote in Zig, I was using version 0.7.0; but since then, I've updated to 0.9.0, and a few things have changed. (I'm still writing to stderr instead of stdout, though...) One of my favourite features is the syntax for assigning values to structs.

**Zig**: A version of C with optional types.

**Syntax Highlight**: `.{}` (an empty struct that matches the type of the variable you're assigning it to)

Day 24: Hy
----------
One last LISP language. Wait a second, this doesn't feel like LISP! Isn't this... Python?

Hy shares a more syntax with Clojure than with other LISPs I've used (square brackets for function args, curly braces for hash maps), and of course it has the parentheses and quotes that LISP is so well known for. But it really doesn't feel like LISP! Perhaps it's the use of dot methods and functions that I'm so used to (just in a different order -- `(.append xs x)` instead of `xs.append(x)`), or maybe I know at some level that the whole thing's running on top of CPython, but it really does *feel* like writing Python.

When analysing this problem myself, I uncovered a lot of clues leading towards a solution: the fourteen chunks of assembly, seven of one type and seven of another; division, multiplication and modulo all of 26; the fact that the `z` register represented and stored the assembly program's internal state; but I couldn't work out how it was all connected. I wrote a program to represent the states of all registers as S-expressions, but they got hopelessly complicated after a few hundred steps. (That said, a LISP seems like the perfect kind of language to try this with.)

Finally, I took a peek for hints online and saw someone mention a stack, and then it all fell into place. I solved the problem relatively quickly afterwards, by writing a quick-and-dirty program that ran the assembly and printed the operands of every comparison to a non-zero number (since these were the only pairs of numbers that needed to match to get the solution). After a bit of trial and error, and manually changing trial digits in the source code of the program, I found the puzzle's solution.

Since then, I've been trying to get the first version of the program to solve the problem with S-expressions. (I haven't succeeded yet, at time of writing, but I'm close!) The comments of that version of the program show how to solve the problem analytically given the S-expressions emitted by the program. Hopefully one day I'll automate the process.

**Hy**: I can't believe it's not Python!

**Syntax Highlight**: `hy.eval` (Python already has a native `eval` function -- which Hy has access to! -- so the function that evaluates an S-expression needs a slightly different name)

Day 25: TypeScript
------------------
I'm not convinced that TypeScript is a real language. It's more like a type-checking system -- an *optional* type-checking system, at that! -- for JavaScript programs. Ah well.

The ecosystem required to set up TypeScript took a bit of fiddling to get right, and "compiling" the TypeScript to JavaScript (actually just stripping type annotations) is rather slow; but the language itself is pretty inoffensive. For this problem, I represented the input as an array of strings, where I probably could have used a 2-dimensional array of strings or a single string; but hey, it worked in the end.

I can see why returning `null` or `undefined` or `Infinity` or whatever would be useful when running JavaScript in a user's browser and you don't want everything to blow up, but it makes it kind of annoying to track down errors in the program itself.

**TypeScript**: It's a typechecking system for JavaScript that takes more than 5 seconds to check less than 50 lines of code (well done, Microsoft).

**Syntax Highlight**: `===` (checks whether two values are *actually* equal -- because JavaScript's default equality operator, `==`, silently and implicitly coerces its arguments to have the same type)
