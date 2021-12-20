#!/usr/bin/ijconsole

deltas =: ,<@,"0/~i:1
NB. ORDER MATTERS

wrapborder =: {{
    size =. {.$y
    symb =. (2|x){'.#'
    ((size+2)#symb),((symb&,)@(,&symb)"1 y),(size+2)#symb
}}
NB. x=gen y=grid. Assumes that '#' = 0 { IEA and '.' = 1 { IEA

update_template =: {{
    gen  =: 0{::({:y)
    orig =: 1{::({:y)
    size =: {.$orig
    grid =: gen wrapborder orig
    coords =: <@,"0/~>:i.size
    neighbours =: grid {~ deltas +&.>/ coords
    y , (>:gen) ; (>:gen) wrapborder (|:(#.@('.#'i.])"1 |: neighbours) { x)
}}
NB. x=rules, y=world

countalive =: (+/^:_)@:('#'&=)

input  =: cutopen toJ 1!:1 < 'input20.txt'
IEA    =: > {. input
world  =: ,: (0 ; (0 wrapborder > }. input))
update =: IEA & update_template

NB. part 1
gen2  =. update^:2 world
echo countalive (1{::{:gen2)
NB. part 2
gen50 =. update^:50 world
echo countalive (1{::{:gen50)

exit''
