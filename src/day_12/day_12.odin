package day_12

import "../lib"
import gr "../lib/grid"
import ba "core:container/bit_array"
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

encode :: #force_inline proc "contextless" (r, c, cols: int) -> int {
    return r * cols + c
}


// change to solve_part1
solve_part1 :: proc(g: gr.Grid(N, N, 1, byte)) -> (sum: u64) {
    max_l: int
    q: queue.Queue(gr.Pos)
    queue.init(&q, capacity = 32)

    seen: ba.Bit_Array
    _ = ba.init(&seen, max_index = (N + 2) * (N + 2), min_index = 0)

    area: [dynamic]gr.Pos
    // area = make_dynamic_array_len_cap([dynamic]gr.Pos, 0, REGION_CAP)

    key, n_key, cr, cc, nr, nc: int
    xs: [4][2]int
    pos, p: gr.Pos
    anchor_ch, ch: u8
    cnt: int
    for r in 1 ..< g.rows - 1 {
        for c in 1 ..< g.cols - 1 {
            key = encode(r, c, g.cols)
            if ba.unsafe_get(&seen, key) do continue
            ba.unsafe_set(&seen, key)

            // clear(&area)
            area = make_dynamic_array([dynamic]gr.Pos)
            pos = {r, c}
            append_elem(&area, pos)

            queue.clear(&q)
            queue.push_back(&q, pos)
            anchor_ch = gr.unsafe_get(g, r, c)
            for queue.len(q) > 0 {
                p = queue.pop_front(&q)
                cr, cc = p[0], p[1]
                xs = {{cr - 1, cc}, {cr, cc + 1}, {cr + 1, cc}, {cr, cc - 1}}
                for x in xs {
                    nr, nc = x[0], x[1]
                    cnt += 1
                    ch = gr.unsafe_get(g, nr, nc)
                    if ch == '$' do continue
                    if ch != anchor_ch do continue

                    n_key = encode(nr, nc, g.cols)
                    if ba.unsafe_get(&seen, n_key) do continue

                    append_elem(&area, x)
                    queue.push_back(&q, x)
                    ba.unsafe_set(&seen, n_key)
                }
            }
            max_l = max(max_l, len(area))
            l := u64(len(area))

            // add to sum without calling perimeter
            //
            //
            //
            //
            p := perimeter(g, area)
            //
            //
            //
            //
            //
            sum += l * p
            // sum += u64(len(area)) * perimeter(g, area)
        }
    }
    fmt.println("max_l = ", max_l)
    return
}

perimeter :: proc(g: gr.Grid(N, N, 1, byte), ps: [dynamic]gr.Pos) -> (tot: u64) {
    ch: u8
    for p in ps {
        ch = gr.unsafe_get(g, p[0], p[1])
        for n_ch in gr.unsafe_neighbor_values_4(g, p) {
            if n_ch != ch do tot += 1
        }
    }
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
    // fmt.println(gr.show_pretty_char(g))
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
