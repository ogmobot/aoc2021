// Compile with npx tsc .
// NOTE: this will create a .js file with the same name!

const fs = require("fs");

function get_grid(data: string): Array<string> {
    let lines: Array<string> = data.trim().split("\n");
    return lines;
}

function move_east(grid: Array<string>): Array<string> {
    let result: Array<Array<string>> = grid.map((s) => Array.from(s));
    grid.forEach((s, row) => {
        Array.from(s).forEach((c, col) => {
            if ((c == ">") && (grid[row][(col + 1) % s.length] == ".")) {
                result[row][col] = ".";
                result[row][(col + 1) % s.length] = ">";
            }
        });
    });
    return result.map((arr) => arr.join(""));
}

function move_south(grid: Array<string>): Array<string> {
    let result: Array<Array<string>> = grid.map((s) => Array.from(s));
    grid.forEach((s, row) => {
        Array.from(s).forEach((c, col) => {
            if ((c == "v") && (grid[(row + 1) % grid.length][col] == ".")) {
                result[row][col] = ".";
                result[(row + 1) % grid.length][col] = "v";
            }
        });
    });
    return result.map((arr) => arr.join(""));
}

fs.readFile("input25.txt", "utf8", (err: object, data: string) => {
    if (err) {
        return;
    }
    let grid: Array<string> = get_grid(data);
    //console.log(grid);

    let counter: number = 0;
    while (true) {
        counter += 1;
        const orig_state: string = grid.join("");
        grid = move_east(grid);
        grid = move_south(grid);
        const final_state: string = grid.join("");
        if (orig_state == final_state) break;
    }
    console.log(counter);
    //console.log(grid);
});

/*
I can see how JavaScript got so popular as a scripting tool, and also why
Microsoft felt the need to develop TypeScript on top of it. JavaScript's logic
for implicity converting between types can lead to some weird interactions,
    [ e.g. ('b'+'a'+ +'a'+'a').toLowerCase() === 'banana' ]
and a way to automatically detect that nothing's too out of whack goes a long
way towards avoiding unexpected results like this.
*/
