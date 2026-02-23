package day_06

import "../lib"
import gr "../lib/grid"
import ba "core:container/bit_array"
import "core:fmt"
import "core:os"
import "core:sync"
import "core:testing"
import "core:thread"

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

// package scoped variables
loop_counter: u16

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

next_dr_dc_dir :: #force_inline proc "contextless" (dir: Dir) -> (int, int, Dir) {
    switch dir {
    case .N:
        return 0, 1, .E
    case .E:
        return 1, 0, .S
    case .S:
        return 0, -1, .W
    case .W:
        return -1, 0, .N
    }
    return 0, 0, dir // error
}

simulate_guard_path :: proc(
    g: gr.Grid(N, N, 1, byte),
    start_r, start_c: int,
    is_part2 := false,
) -> (
    route: [dynamic]State,
    unique_count: u64,
) {
    // setup visited bit array
    get_key := #force_inline proc "contextless" (st: State) -> int { return st.r * N + st.c }
    visited: ba.Bit_Array
    _ = ba.init(&visited, max_index = (N + 2) * (N + 2), min_index = 0)

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
    if is_part2 { append(&route, st) }


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
        key = get_key(st)
        if !ba.unsafe_get(&visited, key) {
            ba.unsafe_set(&visited, key)
            unique_count += 1

            // for part2 store the first occurance of position (with direction)
            if is_part2 { append(&route, st) }
        }
    }
    return
}

current_dr_dc :: proc "contextless" (dir: Dir) -> (int, int) {
    switch dir {
    case .N:
        return -1, 0
    case .E:
        return 0, 1
    case .S:
        return 1, 0
    case .W:
        return 0, -1
    }
    return 0, 0 // error
}

rc_dir_to_idx :: #force_inline proc "contextless" (st: State) -> int {
    return (st.r * N + st.c) * 4 + int(st.dir)
}

// checks if adding one new guard at `curr_st` creates a loop, thread safe
is_loop :: proc(g: gr.Grid(N, N, 1, byte), states: [2]State) -> u16 {
    st := states[0]
    new_guard_r, new_guard_c := states[1].r, states[1].c

    visited: ba.Bit_Array
    _ = ba.init(&visited, max_index = (N + 2) * (N + 2) * 4, min_index = 0, allocator = context.temp_allocator)
    key := rc_dir_to_idx(st)
    ba.unsafe_set(&visited, key)

    next_v: byte
    nr, nc: int
    dr, dc := current_dr_dc(st.dir)
    for {
        nr = st.r + dr
        nc = st.c + dc
        next_v = GUARD_CHAR if nc == new_guard_c && nr == new_guard_r else gr.unsafe_get(g, nr, nc)
        if next_v == BORDER_CHAR { return 0 }     // no loop
        if next_v == GUARD_CHAR {
            dr, dc, st.dir = next_dr_dc_dir(st.dir)
            continue
        }
        st.r = nr
        st.c = nc
        key = rc_dir_to_idx(st)
        #no_bounds_check {
            if ba.unsafe_get(&visited, key) { return 1 }     // loop found
            ba.unsafe_set(&visited, key)
        }
    }
}

solution := lib.Solution {
    day            = 06,
    input          = INPUT,
    part1          = part1,
    part2          = part2,
    expected_part1 = EXPECTED_PART1,
    expected_part2 = EXPECTED_PART2,
}

part1 :: proc(s: []u8) -> (result: u64) {
    g := gr.create_grid_from_bytes(N, N, 1, byte, s, pad_val = '$')
    start_pos, _ := gr.find_first_position(g, '^')
    _, unique_count := simulate_guard_path(g, start_pos[0], start_pos[1])
    return unique_count
}

part2 :: proc(s: []u8) -> (result: u64) {

    Loop_Task :: struct {
        grid:   ^gr.Grid(N, N, 1, byte),
        states: [2]State,
    }

    worker :: proc(task: thread.Task) {
        data := cast(^Loop_Task)task.data
        sync.atomic_add(&loop_counter, is_loop(data.grid^, data.states))
    }

    g := gr.create_grid_from_bytes(N, N, 1, byte, s, pad_val = '$')
    start_pos, _ := gr.find_first_position(g, '^')
    route, _ := simulate_guard_path(g, start_pos[0], start_pos[1], is_part2 = true)
    task_len := len(route) - 1

    pool: thread.Pool
    thread.pool_init(&pool, context.allocator, os.processor_core_count() - 1)
    thread.pool_start(&pool)

    tasks := make_slice([]Loop_Task, task_len)
    for i in 0 ..< len(route) - 1 {
        tasks[i] = Loop_Task {
            grid   = &g,
            states = {route[i], route[i + 1]},
        }
        thread.pool_add_task(&pool, context.allocator, worker, &tasks[i])
    }

    thread.pool_finish(&pool)
    thread.pool_destroy(&pool)
    return u64(loop_counter)

}

/*
   tests -----------------------------
*/

@(test)
test_part1 :: proc(t: ^testing.T) {
    context.allocator = context.temp_allocator
    p1 := part1(INPUT)
    testing.expect(t, p1 == EXPECTED_PART1, fmt.tprintf("Expected result %d, got %d", EXPECTED_PART1, p1))
}

@(test)
test_part2 :: proc(t: ^testing.T) {
    context.allocator = context.temp_allocator
    p2 := part2(INPUT)
    testing.expect(t, p2 == EXPECTED_PART2, fmt.tprintf("Expected result %d, got %d", EXPECTED_PART2, p2))
}
