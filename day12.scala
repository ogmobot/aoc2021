#!/usr/bin/scala
!#
import scala.io.Source

for (line <- Source.fromFile("input.txt").getLines()) {
    println(line)
}
