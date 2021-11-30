// Compile with npx tsc .
// NOTE: this will create a .js file with the same name!

const fs = require("fs");

fs.readFile("input.txt", "utf8", (err, data: string) => {
    if (err) {
        return;
    }
    let lines: Array<string> = data.trim().split("\n");
    lines.shift(); // discard first line
    console.log(
        lines.map(
            (line: string) => line.split(",").map(
                (val: string) => parseInt(val)
            ).reduce(
                (x: number, y: number) => x + y
            )
        ).reduce(
            (x: number, y: number) => x * y
        )
    );
});
