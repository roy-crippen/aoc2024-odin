package day_05

import "../lib"
import bp "../lib/bitpair"
import "core:fmt"
import "core:slice"
import "core:testing"

INPUT :: #load("day_05.txt", []u8)

parse :: proc(s: []u8) -> (invalid_rule_map: bp.BitPairSet, jobs: [dynamic][dynamic]u16) {
    invalid_rule_map, _ = bp.create(2, context.allocator)

    i := 0
    rules_end := false

    // parse rules section until blank line ("\n\n")
    for !rules_end && i < len(s) {
        v0: u16
        v1: u16

        // parse first number (before '|')
        num_start := i
        for i < len(s) && s[i] >= '0' && s[i] <= '9' { i += 1 }
        if i > num_start {
            v0 = lib.unsafe_slice_u8_to_u16(s[num_start:i])
        } else {
            // invalid — skip or error
            continue
        }

        // expect '|'
        if i < len(s) && s[i] == '|' { i += 1 } else { continue }

        // parse second number (before '\n')
        num_start = i
        for i < len(s) && s[i] >= '0' && s[i] <= '9' { i += 1 }
        if i > num_start {
            v1 = lib.unsafe_slice_u8_to_u16(s[num_start:i])
        } else {
            continue
        }

        // eet the rule
        bp.unsafe_set(&invalid_rule_map, v1, v0)

        // skip to next line
        for i < len(s) && s[i] != '\n' { i += 1 }
        if i < len(s) && s[i] == '\n' { i += 1 }

        // check for blank line ("\n\n" or end)
        if i < len(s) && s[i] == '\n' {
            rules_end = true
            // skip the second \n
            i += 1
        } else if i >= len(s) {
            rules_end = true
        }

        // skip \r if present
        if i < len(s) && s[i] == '\r' { i += 1 }
    }

    // now parse jobs section (from current i to end)
    jobs = make([dynamic][dynamic]u16, context.allocator)

    for i < len(s) {
        job := make([dynamic]u16, context.allocator)

        // parse comma-separated numbers until '\n'
        for {
            // skip leading whitespace / \r if any (though AoC usually clean)
            for i < len(s) && (s[i] == ' ' || s[i] == '\r') { i += 1 }

            num_start := i
            for i < len(s) && s[i] >= '0' && s[i] <= '9' { i += 1 }
            if i > num_start {
                append(&job, lib.unsafe_slice_u8_to_u16(s[num_start:i]))
            }

            // expect ',' or '\n'
            if i >= len(s) || s[i] == '\n' {
                break
            } else if s[i] == ',' {
                i += 1
            } else {
                // invalid token — skip line or error
                free(&job)
                break
            }
        }

        if len(job) > 0 {
            append(&jobs, job)
        } else {
            // empty line — discard
            free(&job)
        }

        // skip to next line
        for i < len(s) && s[i] != '\n' { i += 1 }
        if i < len(s) { i += 1 }
    }

    return
}

check_job :: proc(invalid_rule_map: ^bp.BitPairSet, job: [dynamic]u16) -> bool {
    for i in 0 ..< len(job) {
        for j in i + 1 ..< len(job) {
            if bp.unsafe_get(invalid_rule_map, job[i], job[j]) { return false }
        }
    }
    return true
}

solution := lib.Solution {
    day            = 05,
    input          = INPUT,
    part1          = part1,
    part2          = part2,
    expected_part1 = 6034,
    expected_part2 = 6305,
}

part1 :: proc(s: []u8) -> (result: u64) {
    invalid_rule_map, jobs := parse(s)
    defer {
        for job in jobs { delete(job) }
        delete(jobs)
        bp.destroy(&invalid_rule_map)
    }

    for job in jobs {
        if check_job(&invalid_rule_map, job) {
            result += u64(job[len(job) / 2])
        }
    }

    return
}

part2 :: proc(s: []u8) -> (result: u64) {
    invalid_rule_map, jobs := parse(s)
    defer {
        for job in jobs { delete(job) }
        delete(jobs)
        bp.destroy(&invalid_rule_map)
    }

    compare :: proc(a, b: u16) -> bool {
        invalid_rule_map := cast(^bp.BitPairSet)context.user_ptr
        return bp.unsafe_get(invalid_rule_map, a, b)
    }

    context.user_ptr = &invalid_rule_map
    for job in jobs {
        if !check_job(&invalid_rule_map, job) {
            slice.sort_by(job[:], compare)
            result += u64(job[len(job) / 2])
        }
    }

    return
}

/*
   tests -----------------------------
*/

@(test)
test_example_part1 :: proc(t: ^testing.T) {
    p1_example := part1(example_u8)
    expected: u64 = 143
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
    expected: u64 = 123
    testing.expect(t, p2_example == expected, fmt.tprintf("Expected result %d, got %d", expected, p2_example))
}

@(test)
test_part2 :: proc(t: ^testing.T) {
    p2 := part2(INPUT)
    expected := solution.expected_part2
    testing.expect(t, p2 == expected, fmt.tprintf("Expected result %d, got %d", expected, p2))
}

example_str := `47|53
97|13
97|61
97|47
75|29
61|13
75|53
29|13
97|29
53|29
61|53
97|53
61|29
47|13
75|47
97|75
47|61
75|61
47|29
75|13
53|13

75,47,61,53,29
97,61,53,29,13
75,29,13
75,97,47,61,53
61,13,29
97,13,75,29,47`

example_u8 := transmute([]u8)example_str
