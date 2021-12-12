#!/usr/bin/scala
!#
import scala.io.Source

def find_connections(pairs: List[List[String]], a: String): List[String] = {
    if (pairs.isEmpty) {
        return List[String]()
    } else if (pairs.head(0) == a) {
        return pairs.head(1) +: find_connections(pairs.tail, a)
    } else if (pairs.head(1) == a) {
        return pairs.head(0) +: find_connections(pairs.tail, a)
    } else {
        return find_connections(pairs.tail, a)
    }
}

def count_paths(
    start: String,
    end: String,
    connections: List[List[String]],
    visited: List[String],
    lenient: Boolean
): Long = {
    find_connections(connections, start)
    .filter(
        x => (!visited.contains(x)) || (lenient && visited.count(_ == x) == 1))
    .map(
        x => {
            if (x == end) {
                1
            } else {
                count_paths(
                    x, end,
                    connections,
                    (start +: visited).filter(xx => xx.exists(_.isLower)),
                    lenient && (!visited.contains(x)))}})
    .sum
}

def main() = {
    val connections = Source.fromFile("input12.txt").getLines().map(
        _.split("-").toList
    ).toList
    val part1 = count_paths("start", "end", connections, List[String](), false)
    val part2 = count_paths("start", "end", connections, "start" :: Nil, true)
    println(s"$part1\n$part2")
}

main()
