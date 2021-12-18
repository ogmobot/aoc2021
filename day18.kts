#!/snap/bin/kotlin
import java.io.File

fun parseTree(s: String): MutableList<Pair<Int, Int>> {
    //<value, depth>
    var result = mutableListOf<Pair<Int, Int>>()
    var nested = 0
    var index = 0
    while (index < s.length) {
        when (s[index]) {
            '['  -> nested++
            ']'  -> nested--
            ','  -> {}
            else -> {
                val numLen = s.substring(index).indexOfFirst({c -> !c.isDigit()})
                result.add(Pair(
                    s.substring(index, index + numLen).toInt(),
                    nested))
                index += numLen - 1
            }
        }
        index++
    }
    return result
}
fun maybeExplode(n: MutableList<Pair<Int, Int>>): Boolean {
    n.forEachIndexed { i, value ->
        if (i == n.size - 1) return false
        if (value.second == n[i + 1].second && value.second > 4) {
            if (i > 0)
                n.set(
                    i - 1,
                    Pair(n[i - 1].first + value.first, n[i - 1].second))
            if (i + 1 < n.size - 1)
                n.set(
                    i + 2,
                    Pair(n[i + 2].first + n[i + 1].first, n[i + 2].second))
            n.removeAt(i + 1)
            n.set(i, Pair(0, value.second - 1))
            return true
        }
    }
    return false
}

fun maybeSplit(n: MutableList<Pair<Int, Int>>): Boolean {
    n.forEachIndexed { i, value ->
        if (value.first >= 10) {
            n.add(
                i,
                Pair(value.first / 2, value.second + 1))
            n.set(
                i + 1,
                Pair((value.first / 2) + (value.first % 2), value.second + 1))
            return true
        }
    }
    return false
}

fun reduceSnailfish(n: MutableList<Pair<Int, Int>>): Boolean {
    // returns true if anything happened
    if (maybeExplode(n)) return true
    if (maybeSplit(n)) return true
    return false
}

fun addSnailfish(
        a: MutableList<Pair<Int, Int>>,
        b: MutableList<Pair<Int, Int>>
): MutableList<Pair<Int, Int>> {
    var result = (a.map { pair -> Pair(pair.first, pair.second + 1) }).toMutableList()
    result += (b.map { pair -> Pair(pair.first, pair.second + 1) }).toMutableList()
    while (reduceSnailfish(result)) {}
    return result
}

fun magnitude(n: MutableList<Pair<Int,Int>>): Int {
    if (n.size == 0) {
        return 0
    } else {
        return (3*n.first().first + 2*n.last().first)
    }
}

fun sf(n: MutableList<Pair<Int,Int>>): String {
    var result = ""
    var nested = 0
    var i = 0
    while (i < n.size) {
        if (nested < n[i].second) {
            result += "[ "
            nested++
            continue
        }
        if (nested > n[i].second) {
            result += "] "
            nested--
            continue
        }
        if (nested == n[i].second) {
            result += "${n[i].first.toString()} "
            i++
            continue
        }
    }
    while (nested > 0) {
        nested--;
        result += "] "
    }
    return result
}

fun main() {
    //val input = File("input18.txt").readLines().map { line: String -> parseTree(line) }
    val test_s = "[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]"
    var tmp = parseTree(test_s)
    println("${sf(tmp)}")
    println("$tmp")
    maybeExplode(tmp)
    println("${sf(tmp)}")
    println("$tmp")
    /*
    // part 1
    val result = input.reduce { a, b -> addSnailfish(a, b) }
    println("${magnitude(result)}")
    // part 2
    val maxSum = (input.map { a ->
        (input.map { b ->
            if (a == b) {
                0
            } else {
                magnitude(addSnailfish(a, b))
            }
        }).reduce { x, y -> if (x > y) x else y }
    }).reduce { x, y -> if ( x > y) x else y }
    println("${maxSum}")
    */
}

main()

// I found Kotlin annoying to write in, but I think a big part of that was due
// to my development environment (i.e. a slow compiler and having to spin up
// the JVM each test). Despite the compiler being very pedantic about possible
// nulls, it didn't seem to be very good at inferring any other types -- hence
// needing to specify readLines() returns Strings, and using reduce {max(a, b)}
// instead of MaxOrNull().
// I've now written programs in a few JVM languages: Java (day 4), Scala (day
// 12), Clojure (day 14) and Kotlin (day 18, today). (Technically, Raku can
// also compile to JVM bytecode.) My ranking:
// Scala > Clojure > Raku > Kotlin > Java
