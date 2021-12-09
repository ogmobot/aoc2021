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

func adjacent_coords(array []string, row int, col int) []coord {
    var result []coord
    if row > 0                { result = append(result, coord{row - 1, col}) }
    if (row + 1) < len(array) { result = append(result, coord{row + 1, col}) }
    if col > 0                { result = append(result, coord{row, col - 1}) }
    if (col + 1) < len(array) { result = append(result, coord{row, col + 1}) }
    return result
}

func risk(array []string, row int, col int) int {
    lowpoint := true
    adjs := adjacent_coords(array, row, col)
    for i := 0; i < len(adjs); i++ {
        lowpoint = lowpoint && (array[row][col] < array[adjs[i].row][adjs[i].col])
    }
    if lowpoint {
        return 1 + (int(array[row][col]) - int('0'))
    }
    return 0
}

func find_attractor(array []string, row int, col int) coord {
    var adjs []coord
    for risk(array, row, col) == 0 {
        adjs = adjacent_coords(array, row, col)
        for i := 0; i < len(adjs); i++ {
            if array[adjs[i].row][adjs[i].col] < array[row][col] {
                row, col = adjs[i].row, adjs[i].col
                break
            }
        }
    }
    return coord{row, col}
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
    // part 1
    total := 0
    for row := 0; row < len(seafloor); row++ {
        for col := 0; col < len(seafloor[row]); col++ {
            total += risk(seafloor, row, col)
        }
    }
    fmt.Println(total)
    // part 2
    basins := make(map[coord]int)
    for row := 0; row < len(seafloor); row++ {
        for col := 0; col < len(seafloor[row]); col++ {
            if seafloor[row][col] != '9' {
                basins[find_attractor(seafloor, row, col)] += 1
            }
        }
    }
    var sizes []int
    for _, size := range basins {
        sizes = append(sizes, size)
    }
    sort.Slice(sizes, func (i, j int) bool { return sizes[i] > sizes[j] })
    fmt.Println(sizes[0] * sizes[1] * sizes[2])
}
