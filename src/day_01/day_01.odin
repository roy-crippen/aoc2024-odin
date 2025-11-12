package day_01

import "../lib"
import "core:fmt"

INPUT :: #load("day_01.txt", string)

parse :: proc(s: string) -> ([]u64, []u64) {



}

solution_01  := lib.Solution{
    day = 01,
    input = INPUT,
    part1 = part1,
    part2 = part2,
    expected_part1 = 2086478,
    expected_part2 = 24941624,
}

part1 := proc(s:string) -> u64 {
    fmt.println("hello from day 1 part 1")
    return 42
}

part2 := proc(s:string) -> u64 {
    return 42
}


