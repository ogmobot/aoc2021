#!/usr/bin/python3
from functools import reduce
from operator import mul

with open("input.txt", "r") as inputfile:
    inputfile.readline()
    print(
        reduce(
            mul,
            [sum([int(x) for x in line.split(",")]) for line in inputfile]
        )
    )
