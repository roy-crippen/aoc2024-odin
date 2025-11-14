package lib

import "core:testing"
import "core:fmt"

Solution :: struct {
day : int,
input : string,
part1 : proc(s: string) -> int,
part2 : proc(s: string) -> int,
expected_part1 : int,
expected_part2 : int,
}

parse_uint_fast :: proc(s: string) -> int {
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
    expected :int = 123
    testing.expect(t, val == expected, fmt.tprintf("Expected result %d, got %d", expected, val))
}
