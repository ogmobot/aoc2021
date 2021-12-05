! Run using fact (symlink to factor interpreter)
USING:
    arrays
    combinators
    kernel
    io io.files io.encodings.utf8
    math math.parser
    prettyprint multiline
    splitting
    sequences assocs
;
IN: day02

: word>delta ( text -- array )
    H{
        { "forward" {  1  0 } }
        { "up"      {  0 -1 } }
        { "down"    {  0  1 } }
    } at ;

: line>pair ( text -- pair ) ! maps e.g. "forward 5" to { 5 0 }
    " " split
    0 over nth word>delta
    1 rot nth string>number
    ! ( pair size )
    [ * ] curry map
;

: sizeword>delta ( state size word -- state delta )
    {
        { "forward" [
            over 2 swap nth
            ! ( state size aim )
            over *
            ! ( state dx dy )
            0 3array
        ] }
        { "up" [
            { 0 0 -1 } swap [ * ] curry map
        ] }
        { "down" [
            { 0 0 1 } swap [ * ] curry map
        ] }
    } case ;

: change-state ( state text -- state' )
    ! state is { horizonal vertical aim }
    " " split
    1 over nth string>number
    swap
    0 swap nth
    ! ( state size word )
    sizeword>delta
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
    different methods allows me to explore more of the language ;)
]]
