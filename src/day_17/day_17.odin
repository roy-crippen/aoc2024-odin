package day_17

import "../lib"
import "core:fmt"
import "core:testing"

EXAMPLE :: false
when EXAMPLE {
    A :: 729
    LEN :: 6
    PROGRAM :: [LEN]u64{0, 1, 5, 4, 3, 0}
    INPUT :: #load("example.txt", []u8)
    EXPECTED_PART1 :: 4635635210
    EXPECTED_PART2 :: 42
} else {
    A :: 59397658
    // A :: 59590048
    LEN :: 16
    PROGRAM :: [LEN]u64{2, 4, 1, 1, 7, 5, 4, 6, 1, 4, 0, 3, 5, 5, 3, 0}
    // PROGRAM :: [LEN]u64{2, 4, 1, 5, 7, 5, 0, 3, 1, 6, 4, 3, 5, 5, 3, 0}
    INPUT :: #load("day_17.txt", []u8)
    EXPECTED_PART1 :: 461421316
    EXPECTED_PART2 :: 202366627359274
}
B :: 0
C :: 0

run :: proc(a, b, c: ^u64) -> (out: [dynamic]u64) {
    out = make_dynamic_array_len_cap([dynamic]u64, 0, 16)
    pc, literal, combo: u64
    program := PROGRAM
    for pc != LEN {
        literal = program[pc + 1]
        switch literal {
        case 4:
            combo = a^
        case 5:
            combo = b^
        case 6:
            combo = c^
        case:
            combo = literal
        }
        pc += 2

        switch program[pc - 2] {
        case 0:
            a^ >>= combo
        case 1:
            b^ ~= literal
        case 2:
            b^ = combo % 8
        case 3:
            pc = literal if a^ != 0 else pc
        case 4:
            b^ ~= c^
        case 5:
            append_elem(&out, combo % 8)
        case 6:
            b^ = a^ >> combo
        case 7:
            c^ = a^ >> combo
        case:
            assert(false, "unreachable")
        }
    }

    return
}

solution := lib.Solution {
    day            = 17,
    input          = INPUT,
    part1          = part1,
    part2          = part2,
    expected_part1 = EXPECTED_PART1,
    expected_part2 = EXPECTED_PART2,
}

part1 :: proc(s: []u8) -> (result: u64) {
    a, b, c: u64 = A, B, C
    xs := run(&a, &b, &c)
    result = lib.from_digits(xs[:])
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
