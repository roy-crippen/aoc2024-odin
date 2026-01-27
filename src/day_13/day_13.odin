package day_13

import "../lib"
import "core:bytes"
import "core:fmt"
import "core:math"
import "core:testing"

EXAMPLE :: false
when EXAMPLE {
    INPUT :: #load("example.txt", []u8)
    EXPECTED_PART1 :: 480
    EXPECTED_PART2 :: 875318608908
} else {
    INPUT :: #load("day_13.txt", []u8)
    EXPECTED_PART1 :: 29598
    EXPECTED_PART2 :: 93217456941970
}

parse_values :: proc(s: []u8, sep: u8) -> (v1: int, v2: int) {
    l := len(s)
    i, j: int
    for i = 0; s[i] != sep; i += 1 {  }
    for j = i; s[j] != ','; j += 1 {  }
    v1 = lib.unsafe_slice_u8_to_int(s[i + 1:j])
    for i = j; s[i] != sep; i += 1 {  }
    for j = i; j < l; j += 1 {  }
    v2 = lib.unsafe_slice_u8_to_int(s[i + 1:j])
    return
}

parse_block :: proc(block: []u8) -> (ax, ay, bx, by, px, py: int) {
    vs := bytes.split(block, {'\n'})
    ax, ay = parse_values(vs[0], '+')
    bx, by = parse_values(vs[1], '+')
    px, py = parse_values(vs[2], '=')
    return
}

solve :: proc(s: []u8, offset: int) -> (acc: u64) {
    ca, cb: f64
    for block in bytes.split(s, {'\n', '\n'}) {
        ax, ay, bx, by, px, py := parse_block(block)
        px += offset
        py += offset
        ca = f64(px * by - py * bx) / f64(ax * by - ay * bx)
        cb = (f64(px) - f64(ax) * ca) / f64(bx)
        if math.mod_f64(ca, 1) == 0 && math.mod_f64(cb, 1) == 0 {
            acc += u64(ca) * 3 + u64(cb)
        }

    }
    return u64(acc)
}

solution := lib.Solution {
    day            = 13,
    input          = INPUT,
    part1          = part1,
    part2          = part2,
    expected_part1 = EXPECTED_PART1,
    expected_part2 = EXPECTED_PART2,
}

part1 :: proc(s: []u8) -> (result: u64) {
    return solve(s, 0)
}

part2 :: proc(s: []u8) -> (result: u64) {
    return solve(s, 10_000_000_000_000)
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
test_parse_block :: proc(t: ^testing.T) {
    context.allocator = context.temp_allocator
    str: string = `Button A: X+94, Y+34
    Button B: X+22, Y+67
    Prize: X=8400, Y=5400`
    s := transmute([]u8)str
    ax, ay, bx, by, px, py := parse_block(s)
    testing.expect(t, ax == 94 && ay == 34 && bx == 22 && by == 67 && px == 8400 && py == 5400)
}

@(test)
test_parse_values :: proc(t: ^testing.T) {
    context.allocator = context.temp_allocator
    str: string = "Button A: X+94, Y+34"
    s: []u8 = transmute([]u8)(str)
    v1, v2 := parse_values(s, '+')
    testing.expect(t, v1 == 94 && v2 == 34)
}
