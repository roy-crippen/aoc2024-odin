package day_09

import "../lib"
import "core:fmt"
import "core:testing"

EXAMPLE :: true
when EXAMPLE {
    INPUT :: #load("example.txt", []u8)
    EXPECTED_PART1 :: 42
    EXPECTED_PART2 :: 42
} else {
    INPUT :: #load("day_09.txt", []u8)
    EXPECTED_PART1 :: 42
    EXPECTED_PART2 :: 42
}


solution := lib.Solution {
    day            = 09,
    input          = INPUT,
    part1          = part1,
    part2          = part2,
    expected_part1 = EXPECTED_PART1,
    expected_part2 = EXPECTED_PART2,
}

part1 :: proc(s: []u8) -> (result: u64) {
    result = EXPECTED_PART1
    return
}

part2 :: proc(s: []u8) -> (result: u64) {
    result = EXPECTED_PART2
    return
}

/*
   tests -----------------------------
*/

@(test)
test_part1 :: proc(t: ^testing.T) {
    context.allocator = context.temp_allocator
    p1 := part1(INPUT)
    expected: u64 = EXPECTED_PART1
    testing.expect(t, p1 == expected, fmt.tprintf("Expected result %d, got %d", expected, p1))
}

@(test)
test_part2 :: proc(t: ^testing.T) {
    context.allocator = context.temp_allocator
    p2 := part2(INPUT)
    expected: u64 = EXPECTED_PART2
    testing.expect(t, p2 == expected, fmt.tprintf("Expected result %d, got %d", expected, p2))
}
