package day_03

import "../lib"
import "core:fmt"
import "core:slice"
import "core:testing"


INPUT :: #load("day_03.txt", []u8)

solution := lib.Solution {
    day            = 03,
    input          = INPUT,
    part1          = part1,
    part2          = part2,
    expected_part1 = 169021493,
    expected_part2 = 111762583,
}

is_mul :: #force_inline proc(s: []u8, mul_slice: []u8) -> bool {return slice.has_prefix(s, mul_slice)}
is_do :: #force_inline proc(s: []u8, do_slice: []u8) -> bool {return slice.has_prefix(s, do_slice)}
is_dont :: #force_inline proc(s: []u8, dont_slice: []u8) -> bool {return slice.has_prefix(s, dont_slice)}

get_close_paren_idx :: #force_inline proc(s: []u8) -> int {
    i, b := slice.linear_search(s, ')')
    if !b {panic("parse error looking for ')'")}
    return i
}

parse_val :: proc(s: []u8) -> int {
    comma_idx, ok := slice.linear_search(s, ',')
    if !ok {return 0}
    a := lib.parse_slice_u8_fast(s[4:comma_idx])
    b := lib.parse_slice_u8_fast(s[comma_idx + 1:len(s) - 1])
    return a * b
}

part1 :: proc(xs: []u8) -> u64 {
    t: string = "mul("
    mul_slice := transmute([]u8)t
    result, i: int

    for ; i < len(xs); i += 1 {
        if !is_mul(xs[i:], mul_slice) {continue}
        j := get_close_paren_idx(xs[i:])
        if (j >= 12) {continue}
        result += parse_val(xs[i:i + j + 1])
        i += j
    }
    return cast(u64)result
}

part2 :: proc(xs: []u8) -> u64 {
    t: string = "mul("
    mul_slice := transmute([]u8)t
    t = "do()"
    do_slice := transmute([]u8)t
    t = "don't()"
    dont_slice := transmute([]u8)t

    result, i: int
    enabled := true

    for ; i < len(xs); i += 1 {
        if is_do(xs[i:], do_slice) {
            enabled = true
            i += 3
            continue
        }

        if is_dont(xs[i:], dont_slice) {
            enabled = false
            i += 6
            continue
        }

        if !enabled || !is_mul(xs[i:], mul_slice) {continue}
        j := get_close_paren_idx(xs[i:])
        if (j >= 12) {continue}
        result += parse_val(xs[i:i + j + 1])
        i += j
    }
    return cast(u64)result
}

/*
   tests -----------------------------
*/

@(test)
test_example_part1 :: proc(t: ^testing.T) {
    p1_example := part1(example_u8)
    expected: u64 = 161
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
    p2_example := part2(example_u8)
    expected: u64 = 48
    testing.expect(t, p2_example == expected, fmt.tprintf("Expected result %d, got %d", expected, p2_example))
}

@(test)
test_part2 :: proc(t: ^testing.T) {
    p2 := part2(INPUT)
    expected := solution.expected_part2
    testing.expect(t, p2 == expected, fmt.tprintf("Expected result %d, got %d", expected, p2))
}

example_str := `xmul(2,4)&mul(3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))`

example_u8 := transmute([]u8)example_str
