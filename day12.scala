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

def count_paths_memo(
    connections: List[List[String]]
): ((String, String, Set[String], Boolean) => Long) = {
    val cache =
        collection.mutable.Map.empty[
            (String, String, Set[String], Boolean),
            Long
        ]
    def count_paths(
        start: String, end: String,
        visited: Set[String],
        lenient: Boolean
    ): Long =
        cache.getOrElseUpdate((start, end, visited, lenient),
                find_connections(connections, start)
                .filter(x =>
                    (x != "start") &&
                    ((!visited.contains(x)) || lenient))
                .map(x =>
                    if (x == end) {
                        1
                    } else {
                        count_paths(
                            x, end,
                            {
                                if (x(0).isLower) visited + x
                                else visited
                            },
                            lenient && (!visited.contains(x)))})
                .sum)
    (a: String, b: String, c: Set[String], d: Boolean) =>
        count_paths(a, b, c, d)
}

def main() = {
    val connections = Source.fromFile("input12.txt").getLines().map(
        _.split("-").toList
    ).toList
    val count_paths = count_paths_memo(connections)
    // part 1
    println(count_paths("start", "end", Set("start"), false))
    // part 2
    println(count_paths("start", "end", Set("start"), true))
}

main()

/*
It's been a while since I worked with immutable data. Scala was a pleasant way
to get back to this style of programming. The language apparently has tail-call
optimisation; my solution doesn't take advantage of this, so it might crash on
huge inputs. I might try to rewrite it later.
*/
