package lib

import "core:fmt"
import "core:testing"

// best 1,2,3,99 = Total time:  1.042ms
// ave 1,2,3,99 = approximately 1.500ms

Solution :: struct {
    day:            int,
    input:          string,
    part1:          proc(s: string) -> int,
    part2:          proc(s: string) -> int,
    expected_part1: int,
    expected_part2: int,
}

Solution_new :: struct {
    day:            int,
    input:          string,
    part1:          proc(s: string) -> u64,
    part2:          proc(s: string) -> u64,
    expected_part1: int,
    expected_part2: int,
}

parse_uint_fast :: proc(s: string) -> int {
    result := 0
    for c in s {
        result = result * 10 + (int(c) - '0')
    }
    return result
}

parse_slice_u8_fast :: proc(s: []u8) -> int {
    result := 0
    for c in s {
        result = result * 10 + (int(c) - '0')
    }
    return result
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
