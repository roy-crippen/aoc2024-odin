package day_02

import "../lib"
import "core:testing"
import "core:fmt"

INPUT :: #load("day_02.txt", string)

solution  := lib.Solution{
    day = 02,
    input = INPUT,
    part1 = part1,
    part2 = part2,
    expected_part1 = 42,
    expected_part2 = 42,
}

part1 := proc(s:string) -> int {
    return 42
}

part2 := proc(s:string) -> int {
    return 42
}

/*
   tests -----------------------------
*/

@(test)
test_example_part1 :: proc(t: ^testing.T) {
    p1_example := part1(example_str)
    expected :int = 42
    testing.expect(t, p1_example == expected, fmt.tprintf("Expected result %d, got %d", expected, p1_example))
}

@(test)
test_part1 :: proc(t: ^testing.T) {
    p1 := part1(INPUT)
    expected := solution.expected_part1
    testing.expect(t, p1 == expected, fmt.tprintf("Expected result %d, got %d", expected, p1))
}

@(test)
test_example_part2 :: proc(t: ^testing.T) {
    p2_example := part2(example_str)
    expected :int = 42
    testing.expect(t, p2_example == expected, fmt.tprintf("Expected result %d, got %d", expected, p2_example))
}

@(test)
test_part2 :: proc(t: ^testing.T) {
    p2 := part2(INPUT)
    expected := solution.expected_part2
    testing.expect(t, p2 == expected, fmt.tprintf("Expected result %d, got %d", expected, p2))
}

example_str := ``

