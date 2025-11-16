package day_02

import "../lib"
import sa "core:container/small_array"
import "core:fmt"
import "core:mem"
import "core:slice"
import "core:strings"
import "core:testing"

INPUT :: #load("day_02.txt", string)

is_pair_safe :: #force_inline proc(a: int, b: int, asc: bool) -> bool {
    diff := a - b
    delta := diff if diff >= 0 else -diff
    return delta < 4 && delta != 0 && a < b == asc
}

is_safe_part1 :: proc(s: string) -> bool {
    s_mut := s
    prev_str, _ := strings.split_iterator(&s_mut, " ") // acts like a next() function
    curr_str, _ := strings.split_iterator(&s_mut, " ")

    prev := lib.parse_uint_fast(prev_str)
    curr := lib.parse_uint_fast(curr_str)
    asc := curr > prev

    if !is_pair_safe(prev, curr, asc) {
        return false
    }

    // process the rest
    for vs in strings.split_iterator(&s_mut, " ") {
        prev = curr
        curr = lib.parse_uint_fast(vs)
        if !is_pair_safe(prev, curr, asc) {
            return false
        }
    }
    return true
}

is_safe :: proc(xs: []int) -> bool {
    asc := xs[1] > xs[0]
    try_skip := false
    i := 0
    for ; i < len(xs) - 1; i += 1 {
        if is_pair_safe(xs[i], xs[i + 1], asc) {
            continue
        }
        if try_skip {return false}
        if i < len(xs) - 2 {
            try_skip = true
            if !is_pair_safe(xs[i], xs[i + 2], asc) {return false}
            i += 1
        }
    }
    return true
}

is_safe_part2 :: proc(s: string) -> bool {
    s_mut := s
    sa_xs: sa.Small_Array(10, int)
    for str in strings.split_iterator(&s_mut, " ") {
        sa.push_back(&sa_xs, lib.parse_uint_fast(str))
    }
    xs := sa.slice(&sa_xs)

    if is_safe(xs) {
        return true
    }
    slice.reverse(xs)
    return is_safe(xs)
}

solution := lib.Solution {
    day            = 02,
    input          = INPUT,
    part1          = part1,
    part2          = part2,
    expected_part1 = 390,
    expected_part2 = 439,
}

run :: proc(s: string, f: proc(_: string) -> bool) -> (cnt: int) {
    s_mut := s
    cnt = 0
    for line in strings.split_lines_iterator(&s_mut) {
        cnt += 1 if f(line) else 0
    }
    return
}

part1 :: proc(s: string) -> (cnt: int) {
    return run(s, is_safe_part1)
}

part2 :: proc(s: string) -> (cnt: int) {
    return run(s, is_safe_part2)
}

/*
   tests -----------------------------
*/

@(test)
test_example_part1 :: proc(t: ^testing.T) {
    p1_example := part1(example_str)
    expected: int = 2
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
    expected: int = 4
    testing.expect(t, p2_example == expected, fmt.tprintf("Expected result %d, got %d", expected, p2_example))
}

@(test)
test_part2 :: proc(t: ^testing.T) {
    p2 := part2(INPUT)
    expected := solution.expected_part2
    testing.expect(t, p2 == expected, fmt.tprintf("Expected result %d, got %d", expected, p2))
}

@(test)
test_is_pair_safe :: proc(t: ^testing.T) {
    testing.expect(t, is_pair_safe(7, 6, false))
    testing.expect(t, is_pair_safe(6, 7, true))
    testing.expect(t, !is_pair_safe(7, 6, true))
    testing.expect(t, !is_pair_safe(7, 3, false))
    testing.expect(t, !is_pair_safe(7, 7, true))
    testing.expect(t, !is_pair_safe(7, 7, false))
}

@(test)
test_is_safe_part2 :: proc(t: ^testing.T) {
    testing.expect(t, !is_safe_part2("1 2 7 8 9"))
    testing.expect(t, is_safe_part2("1 3 2 4 5"))
    testing.expect(t, is_safe_part2("8 6 4 4 1"))
    testing.expect(t, !is_safe_part2("42 41 43 45 50"))
    testing.expect(t, is_safe_part2("42 41 43 45 46"))
}

example_str := `7 6 4 2 1
1 2 7 8 9
9 7 6 2 1
1 3 2 4 5
8 6 4 4 1
1 3 6 7 9
`
