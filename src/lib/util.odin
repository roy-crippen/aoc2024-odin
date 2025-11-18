package lib

import "core:fmt"
import "core:testing"

// best 1,2,3,99 = Total time:  1.042ms
// ave 1,2,3,99 = approximately 1.500ms

Solution :: struct {
    day:            u8,
    input:          []u8,
    part1:          proc([]u8) -> u64,
    part2:          proc([]u8) -> u64,
    expected_part1: u64,
    expected_part2: u64,
}

parse_uint_fast :: proc(s: string) -> (result: int) {
    for c in s {result = result * 10 + (int(c) - '0')}
    return
}

parse_u32_fast :: proc(s: string) -> (result: u32) {
    for c in s {result = result * 10 + (u32(c) - '0')}
    return
}

parse_i32_fast :: #force_inline proc(s: string) -> (result: i32) {
    for c in s {result = result * 10 + (i32(c) - '0')}
    return
}

parse_slice_u8_fast :: proc(s: []u8) -> (result: int) {
    for c in s {result = result * 10 + (int(c) - '0')}
    return
}

parse_slice_u8_to_i32 :: proc(s: []u8) -> (result: i32) {
    for c in s {result = result * 10 + (i32(c) - '0')}
    return
}

/*
   tests -----------------------------
*/

@(test)
test_parse_uint_fast :: proc(t: ^testing.T) {
    val := parse_uint_fast("123")
    expected: int = 123
    testing.expect(t, val == expected, fmt.tprintf("Expected result %d, got %d", expected, val))
}
