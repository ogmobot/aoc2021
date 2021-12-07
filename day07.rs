use std::fs;

fn triangular(n: i32) -> i32 {
    return n*(n+1)/2;
}

fn main() {
    let contents = fs::read_to_string("input07.txt")
        .expect("File read error");
    let vals: Vec<i32> = contents
        .split(",")
        .filter(|s| !s.is_empty())
        .map(|s| s.trim().parse().unwrap())
        .collect();
    // part 1
    let result_p1: i32 = (0..(*vals.iter().max().unwrap()))
        .map(|target| vals
            .iter()
            .map(|val| (val - target).abs())
            .sum())
        .min().unwrap();
    println!("{}", result_p1);
    // part 2
    let result_p2: i32 = (0..(*vals.iter().max().unwrap()))
        .map(|target| vals
            .iter()
            .map(|val| triangular((val - target).abs()))
            .sum())
        .min().unwrap();
    println!("{}", result_p2);
}
// not 96003565
