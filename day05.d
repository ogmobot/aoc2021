import std.algorithm.iteration;
import std.algorithm.comparison;
import std.array;
import std.conv;
import std.regex;
import std.range;
import std.stdio;

const auto MAXVAL = 1000;

struct Segment {
    int x1, y1, x2, y2;
}

Segment parse_segm (string line) {
    Segment result;
    const auto re = regex(`(\d+),(\d+) -> (\d+),(\d+)`);
    auto words = line.matchAll(re);
    result.x1 = to!int(words.front[1]);
    result.y1 = to!int(words.front[2]);
    result.x2 = to!int(words.front[3]);
    result.y2 = to!int(words.front[4]);
    return result;
}

int[MAXVAL][MAXVAL] map_segms (Segment[] segms) {
    int[MAXVAL][MAXVAL] result;
    foreach (segm; segms) {
        if (segm.x1 == segm.x2) {           //vertical line
            foreach (y; iota(min(segm.y1, segm.y2), max(segm.y1, segm.y2) + 1)) {
                result[segm.x1][y] += 1;
            }
        } else if (segm.y1 == segm.y2) {    //horizontal line
            foreach (x; iota(min(segm.x1, segm.x2), max(segm.x1, segm.x2) + 1)) {
                result[x][segm.y1] += 1;
            }
        } else {                            //diagonal line
            int dx = (segm.x1 < segm.x2) ? 1 : -1;
            int dy = (segm.y1 < segm.y2) ? 1 : -1;
            foreach (t; iota(1 + max(segm.x1, segm.x2) - min(segm.x1, segm.x2))) {
                result[segm.x1 + (t * dx)][segm.y1 + (t * dy)] += 1;
            }
        }
    }
    return result;
}

void main() {
    File inputfile = File("input05.txt", "r");

    Segment[] segms;
    while (auto line = inputfile.readln()) {
        segms ~= parse_segm(line);
    }
    inputfile.close();
    // part 1
    auto p1segms = segms.filter!(segm =>
        (segm.x1 == segm.x2) || (segm.y1 == segm.y2));
    int[MAXVAL][MAXVAL] p1universe = map_segms(p1segms.array);
    int total = 0;
    foreach (x; MAXVAL.iota) {
        foreach (y; MAXVAL.iota) {
            if (p1universe[x][y] > 1) {
                total += 1;
            }
        }
    }
    total.writeln;
    // part 2
    int[MAXVAL][MAXVAL] p2universe = map_segms(segms);
    total = 0;
    foreach (x; MAXVAL.iota) {
        foreach (y; MAXVAL.iota) {
            if (p2universe[x][y] > 1) {
                total += 1;
            }
        }
    }
    total.writeln;
}
// 953014 too high
