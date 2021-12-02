! Run using fact (symlink to factor interpreter)
USING:
    kernel
    io io.files io.encodings.utf8
    splitting
    combinators
    sequences assocs
    math math.parser
    prettyprint
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
