package main;

import (
    "fmt"
    "bufio"
    "os"
    "strings"
    "strconv"
)

func main() {
    inputfile, err := os.Open("input.txt")
    if err != nil { panic(err) }

    scanner := bufio.NewScanner(inputfile)
    scanner.Scan() // discard first line
    product := 1
    for scanner.Scan() {
        sum := 0;
        vals := strings.Split(scanner.Text(), ",")
        for _, val := range vals {
            v, _ := strconv.Atoi(strings.TrimSpace(val))
            sum += v
        }
        product *= sum
    }
    fmt.Println(product)
}
