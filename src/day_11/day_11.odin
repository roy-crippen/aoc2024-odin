package day_11

import "../lib"
import "core:fmt"
import "core:math"
import "core:strings"
import "core:testing"

EXAMPLE :: true
when EXAMPLE {
    INPUT :: #load("example.txt", []u8)
    EXPECTED_PART1 :: 55312
    EXPECTED_PART2 :: 65601038650482
} else {
    INPUT :: #load("day_11.txt", []u8)
    EXPECTED_PART1 :: 239714
    EXPECTED_PART2 :: 284973560658514
}

parse :: proc(s: []u8) -> (m: map[u64]u64) {
    m = make_map(map[u64]u64)
    vs, _ := strings.split(strings.clone_from_bytes(s), " ")
    for v in vs {
        m[lib.unsafe_string_to_u64(v)] = 1
    }
    return
}

digit_cnt :: proc(n: u64) -> u64 {
    if n < 10 {
        return 1
    } else {
        return 1 + digit_cnt(n / 10)
    }
}

split :: proc(n: u64) -> (lhs: u64, rhs: u64) {
    digits := digit_cnt(n)
    divisor := u64(math.pow10(f64((digits / 2))))
    lhs = n / divisor
    rhs = n % divisor
    return
}

count :: proc(input_m: map[u64]u64, steps: u64) -> (out_m: map[u64]u64) {
    if steps == 0 {
        return input_m
    }

    out_m = make_map_cap(map[u64]u64, 64)
    for stone, qty in input_m {
        if stone == 0 {
            out_m[1] += qty
        } else {
            if digit_cnt(stone) % 2 == 0 {
                lhs, rhs := split(stone)
                out_m[lhs] += qty
                out_m[rhs] += qty
            } else {
                out_m[stone * 2024] += qty
            }
        }
    }
    return count(out_m, steps - 1)
}

solution := lib.Solution {
    day            = 11,
    input          = INPUT,
    part1          = part1,
    part2          = part2,
    expected_part1 = EXPECTED_PART1,
    expected_part2 = EXPECTED_PART2,
}

part1 :: proc(s: []u8) -> (result: u64) {
    initial_m := parse(s)
    for _, value in count(initial_m, 25) { result += value }
    return
}

part2 :: proc(s: []u8) -> (result: u64) {
    initial_m := parse(s)
    for _, value in count(initial_m, 75) { result += value }
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

@(test)
test_digit_cnt :: proc(t: ^testing.T) {
    testing.expect(t, digit_cnt(12345) == 5)
    testing.expect(t, digit_cnt(123456789) == 9)
    testing.expect(t, digit_cnt(1) == 1)
}

@(test)
test_split :: proc(t: ^testing.T) {
    lhs, rhs := split(5)
    testing.expect(t, lhs == 5 && rhs == 0)
    lhs, rhs = split(56)
    testing.expect(t, lhs == 5 && rhs == 6)
    lhs, rhs = split(5635)
    testing.expect(t, lhs == 56 && rhs == 35)
    lhs, rhs = split(562001)
    testing.expect(t, lhs == 562 && rhs == 1)
    lhs, rhs = split(5600)
    testing.expect(t, lhs == 56 && rhs == 0)
}
