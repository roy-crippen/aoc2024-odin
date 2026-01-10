package day_07

import "../lib"
import "core:fmt"
import "core:strings"
import "core:testing"

EXAMPLE :: false
when EXAMPLE {
    INPUT :: #load("example.txt", []u8)
    EXPECTED_PART1 :: 3749
    EXPECTED_PART2 :: 11387
} else {
    INPUT :: #load("day_07.txt", []u8)
    EXPECTED_PART1 :: 5837374519342
    EXPECTED_PART2 :: 492383931650959
}

Equation :: struct {
    answer: u64,
    vals:   []u64,
}

parse :: proc(s: []u8) -> (eqs: []Equation) {
    s_mut := string(s)
    es := make_dynamic_array([dynamic]Equation)
    for line in strings.split_lines_iterator(&s_mut) {
        strs, _ := strings.split(line, ": ")
        answer := lib.unsafe_string_to_u64(strs[0])

        vs := make_dynamic_array([dynamic]u64)
        for str in strings.split_iterator(&strs[1], " ") { append_elem(&vs, lib.unsafe_string_to_u64(str)) }
        vals := vs[:]

        append_elem(&es, Equation{answer, vals})
    }
    eqs = es[:]
    return
}

is_valid_eq :: proc(eq: Equation, is_part2: bool) -> bool {
    switch len(eq.vals) {
    case 1:
        return eq.answer == eq.vals[0]
    case 2:
        return(
            eq.answer == eq.vals[0] + eq.vals[1] ||
            eq.answer == eq.vals[0] * eq.vals[1] ||
            (is_part2 && eq.answer == concat_u64(eq.vals[0], eq.vals[1])) \
        )
    case:
        last_idx := len(eq.vals) - 1
        last := eq.vals[last_idx]
        next_vals := eq.vals[:last_idx]

        if eq.answer % last == 0 {
            eq_next := Equation {
                answer = eq.answer / last,
                vals   = next_vals,
            }
            if is_valid_eq(eq_next, is_part2) { return true }
        }

        if eq.answer > last {
            eq_next := Equation {
                answer = eq.answer - last,
                vals   = next_vals,
            }
            if is_valid_eq(eq_next, is_part2) { return true }
        }

        if is_part2 && eq.answer > last {
            lhs, is_last_concated := un_concat_u64(eq.answer, last)
            if !is_last_concated { return false }
            eq_next := Equation {
                answer = lhs,
                vals   = next_vals,
            }
            if is_valid_eq(eq_next, is_part2) { return true }
        }
    }
    return false
}

un_concat_u64 :: proc "contextless" (joined: u64, rhs: u64) -> (u64, bool) {
    check := rhs
    divisor: u64 = 10
    for check >= 10 { check, divisor = check / 10, divisor * 10 }
    if joined % divisor == rhs { return joined / divisor, true } else { return 0, false }
}

concat_u64 :: proc "contextless" (a: u64, b: u64) -> u64 {
    t := b
    v: u64 = 1
    for t != 0 { t, v = t / 10, v * 10 }
    return a * v + b
}


solution := lib.Solution {
    day            = 07,
    input          = INPUT,
    part1          = part1,
    part2          = part2,
    expected_part1 = EXPECTED_PART1,
    expected_part2 = EXPECTED_PART2,
}

solve :: proc(eqs: []Equation, is_part2: bool) -> (result: u64) {
    for eq in eqs {
        if is_valid_eq(eq, is_part2) { result += eq.answer }
    }
    return
}

part1 :: proc(s: []u8) -> (result: u64) { return solve(parse(s), false) }

part2 :: proc(s: []u8) -> (result: u64) { return solve(parse(s), true) }

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

@(test)
test_concat_u64 :: proc(t: ^testing.T) {
    testing.expect(t, concat_u64(123, 456) == 123456)
    testing.expect(t, concat_u64(1, 23456) == 123456)
    testing.expect(t, concat_u64(12345, 6) == 123456)
}

@(test)
test_un_concat_u64 :: proc(t: ^testing.T) {
    v, b := un_concat_u64(123456, 456)
    testing.expect(t, b && v == 123)

    v, b = un_concat_u64(123456, 3456)
    testing.expect(t, b && v == 12)

    v, b = un_concat_u64(123456, 111)
    testing.expect(t, !b && v == 0)
}
