package day_15

import "../lib"
import gr "../lib/grid"
import "core:bytes"
import sa "core:container/small_array"
import "core:fmt"
import "core:sort"
import "core:testing"

EXAMPLE :: false
when EXAMPLE {
    N :: 10
    INPUT :: #load("example.txt", []u8)
    EXPECTED_PART1 :: 10092
    EXPECTED_PART2 :: 9021
} else {
    N :: 50
    INPUT :: #load("day_15.txt", []u8)
    EXPECTED_PART1 :: 1441031
    EXPECTED_PART2 :: 1425169
}

// used by part 1 and part 2 **************************************************

parse :: proc(s: []u8) -> (gr.Grid(N, N, 0, byte), []u8) {
    g_bytes, _, moves := bytes.partition(s, {'\n', '\n'})
    g := gr.create_grid_from_bytes(N, N, 0, byte, g_bytes)
    return g, moves
}

move :: proc(pos: gr.Pos, dir: byte) -> gr.Pos {
    r, c := pos[0], pos[1]
    switch dir {
    case '^':
        return {r - 1, c}
    case '>':
        return {r, c + 1}
    case 'v':
        return {r + 1, c}
    case '<':
        return {r, c - 1}
    }
    return {r, c}
}

compare_row_then_col_asc :: proc(a: gr.Pos, b: gr.Pos) -> int {
    if a[0] < b[0] do return -1
    if a[0] > b[0] do return 1

    // rows are equal → compare columns
    if a[1] < b[1] do return -1
    if a[1] > b[1] do return 1

    return 0
}

compare_row_then_col_desc :: proc(a: gr.Pos, b: gr.Pos) -> int {
    if b[0] < a[0] do return -1
    if b[0] > a[0] do return 1

    // rows are equal → compare columns
    if b[1] < a[1] do return -1
    if b[1] > a[1] do return 1

    return 0
}

compare_col_then_row_asc :: proc(a: gr.Pos, b: gr.Pos) -> int {
    if a[1] < b[1] do return -1
    if a[1] > b[1] do return 1

    // cols are equal → compare rows
    if a[0] < b[0] do return -1
    if a[0] > b[0] do return 1

    return 0
}

compare_col_then_row_desc :: proc(a: gr.Pos, b: gr.Pos) -> int {
    if b[1] < a[1] do return -1
    if b[1] > a[1] do return 1

    // cols are equal → compare rows
    if b[0] < a[0] do return -1
    if b[0] > a[0] do return 1

    return 0
}


score :: proc(ps: []gr.Pos) -> u64 {
    tot: int
    for p in ps do tot += p[0] * 100 + p[1]
    return u64(tot)
}

// used by part 1 *************************************************************

build_block1 :: proc(ps: ^sa.Small_Array(8, gr.Pos), g: gr.Grid(N, N, 0, byte), pos: gr.Pos, dir: u8) -> bool {
    ch := gr.unsafe_get_pos(g, pos)
    if ch == '.' do return true
    if ch == 'O' {
        sa.push_back(ps, pos)
        return build_block1(ps, g, move(pos, dir), dir)
    }
    return false
}

move_block1 :: proc(g: ^gr.Grid(N, N, 0, byte), ps: ^[]gr.Pos, dir: u8) {
    switch dir {
    case '^':
        sort.heap_sort_proc(ps^, compare_row_then_col_asc)
    case 'v':
        sort.heap_sort_proc(ps^, compare_row_then_col_desc)
    case '<':
        sort.heap_sort_proc(ps^, compare_col_then_row_asc)
    case '>':
        sort.heap_sort_proc(ps^, compare_col_then_row_desc)
    }

    for p in ps do gr.unsafe_swap(g, p, move(p, dir))
}

move_robot1 :: proc(ps: ^sa.Small_Array(8, gr.Pos), g: ^gr.Grid(N, N, 0, byte), robot_pos: ^gr.Pos, dir: u8) {
    next_robot_pos := move(robot_pos^, dir)
    switch gr.unsafe_get_pos(g^, next_robot_pos) {
    case '.':
        gr.unsafe_swap(g, robot_pos^, next_robot_pos)
        robot_pos^ = next_robot_pos
        return
    case 'O':
        sa.clear(ps)
        ok := build_block1(ps, g^, next_robot_pos, dir)
        if ok {
            sa.push_back(ps, robot_pos^)
            ps_slice := sa.slice(ps)
            move_block1(g, &ps_slice, dir)
            robot_pos^ = next_robot_pos
        }
        return
    }
    return
}

// used by part 2 *************************************************************

expand_grid :: proc(g: gr.Grid(N, N, 0, byte)) -> (ex_grid: gr.Grid(N, 2 * N, 0, byte)) {
    ex_grid = gr.create_grid_with_value(N, 2 * N, 0, byte, '.')
    for row, i in g.data {
        for ch, j in row {
            switch ch {
            case '#':
                ex_grid.data[i][2 * j] = '#'
                ex_grid.data[i][2 * j + 1] = '#'
            case 'O':
                ex_grid.data[i][2 * j] = '['
                ex_grid.data[i][2 * j + 1] = ']'
            case '@':
                ex_grid.data[i][2 * j] = '@'
            }
        }
    }

    return
}

