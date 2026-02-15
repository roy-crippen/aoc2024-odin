package day_18

import "../lib"
import gr "../lib/grid"
import "core:container/queue"
import "core:fmt"
import "core:testing"

N :: 71
SAFE_N :: 1024
ALL_N :: 3450
BIG :: 1000 * 1000
INPUT :: #load("day_18.txt", []u8)
EXPECTED_PART1 :: 276
EXPECTED_PART2 :: 2220

Cell1 :: struct {
    row, col, dist: int,
    blocked:        bool,
}

Cell2 :: struct {
    row, col, block_round, walk_round: int,
}

grid1: gr.Grid(N, N, 0, Cell1)
q1: queue.Queue(Cell1)

grid2: gr.Grid(N, N, 0, Cell2)
q2: queue.Queue(Cell2)
result_coordinates: [dynamic]int

parse1 :: proc(s: []u8) {
    grid1 = gr.create_grid(N, N, 0, Cell1)
    for line, row in grid1.data {
        for col in 0 ..< len(line) {
            grid1.data[row][col] = {row, col, BIG, false}
        }
    }

    i, j, k, row, col: int
    for _ in 0 ..< SAFE_N {
        for j = i; s[j] != ','; j += 1 {  }
        col = lib.unsafe_slice_u8_to_int(s[i:j])
        for k = j + 1; s[k] != '\n'; k += 1 {  }
        row = lib.unsafe_slice_u8_to_int(s[j + 1:k])
        grid1.data[row][col].blocked = true
        i = k + 1
    }
}

// encode :: #force_inline proc "contextless" (r, c: int) -> int { return r * N + c }

parse2 :: proc(s: []u8) {
    grid2 = gr.create_grid(N, N, 0, Cell2)
    for line, row in grid2.data {
        for col in 0 ..< len(line) {
            grid2.data[row][col] = {row, col, BIG, -1}
        }
    }

    result_coordinates = make_dynamic_array_len_cap([dynamic]int, 0, ALL_N)

    i, j, k, row, col: int
    for next_idx in 0 ..< ALL_N {
        for j = i; s[j] != ','; j += 1 {  }
        col = lib.unsafe_slice_u8_to_int(s[i:j])
        for k = j + 1; s[k] != '\n'; k += 1 {  }
        row = lib.unsafe_slice_u8_to_int(s[j + 1:k])
        grid2.data[row][col].block_round = next_idx
        append_elem(&result_coordinates, row * col)
        i = k + 1
    }
}

walk1 :: proc() {
    grid1.data[0][0].dist = 0
    queue.init(&q1, capacity = 80)
    queue.push_back(&q1, grid1.data[0][0])

    neighbor_cell, cc: Cell1
    ns: [4][2]int
    ok: bool
    row, col, dist: int
    for queue.len(q1) > 0 {
        cc = queue.pop_front(&q1)
        row, col, dist = cc.row, cc.col, cc.dist + 1
        ns = {{row - 1, col}, {row + 1, col}, {row, col - 1}, {row, col + 1}}
        for rc in ns {
            neighbor_cell, ok = gr.get_pos(grid1, rc)
            if ok && neighbor_cell.dist > dist && !neighbor_cell.blocked {
                grid1.data[rc[0]][rc[1]].dist = dist
                queue.push_back(&q1, grid1.data[rc[0]][rc[1]])
            }
        }
    }
}

walk2 :: proc(walk_round: int) -> bool {
    grid2.data[0][0].walk_round = walk_round
    queue.push_back(&q2, grid2.data[0][0])

    neighbor_cell, cc: Cell2
    ns: [4][2]int
    ok: bool
    row, col: int
    for queue.len(q2) > 0 {
        cc = queue.pop_front(&q2)
        row, col = cc.row, cc.col

        if row == N - 1 && col == N - 1 {
            return true
        }

        ns = {{row - 1, col}, {row + 1, col}, {row, col - 1}, {row, col + 1}}
        for rc in ns {
            neighbor_cell, ok = gr.get_pos(grid2, rc)
            if ok && neighbor_cell.block_round > walk_round && neighbor_cell.walk_round != walk_round {
                grid2.data[rc[0]][rc[1]].walk_round = walk_round
                queue.push_back(&q2, grid2.data[rc[0]][rc[1]])
            }
        }
    }
    return false
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
    parse1(s)
    walk1()
    return u64(grid1.data[N - 1][N - 1].dist)
}

part2 :: proc(s: []u8) -> (result: u64) {
    parse2(s)

    queue.init(&q2, capacity = 64)
    highest_free, lowest_blocked, mid: int
    lowest_blocked = ALL_N - 1
    for {
        if highest_free + 1 == lowest_blocked {
            result = u64(result_coordinates[lowest_blocked])
            break
        }
        mid = (highest_free + lowest_blocked) / 2
        queue.clear(&q2)
        if walk2(mid) {
            highest_free = mid
        } else {
            lowest_blocked = mid
        }
    }

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
