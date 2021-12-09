package main;

import (
    "fmt"
    "bufio"
    "os"
    "strings"
    "sort"
)

type coord struct {
    row int
    col int
}

func adjacent_coords(array *([]string), row int, col int) []coord {
    var result []coord
    if row > 0                 { result = append(result, coord{row - 1, col}) }
    if (row + 1) < len(*array) { result = append(result, coord{row + 1, col}) }
    if col > 0                 { result = append(result, coord{row, col - 1}) }
    if (col + 1) < len((*array)[row]) {
                                 result = append(result, coord{row, col + 1}) }
    return result
}

func risk(array *([]string), row int, col int) int {
    lowpoint := true
    adjs := adjacent_coords(array, row, col)
    for i := 0; i < len(adjs); i++ {
        lowpoint = lowpoint && ((*array)[row][col] < (*array)[adjs[i].row][adjs[i].col])
    }
    if lowpoint {
        return 1 + (int((*array)[row][col]) - int('0'))
    }
    return 0
}

func basin_size(array *([]string), lowpoint coord, result chan int) {
    // because every point drains to a single lowpoint, each basin must be bounded by 9s
    visited := make(map[coord]bool)
    var todo []coord
    var adjs []coord
    var popped coord
    todo = append(todo, lowpoint)
    for len(todo) > 0 {
        popped, todo = todo[0], todo[1:]
        visited[popped] = true
        adjs = adjacent_coords(array, popped.row, popped.col)
        for i := 0; i < len(adjs); i++ {
            r, c := adjs[i].row, adjs[i].col
            if (!visited[coord{r, c}]) && (int((*array)[r][c]) != int('9')) {
                todo = append(todo, coord{r, c})
            }
        }
    }
    result <- len(visited)
}

func main() {
    inputfile, err := os.Open("input09.txt")
    if err != nil { panic(err) }

    var seafloor []string
    scanner := bufio.NewScanner(inputfile)
    for scanner.Scan() {
        seafloor = append(seafloor, strings.Trim(scanner.Text(), "\n"))
    }
    // don't both converting 48..57 to 0..9
    var lowpoints []coord
    // part 1
    total := 0
    for row := 0; row < len(seafloor); row++ {
        for col := 0; col < len(seafloor[row]); col++ {
            risk_level := risk(&seafloor, row, col)
            total += risk_level
            if risk_level > 0 {
                lowpoints = append(lowpoints, coord{row, col})
            }
        }
    }
    fmt.Println(total)
    // part 2
    var sizes []int
    results := make(chan int)
    for i := 0; i < len(lowpoints); i++ {
        go basin_size(&seafloor, lowpoints[i], results)
    }
    for i := 0; i < len(lowpoints); i++ {
        sizes = append(sizes, (<-results))
    }
    sort.Slice(sizes, func (i, j int) bool { return sizes[i] > sizes[j] })
    //fmt.Println(sizes)
    fmt.Println(sizes[0] * sizes[1] * sizes[2])

}

/* Golang is a bit... meh. Passing arrays by value probably means less
   mutability-related shenanigans, but it's annoying to need to use
   `xs = append(xs, x)` to extend an array. The C-style `for` loops are also a
   bit bothersome. At least the package library is extensive. 
   I also tried solving this problem with goroutines, but since it's such a
   small program, the result took more time and more memory than the orignal.
   Still, Go seems like a good option if ever I need to do something with a lot
   of "threads" in parallel.
*/
