#!/usr/bin/rakudo

sub mapcombine (%a, %b) {
    %().append(%a).append(%b);
}

sub similar ($a, $b) {
    if $b {
        # $a.split("") contains two empty strings, so -2 is necessary
        $a.split("").map({$b.Str.split("").contains($_);}).sum - 2;
    }
}

sub tr_1478 (@words) {
    @words.map(-> $word {
        given $word.chars {
            when $_ == 2 {1 => $word};
            when $_ == 3 {7 => $word};
            when $_ == 4 {4 => $word};
            when $_ == 7 {8 => $word};
            default { %(); }
        }
    }).reduce(&mapcombine);
}

sub tr_all (%map, @words) {
    my %newmap = @words.map(-> $word {
        given $word.chars {
            when $_ == 5 {
                if similar($word, %map{1}) == 2 { {3 => $word}; }
                elsif similar($word, %map{4}) == 3 { {5 => $word}; }
                else { {2 => $word}; }
            }
            when $_ == 6 {
                if similar($word, %map{1}) == 1 { {6 => $word}; }
                elsif similar($word, %map{4}) == 4 { {9 => $word}; }
                else { {0 => $word}; }
            }
            default { %(); }
        }
    }).reduce(&mapcombine);
    mapcombine(%map, %newmap);
}

sub getvals ($line) {
    my ($lhs, $rhs) = $line.split(" | ");
    my @digits = $lhs.split(" ").map({$_.split("").sort.join});
    my %table = tr_all (tr_1478 @digits), @digits;
    $rhs.split(" ").map({%table.invert.Map{$_.split("").sort.join}});
}

my @values = "input08.txt".IO.lines.map(&getvals).map(*.List);
# part 1
say @values.map({ $_.map({(1, 4, 7, 8).contains($_)}).sum }).sum;
# part 2
say @values.map({ $_.join }).sum

#`(
Raku was a little tougher to get the hang of than I expected. The $ @ % & sigils
turned out to be a nice way helping to keep track of types, and the $_ meta-
variable was cool too. (I'm still not 100% clear on when parentheses are needed
vs. when they can be omitted.)
Today's puzzle could have been solved with a `for` loop, which Raku supports;
but the documentation strongly discourages their use, so the solution uses a
functional approach instead. I think the solution's still relatively neat, but I
suspect the time/space requirements are bigger than they need to be. That said,
if time and space efficiency is important for the program, you probably
shouldn't be using Raku.
)
