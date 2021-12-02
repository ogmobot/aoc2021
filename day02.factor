! Run using fact (symlink to factor interpreter)
USING:
    kernel
    io io.files io.encodings.utf8
    splitting
    combinators
    sequences assocs
    math math.parser
    prettyprint multiline
;
IN: day02

: line>pair ( text -- pair ) ! maps e.g. "forward 5" to { 5 0 }
    " " split
    0 over nth
    H{
        { "forward" {  1  0 } }
        { "up"      {  0 -1 } }
        { "down"    {  0  1 } }
    } at
    ! ( words pair )
    1 rot nth string>number
    ! ( pair size )
    swap
    [ over * ] map
    nip
;

: change-state ( state text -- new-state )
    ! state is { horizonal vertical aim }
    " " split
    1 over nth string>number
    swap
    0 swap nth
    ! ( state size word )
    {
        { "forward" [
            over 2 swap nth
            ! ( state size aim )
            over *
            ! ( state dx dy )
            { 0 } swap prefix swap prefix
        ] }
        { "up" [
            { 0 0 -1 } [ over * ] map nip
        ] }
        { "down" [
            { 0 0 1 } [ over * ] map nip
        ] }
    } case
    ! ( state delta )
    [ + ] 2map
;

"input02.txt" utf8 file-contents "\n" split but-last
dup

! part 1 ( string-array -- )
[ line>pair ] map
{ 0 0 } [ [ + ] 2map ] reduce
1 [ * ] reduce .

! part 2 ( string-array -- )
{ 0 0 0 } [ change-state ] accumulate drop
but-last 1 [ * ] reduce .

![[
    I've never programmed in a stack-based language before -- it's certainly
    very different from anything else I've used in the past. A stateful
    solution using variables is probably what Eric intended, but a more
    functional approach seemed more idiomatic for Factor. (That said, the
    state-accumulation approach for part 2 is pretty close to using variables
    anyway!)
    I probably could have used similar approaches for both parts, but using
    different methods allows me to explore more of the language!
]]
