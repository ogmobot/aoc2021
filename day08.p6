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

sub tr_1478 ($word) {
    given $word.chars {
        when $_ == 2 { {1 => $word}; }
        when $_ == 3 { {7 => $word}; }
        when $_ == 4 { {4 => $word}; }
        when $_ == 7 { {8 => $word}; }
        default { %(); }
    }
}
sub tr_all (%map, @words) {
    my %newmap = @words.map(-> $word {
        given $word.chars {
            when $_ == 5 {
                if similar($word, %map{1}) == 2 {
                    {3 => $word};
                } elsif similar($word, %map{4}) == 3 {
                    {5 => $word};
                } else {
                    {2 => $word};
                }
            }
            when $_ == 6 {
                if similar($word, %map{1}) == 1 {
                    {6 => $word};
                } elsif similar($word, %map{4}) == 4 {
                    {9 => $word};
                } else {
                    {0 => $word};
                }
            }
            default { %(); }
        }
    }).reduce(&mapcombine);
    mapcombine(%map, %newmap);
}

sub getvals ($line) {
    my ($lhs, $rhs) = $line.split(" | ");
    my @digits = $lhs.split(" ").map({$_.split("").sort.join});
    my %table1478 = @digits.map(&tr_1478).reduce(&mapcombine);
    my %table = tr_all(%table1478, @digits);
    #$rhs.split(" ").map({%table.invert{$_.split("").sort.join}});
    $rhs.split(" ").map({%table.invert().Map{$_.split("").sort.join}});
}

my @values = "input08.txt".IO.lines.map({ getvals($_); }).map(*.List);
say @values.map({ $_.map({(1, 4, 7, 8).contains($_)}).sum }).sum;
say @values.map({ $_.join }).sum
