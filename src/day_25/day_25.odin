package day_25

import "../lib"
import "core:bytes"
import "core:fmt"
import "core:testing"

EXAMPLE :: false
when EXAMPLE {
    INPUT :: #load("example.txt", []u8)
    EXPECTED_PART1 :: 3
    EXPECTED_PART2 :: 42
} else {
    INPUT :: #load("day_25.txt", []u8)
    EXPECTED_PART1 :: 3264
    EXPECTED_PART2 :: 42
}


solution := lib.Solution {
    day            = 25,
    input          = INPUT,
    part1          = part1,
    part2          = part2,
    expected_part1 = EXPECTED_PART1,
    expected_part2 = EXPECTED_PART2,
}

Ctx :: struct {
    locks: [dynamic][5]u16,
    keys:  [dynamic][5]u16,
}

parse :: proc(s: []u8) -> (ctx: Ctx) {
    locks := make_dynamic_array([dynamic][5]u16)
    keys := make_dynamic_array([dynamic][5]u16)

    for block in bytes.split(s, {'\n', '\n'}) {
        lines := bytes.split(block, {'\n'})
        xs: [5]u16
        for ms, i in transpose(lines[1:6]) {
            xs[i] = count_char(ms)
        }
        if string(lines[0]) == "#####" {
            append_elem(&locks, xs)
        } else {
            append_elem(&keys, xs)
        }
    }
    ctx = {
        locks = locks,
        keys  = keys,
    }
    return
}

count_char :: #force_inline proc "contextless" (xs: [5]u8) -> (cnt: u16) {
    for x in xs {
        if x == '#' do cnt += 1
    }
    return
}

transpose :: proc(rows: [][]u8) -> (mat: [5][5]u8) {
    if len(rows) != 5 && len(rows[0]) != 5 {
        panic("transpose: expected exactly 5 rows and 5 cols")
    }
    for i in 0 ..< 5 {
        for j in 0 ..< 5 {
            mat[j][i] = rows[i][j] // transpose: swap i and j
        }
    }
    return
}

part1 :: proc(s: []u8) -> (result: u64) {
    ctx := parse(s)
    for lock in ctx.locks {
        for key in ctx.keys {
            match := true
            for i in 0 ..< 5 {
                if lock[i] + key[i] > 5 do match = false
            }
            if match do result += 1
        }
    }
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
