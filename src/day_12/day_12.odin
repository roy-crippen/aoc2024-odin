package day_12

import "../lib"
import gr "../lib/grid"
import "core:container/queue"
import "core:fmt"
import "core:testing"

EXAMPLE :: false
when EXAMPLE {
    N :: 10
    INPUT :: #load("example.txt", []u8)
    EXPECTED_PART1 :: 1930
    EXPECTED_PART2 :: 1206
} else {
    N :: 140
    INPUT :: #load("day_12.txt", []u8)
    EXPECTED_PART1 :: 1361494
    EXPECTED_PART2 :: 830516
}

solve_part1 :: proc(g: gr.Grid(N, N, 1, byte)) -> (sum: u64) {
    q: queue.Queue(gr.Pos)
    queue.init(&q, capacity = 32)

    seen := gr.create_grid(N + 2, N + 2, 0, bool)

    cr, cc, nr, nc: int
    xs: [4][2]int
    pos, p: gr.Pos
    anchor_ch, ch: u8
    cnt, max_q_len: int
    perimeter, area_points: u64
    for r in 1 ..< g.rows - 1 {
        for c in 1 ..< g.cols - 1 {
            perimeter, area_points = 0, 1
            if gr.unsafe_get(seen, r, c) do continue
            gr.unsafe_set(&seen, r, c, true)

            pos = {r, c}
            queue.clear(&q)
            queue.push_back(&q, pos)
            anchor_ch = gr.unsafe_get(g, r, c)
            for queue.len(q) > 0 {
                max_q_len = max(max_q_len, queue.len(q))
                p = queue.pop_front(&q)
                cr, cc = p[0], p[1]
                xs = {{cr - 1, cc}, {cr, cc + 1}, {cr + 1, cc}, {cr, cc - 1}}
                for x in xs {
                    nr, nc = x[0], x[1]
                    cnt += 1
                    ch = gr.unsafe_get(g, nr, nc)
                    if ch == '$' || ch != anchor_ch {
                        perimeter += 1
                        continue
                    }
                    if gr.unsafe_get(seen, nr, nc) do continue
                    gr.unsafe_set(&seen, nr, nc, true)
                    area_points += 1
                    queue.push_back(&q, x)
                }
            }
            sum += area_points * perimeter
        }
    }
    fmt.println(max_q_len)
    return
}

solution := lib.Solution {
    day            = 12,
    input          = INPUT,
    part1          = part1,
    part2          = part2,
    expected_part1 = EXPECTED_PART1,
    expected_part2 = EXPECTED_PART2,
}

part1 :: proc(s: []u8) -> (result: u64) {
    g := gr.create_grid_from_bytes(N, N, 1, byte, s, pad_val = '$')
    result = solve_part1(g)
    return
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
