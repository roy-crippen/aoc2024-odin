package day_01

import "../lib"
import sa "core:container/small_array"
import "core:fmt"
import "core:sort"
import "core:testing"

INPUT :: #load("day_01.txt", []u8)

solution := lib.Solution {
    day            = 01,
    input          = INPUT,
    part1          = part1,
    part2          = part2,
    expected_part1 = 2_086_478,
    expected_part2 = 24_941_624,
}

parse :: proc(s: []u8) -> (xs: sa.Small_Array(1024, i32), ys: sa.Small_Array(1024, i32)) {
    i: int
    for i < len(s) {
        if i < len(s) && s[i] == '\n' {
            i += 1
            continue
        }
        x_start := i
        for i < len(s) && s[i] != ' ' {
            i += 1
        }
        x_str := s[x_start:i]
        i += 3 // skip 3 spaces
        y_start := i
        for i < len(s) && s[i] != '\n' {
            i += 1
        }
        y_str := s[y_start:i]
        i += 1 // skip newline

        sa.push_back(&xs, lib.unssafe_slice_u8_to_i32(x_str))
        sa.push_back(&ys, lib.unssafe_slice_u8_to_i32(y_str))
    }
    return xs, ys
}

part1 :: proc(s: []u8) -> (result: u64) {
    sa_xs, sa_ys := parse(s)
    xs := sa.slice(&sa_xs)
    ys := sa.slice(&sa_ys)
    sort.heap_sort(xs)
    sort.heap_sort(ys)

    sum: i32
    for i in 0 ..< len(xs) {
        diff := xs[i] - ys[i]
        sum += diff if diff >= 0 else -diff
    }
    result = cast(u64)sum
    return
}

part2 :: proc(s: []u8) -> (result: u64) {
    sa_xs, sa_ys := parse(s)
    xs := sa.slice(&sa_xs)
    ys := sa.slice(&sa_ys)
    sum: i32
    for x in xs {
        for y in ys {
            sum += x if x == y else 0
        }
    }
    result = cast(u64)sum
    return
}


/*
   tests -----------------------------
*/

@(test)
test_example_part1 :: proc(t: ^testing.T) {
    p1_example := part1(example_u8)
    expected: u64 = 11
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
    expected: u64 = 31
    testing.expect(t, p2_example == expected, fmt.tprintf("Expected result %d, got %d", expected, p2_example))
}

@(test)
test_part2 :: proc(t: ^testing.T) {
    p2 := part2(INPUT)
    expected := solution.expected_part2
    testing.expect(t, p2 == expected, fmt.tprintf("Expected result %d, got %d", expected, p2))
}

example_str := `3   4
4   3
2   5
1   3
3   9
3   3`

example_u8 := transmute([]u8)example_str