build_block2 :: proc(ps: ^sa.Small_Array(256, gr.Pos), g: gr.Grid(N, 2 * N, 0, byte), pos: gr.Pos, dir: u8) -> bool {
    ch := gr.unsafe_get_pos(g, pos)
    if ch == '.' do return true
    if ch == '[' && (dir == '^' || dir == 'v') {
        sa.push_back(ps, pos)
        ok := build_block2(ps, g, move(pos, dir), dir)
        if ok {
            pos_east := move(pos, '>')
            sa.push_back(ps, pos_east)
            return build_block2(ps, g, move(pos_east, dir), dir)
        }
        return false
    }
    if ch == ']' && (dir == '^' || dir == 'v') {
        sa.push_back(ps, pos)
        ok := build_block2(ps, g, move(pos, dir), dir)
        if ok {
            pos_west := move(pos, '<')
            sa.push_back(ps, pos_west)
            return build_block2(ps, g, move(pos_west, dir), dir)
        }
        return false
    }
    if ch == 'O' || ch == '[' || ch == ']' {
        sa.push_back(ps, pos)
        return build_block2(ps, g, move(pos, dir), dir)
    }
    return false
}

remove_duplicates :: proc(s: ^[]gr.Pos) {
    if len(s^) <= 1 {
        return
    }

    write_idx := 1
    for i in 1 ..< len(s^) {
        if s^[i] != s^[write_idx - 1] {
            s^[write_idx] = s^[i]
            write_idx += 1
        }
    }
    s^ = s^[:write_idx]
}

move_block2 :: proc(g: ^gr.Grid(N, 2 * N, 0, byte), ps: ^[]gr.Pos, dir: u8) {
    switch dir {
    case '^':
        sort.heap_sort_proc(ps^, compare_row_then_col_asc)
        remove_duplicates(ps)
    case 'v':
        sort.heap_sort_proc(ps^, compare_row_then_col_desc)
        remove_duplicates(ps)
    case '<':
        sort.heap_sort_proc(ps^, compare_col_then_row_asc)
        remove_duplicates(ps)
    case '>':
        sort.heap_sort_proc(ps^, compare_col_then_row_desc)
        remove_duplicates(ps)
    }

    for p in ps do gr.unsafe_swap(g, p, move(p, dir))
}

move_robot2 :: proc(ps: ^sa.Small_Array(256, gr.Pos), g: ^gr.Grid(N, 2 * N, 0, byte), robot_pos: ^gr.Pos, dir: u8) {
    next_robot_pos := move(robot_pos^, dir)
    switch gr.unsafe_get_pos(g^, next_robot_pos) {
    case '.':
        gr.unsafe_swap(g, robot_pos^, next_robot_pos)
        robot_pos^ = next_robot_pos
        return
    case 'O', '[', ']':
        sa.clear(ps)
        ok := build_block2(ps, g^, next_robot_pos, dir)
        if ok {
            sa.push_back(ps, robot_pos^)
            ps_slice := sa.slice(ps)
            move_block2(g, &ps_slice, dir)
            robot_pos^ = next_robot_pos
        }
        return
    }
    return
}

// solution *******************************************************************

solution := lib.Solution {
    day            = 15,
    input          = INPUT,
    part1          = part1,
    part2          = part2,
    expected_part1 = EXPECTED_PART1,
    expected_part2 = EXPECTED_PART2,
}

part1 :: proc(s: []u8) -> (result: u64) {
    g, moves := parse(s)

    // apply movements
    ps: sa.Small_Array(8, gr.Pos)
    robot_pos, _ := gr.find_first_position(g, '@')
    for dir in moves {
        move_robot1(&ps, &g, &robot_pos, dir)
    }

    // calculate score
    box_ps := gr.find_positions(g, proc(v: u8) -> bool { return v == 'O' })
    result = score(box_ps)
    return
}

part2 :: proc(s: []u8) -> (result: u64) {
    g_small, moves := parse(s)
    g := expand_grid(g_small)

    // apply movements
    ps: sa.Small_Array(256, gr.Pos)
    robot_pos, _ := gr.find_first_position(g, '@')
    for dir in moves {
        move_robot2(&ps, &g, &robot_pos, dir)
    }

    // calculate score
    box_ps := gr.find_positions(g, proc(v: u8) -> bool { return v == 'O' || v == '[' })
    result = score(box_ps)
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


@(test)
test_remove_duplicates :: proc(t: ^testing.T) {
    s: [][2]int = {{2, 3}, {3, 4}, {3, 4}, {4, 5}}
    expected: [][2]int = {{2, 3}, {3, 4}, {4, 5}}
    remove_duplicates(&s)
    testing.expect(t, s[0] == expected[0])
    testing.expect(t, s[1] == expected[1])
    testing.expect(t, s[2] == expected[2])
}
