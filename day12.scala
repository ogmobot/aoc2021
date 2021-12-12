#!/usr/bin/scala
!#
import scala.io.Source

def find_connections(pairs: List[List[String]], a: String): List[String] =
    pairs match {
    case Nil                    => Nil
    case p :: tail if p(0) == a => p(1) :: find_connections(tail, a)
    case p :: tail if p(1) == a => p(0) :: find_connections(tail, a)
    case p :: tail              =>         find_connections(tail, a)
    }

def count_paths(
    start: String, end: String,
    connections: List[List[String]],
    visited: List[String],
    lenient: Boolean
): Long =
    find_connections(connections, start)
    .filter(x => (!visited.contains(x)) || lenient)
    .map(x =>
        if (x == end) {
            1
        } else {
            count_paths(
                x, end,
                connections,
                (start :: visited).filter(_(0).isLower),
                lenient && (!visited.contains(x)))})
    .sum

def main() = {
    val connections = Source.fromFile("input12.txt").getLines().map(
        _.split("-").toList
    ).toList
    // part 1
    println(count_paths("start", "end", connections, List[String](), false))
    // part 2
    println(count_paths("start", "end", connections, List("start"), true))
}

main()

/*
It's been a while since I worked with immutable data. Scala was a pleasant way
to get back to this style of programming. The language apparently has tail-call
optimisation; my solution doesn't take advantage of this, so it might crash on
huge inputs. I might try to rewrite it later.
*/
