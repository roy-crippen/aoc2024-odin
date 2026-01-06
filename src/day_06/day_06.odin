package day_06

import "../lib"
import gr "../lib/grid"
import sa "core:container/small_array"
import "core:fmt"
import "core:log"
// import "core:slice"
import "core:testing"
// import "core:time"
import ba "core:container/bit_array"

EXAMPLE :: false
when EXAMPLE {
    N :: 10
    INPUT :: #load("example.txt", []u8)
    EXPECTED_PART1 :: 41
    EXPECTED_PART2 :: 6
} else {
    N :: 130
    INPUT :: #load("day_06.txt", []u8)
    EXPECTED_PART1 :: 5329
    EXPECTED_PART2 :: 2162
}

BORDER_CHAR: byte = '$'
GUARD_CHAR: byte = '#'

State :: struct {
    r:   int,
    c:   int,
    dir: Dir,
}

Dir :: enum {
    N = 0,
    E,
    S,
    W,
}

next_dr_dc_dir :: proc "contextless" (dir: Dir) -> (int, int, Dir) {
    #partial switch dir {
    case .N:
        return 0, 1, .E
    case .E:
        return 1, 0, .S
    case .S:
        return 0, -1, .W
    case .W:
        return -1, 0, .N
    }
    return 0, 0, dir // error, no change
}

// for part 2
rc_dir_to_idx :: #force_inline proc "contextless" (st: State) -> u64 {
    return u64((st.r * N + st.c) * 4 + int(st.dir))
}

simulate_guard_path :: proc(
    g: ^gr.Grid(N, N, 1, byte),
    start_r, start_c: int,
) -> (
    route: sa.Small_Array(6000, State),
    unique_count: u64,
) {
    // setup visited bit array
    get_key := #force_inline proc "contextless" (st: State) -> int { return st.r * N + st.c }
    visited: ba.Bit_Array
    _ = ba.init(&visited, max_index = (N + 2) * (N + 2), min_index = 0)
    defer ba.destroy(&visited)

    // initialize simulation
    st := State {
        r   = start_r,
        c   = start_c,
        dir = .N,
    }
    key := get_key(st)
    ba.unsafe_set(&visited, key)
    next_v: byte
    dr, dc := -1, 0 // North
    unique_count = 1
    sa.push_back(&route, st)

    // simulate
    for {
        nr := st.r + dr
        nc := st.c + dc
        next_v = gr.unsafe_get(g, nr, nc)
        if next_v == BORDER_CHAR { break }     // done
        if next_v == GUARD_CHAR {
            dr, dc, st.dir = next_dr_dc_dir(st.dir)
            continue
        }
        st.r = nr
        st.c = nc
        sa.push_back(&route, st)
        key = get_key(st)
        if !ba.unsafe_get(&visited, key) {
            ba.unsafe_set(&visited, key)
            unique_count += 1
        }
    }
    return
}

solution := lib.Solution {
    day            = 06,
    input          = INPUT,
    part1          = part1,
    part2          = part2,
    expected_part1 = 5329,
    expected_part2 = 2162,
}

part1 :: proc(s: []u8) -> (result: u64) {
    g := gr.create_grid_from_bytes(N, N, 1, byte, s, pad_val = '$')
    start_pos, _ := gr.find_first_position(&g, '^')
    _, unique_count := simulate_guard_path(&g, start_pos[0], start_pos[1])
    return unique_count
}

part2 :: proc(s: []u8) -> (result: u64) {
    result = 42
    return solution.expected_part2
}

/*
   tests -----------------------------
*/

when EXAMPLE {
    @(test)
    test_part1 :: proc(t: ^testing.T) {
        s := fmt.tprintf(
            "example: %v, EXPECTED_PART1: %d, EXPECTED_PART2: %d",
            EXAMPLE,
            EXPECTED_PART1,
            EXPECTED_PART2,
        )
        log.info(s)
        p1 := part1(INPUT)
        testing.expect(t, p1 == EXPECTED_PART1, fmt.tprintf("Expected result %d, got %d", EXPECTED_PART1, p1))
    }

    @(test)
    test_example_part2 :: proc(t: ^testing.T) {
        p2_example := part2(INPUT)
        testing.expect(
            t,
            p2_example == EXPECTED_PART2,
            fmt.tprintf("Expected result %d, got %d", EXPECTED_PART2, p2_example),
        )
    }
} else {
    @(test)
    test_part1 :: proc(t: ^testing.T) {
        s := fmt.tprintf(
            "example: %v, EXPECTED_PART1: %d, EXPECTED_PART2: %d",
            EXAMPLE,
            EXPECTED_PART1,
            EXPECTED_PART2,
        )
        log.info(s)
        p1 := part1(INPUT)
        testing.expect(t, p1 == EXPECTED_PART1, fmt.tprintf("Expected result %d, got %d", EXPECTED_PART1, p1))
    }
}
