package day_01

import "../lib"
import "core:fmt"
import "core:strings"
import "core:sort"
import sa "core:container/small_array"
import "core:testing"

INPUT: string : #load("day_01.txt", string)

solution := lib.Solution{
    day = 01,
    input = INPUT,
    part1 = part1,
    part2 = part2,
    expected_part1 = 2_086_478,
    expected_part2 = 24_941_624,
}

parse :: proc(s: string) -> (sa.Small_Array(1024, int), sa.Small_Array(1024, int)) {
    xs: sa.Small_Array(1024, int)
    ys: sa.Small_Array(1024, int)
    i := 0

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

        sa.push_back(&xs,lib.parse_uint_fast(x_str))
        sa.push_back(&ys,lib.parse_uint_fast(y_str))
    }
    return xs, ys
}

part1 := proc(s: string) -> int {
    sa_xs, sa_ys := parse(s)
    xs := sa.slice(&sa_xs)
    ys := sa.slice(&sa_ys)
    sort.heap_sort(xs)
    sort.heap_sort(ys)

    sum := 0
    for i in 0..<len(xs) {
        diff := xs[i] - ys[i]
        sum += diff if diff >= 0 else -diff
    }
    return sum
}

part2 := proc(s: string) -> int {
    sa_xs, sa_ys := parse(s)
    xs := sa.slice(&sa_xs)
    ys := sa.slice(&sa_ys)
    sum := 0
    for x in xs {
        for y in ys {
            sum += x if x == y else 0
        }
    }
    return sum
}


/*
   tests -----------------------------
*/

@(test)
test_example_part1 :: proc(t: ^testing.T) {
    p1_example := part1(example_str)
    expected :int = 11
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
    p2_example := part2(example_str)
    expected :int = 31
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
