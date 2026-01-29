package lib

import "core:fmt"
import "core:strings"
import "core:testing"

Solution :: struct {
    day:            u8,
    input:          []u8,
    part1:          proc(_: []u8) -> u64,
    part2:          proc(_: []u8) -> u64,
    expected_part1: u64,
    expected_part2: u64,
}

unsafe_string_to_int :: proc "contextless" (s: string) -> (result: int) {
    for c in s { result = result * 10 + (int(c) - '0') }
    return
}

unsafe_string_to_u32 :: proc "contextless" (s: string) -> (result: u32) {
    for c in s { result = result * 10 + (u32(c) - '0') }
    return
}

unsafe_string_to_u64 :: proc "contextless" (s: string) -> (result: u64) {
    for c in s { result = result * 10 + (u64(c) - '0') }
    return
}

unsafe_string_to_u16 :: proc "contextless" (s: string) -> (result: u16) {
    for c in s { result = result * 10 + (u16(c) - '0') }
    return
}

unsafe_string_to_i32 :: #force_inline proc "contextless" (s: string) -> (result: i32) {
    for c in s { result = result * 10 + (i32(c) - '0') }
    return
}

unsafe_slice_u8_to_int :: proc "contextless" (s: []u8) -> (result: int) {
    for c in s { result = result * 10 + (int(c) - '0') }
    return
}

unsafe_slice_u8_to_u16 :: proc "contextless" (s: []u8) -> (result: u16) {
    for c in s { result = result * 10 + (u16(c) - '0') }
    return
}


unssafe_slice_u8_to_i32 :: proc "contextless" (s: []u8) -> (result: i32) {
    for c in s { result = result * 10 + (i32(c) - '0') }
    return
}

unsafe_slice_u8_to_f32 :: proc "contextless" (s: []u8) -> (result: f32) {
    for c in s { result = result * 10 + (f32(c) - '0') }
    return
}

dbg :: proc(s: string) -> string { return strings.concatenate({"\n", s, "\n"}, context.temp_allocator) }

pow_u64 :: proc "contextless" (x, power: u64) -> (result: u64) {
    result = 1
    for _ in 0 ..< power do result *= x
    return
}

pow_int :: proc "contextless" (x, power: int) -> (result: int) {
    result = 1
    for _ in 0 ..< power do result *= x
    return
}

@(private)
powers_10 := [20]u64 {
    1,
    10,
    100,
    1_000,
    10_000,
    100_000,
    1_000_000,
    10_000_000,
    100_000_000,
    1_000_000_000,
    10_000_000_000,
    100_000_000_000,
    1_000_000_000_000,
    10_000_000_000_000,
    100_000_000_000_000,
    1_000_000_000_000_000,
    10_000_000_000_000_000,
    100_000_000_000_000_000,
    1_000_000_000_000_000_000,
    10_000_000_000_000_000_000, // 10^19
}

pow_10_u64 :: #force_inline proc "contextless" (n: u64) -> u64 {
    if n > 19 { return 0 }
    return powers_10[n]
}

/*
   tests -----------------------------
*/

@(test)
test_parse_uint_fast :: proc(t: ^testing.T) {
    val := unsafe_string_to_int("123")
    expected: int = 123
    testing.expect(t, val == expected, fmt.tprintf("Expected result %d, got %d", expected, val))
}
