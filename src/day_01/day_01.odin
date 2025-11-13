package day_01

import "../lib"
import "core:fmt"
import "core:strings"
import "core:sort"

INPUT: string : #load("day_01.txt", string)

solution_01 := lib.Solution{
    day = 01,
    input = INPUT,
    part1 = part1,
    part2 = part2,
    expected_part1 = 2_086_478,
    expected_part2 = 24_941_624,
}

// fast integer parsing for non-negative integers
@(private="file")
parse_uint_fast :: proc(s: string) -> int {
    result := 0
    for c in s {
        result = result * 10 + (int(c) - '0')
    }
    return result
}

parse :: proc(s: string) -> ([1000]int, [1000]int, int) {
    xs: [1000]int
    ys: [1000]int
    count := 0 // Renamed from len to avoid shadowing
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
        i += 3 // Skip exactly 3 spaces
        y_start := i
        for i < len(s) && s[i] != '\n' {
            i += 1
        }
        y_str := s[y_start:i]
        i += 1 // Skip newline

        xs[count] = parse_uint_fast(x_str)
        ys[count] = parse_uint_fast(y_str)
        count += 1
    }
    return xs, ys, count
}

part1 := proc(s: string) -> int {
    xs, ys, count := parse(s)
    sort.heap_sort(xs[:count])
    sort.heap_sort(ys[:count])

    sum := 0
    for i in 0..<count {
        diff := xs[i] - ys[i]
        sum += diff if diff >= 0 else -diff
    }
    return sum
}

part2 := proc(s: string) -> int {
    return 42
}