#!/usr/bin/js

const fs = require("fs");

fs.readFile("input.txt", "utf8", (err, data) => {
    if (err) {
        return;
    }
    let lines = data.trim().split("\n");
    lines.shift(); // discard first line
    console.log(
        lines.map(
            (line) => line.split(",").map(
                (val) => parseInt(val)
            ).reduce(
                (x, y) => x + y
            )
        ).reduce(
            (x, y) => x * y
        )
    );
});
