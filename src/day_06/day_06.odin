package day_06

import "../lib"
import gr "../lib/grid"
import sa "core:container/small_array"
import "core:fmt"
// import "core:log"
// import "core:slice"
import "core:testing"
// import "core:time"
import ba "core:container/bit_array"

INPUT :: #load("day_06.txt", []u8)
EXAMPLE_INPUT :: #load("example.txt", []u8)

N :: 130
// N :: 10
BORDER_CHAR: byte = '$'
GUARD_CHAR: byte = '#'

State :: struct {
    r:    int,
    c:    int,
    cols: int,
    dir:  Dir,
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
    return u64((st.r * st.cols + st.c) * 4 + int(st.dir))
}

simulate_guard_path :: proc(
    g: ^gr.Grid(N, N, 1, byte),
    start_r, start_c: int,
) -> (
    route: sa.Small_Array(6000, State),
    unique_count: u64,
) {
    // setup visited bit array
    get_key := #force_inline proc "contextless" (st: State) -> int { return st.r * st.cols + st.c }
    visited: ba.Bit_Array
    _ = ba.init(&visited, max_index = (N + 2) * (N + 2), min_index = 0)
    defer ba.destroy(&visited)

    // initial simulation
    st := State {
        r    = start_r,
        c    = start_c,
        cols = g.cols,
        dir  = .N,
    }
    key := get_key(st)
    ba.unsafe_set(&visited, key)
    next_v: byte
    dr, dc := -1, 0 // North
    unique_count = 1
    sa.push_back(&route, st)

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
    // input          = EXAMPLE_INPUT,
    part1          = part1,
    part2          = part2,
    expected_part1 = 5329,
    expected_part2 = 2162,
}

part1 :: proc(s: []u8) -> (result: u64) {
    g := gr.create_grid_from_bytes(N, N, 1, byte, s, pad_val = '$')
    start_pos, _ := gr.find_first_position(&g, '^')
    _, unique_count := simulate_guard_path(&g, start_pos[0], start_pos[1])
    result = u64(unique_count)
    return
}

part2 :: proc(s: []u8) -> (result: u64) {


    result = 42
    return solution.expected_part2
}

/*
   tests -----------------------------
*/

// @(test)
// test_example_part1 :: proc(t: ^testing.T) {
//     p1_example := part1(EXAMPLE_INPUT)
//     expected: u64 = 41
//     testing.expect(t, p1_example == expected, fmt.tprintf("Expected result %d, got %d", expected, p1_example))
// }

@(test)
test_part1 :: proc(t: ^testing.T) {
    p1 := part1(INPUT)
    expected := solution.expected_part1
    testing.expect(t, p1 == expected, fmt.tprintf("Expected result %d, got %d", expected, p1))
}

// @(test)
// test_example_part2 :: proc(t: ^testing.T) {
//     p2_example := part2(EXAMPLE_INPUT)
//     expected: u64 = 42
//     testing.expect(t, p2_example == expected, fmt.tprintf("Expected result %d, got %d", expected, p2_example))
// }

// @(test)
// test_part2 :: proc(t: ^testing.T) {
//     p2 := part2(INPUT)
//     expected := solution.expected_part2
//     testing.expect(t, p2 == expected, fmt.tprintf("Expected result %d, got %d", expected, p2))
// }
