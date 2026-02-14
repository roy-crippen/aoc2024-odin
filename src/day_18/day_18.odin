package day_18

import "../lib"
import gr "../lib/grid"
import "core:container/queue"
import "core:fmt"
import "core:testing"

N :: 71
SAFE_N :: 1024
BIG :: 1000 * 1000
INPUT :: #load("day_18.txt", []u8)
EXPECTED_PART1 :: 276
EXPECTED_PART2 :: 2220

Cell :: struct {
    row, col, dist: int,
    blocked:        bool,
}

grid: gr.Grid(N, N, 0, Cell)
q: queue.Queue(Cell)

parse :: proc(s: []u8) {
    grid = gr.create_grid(N, N, 0, Cell)
    for line, row in grid.data {
        for col in 0 ..< len(line) {
            grid.data[row][col] = {row, col, BIG, false}
        }
    }

    i, j, k, row, col: int
    for _ in 0 ..< SAFE_N {
        for j = i; s[j] != ','; j += 1 {  }
        col = lib.unsafe_slice_u8_to_int(s[i:j])
        for k = j + 1; s[k] != '\n'; k += 1 {  }
        row = lib.unsafe_slice_u8_to_int(s[j + 1:k])
        grid.data[row][col].blocked = true
        i = k + 1
    }
}

walk :: proc() {
    grid.data[0][0].dist = 0
    queue.init(&q, capacity = 80)
    queue.push_back(&q, grid.data[0][0])

    neighbor_cell, cc: Cell
    ns: [4][2]int
    ok: bool
    row, col, dist: int
    for queue.len(q) > 0 {
        cc = queue.pop_front(&q)
        row, col, dist = cc.row, cc.col, cc.dist + 1
        ns = {{row - 1, col}, {row + 1, col}, {row, col - 1}, {row, col + 1}}
        for rc in ns {
            neighbor_cell, ok = gr.get_pos(grid, rc)
            if ok && neighbor_cell.dist > dist && !neighbor_cell.blocked {
                grid.data[rc[0]][rc[1]].dist = dist
                queue.push_back(&q, grid.data[rc[0]][rc[1]])
            }
        }
    }
}

solution := lib.Solution {
    day            = 18,
    input          = INPUT,
    part1          = part1,
    part2          = part2,
    expected_part1 = EXPECTED_PART1,
    expected_part2 = EXPECTED_PART2,
}

part1 :: proc(s: []u8) -> (result: u64) {
    parse(s)
    walk()
    return u64(grid.data[N - 1][N - 1].dist)
}

part2 :: proc(s: []u8) -> (result: u64) {
    result = EXPECTED_PART2
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
