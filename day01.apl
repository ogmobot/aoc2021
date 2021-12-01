#!/usr/local/bin/apl --script

input ← ⍎⎕FIO[49]'input01.txt'

⍝ part 1
+/2<⌿input
⍝ part 2
+/2<⌿3+⌿input

)off

⍝ APL obviously feels a lot like J, except I don't recognise its glyphs.
⍝ A lot of the online guides focus on Dyalog APL, instead of GNU APL.
⍝ Luckily, enough of the glyphs match that I was able to cobble together
⍝ solutions to parts 1 and 2 (with 5 and 8 characters, respectively!).
