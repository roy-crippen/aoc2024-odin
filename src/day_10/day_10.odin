package day_10

import "../lib"
import gr "../lib/grid"
import ba "core:container/bit_array"
import "core:container/queue"
import "core:fmt"
import "core:testing"

EXAMPLE :: false
when EXAMPLE {
    N :: 8
    INPUT :: #load("example.txt", []u8)
    EXPECTED_PART1 :: 36
    EXPECTED_PART2 :: 81
} else {
    N :: 52
    INPUT :: #load("day_10.txt", []u8)
    EXPECTED_PART1 :: 667
    EXPECTED_PART2 :: 1344
}

encode :: #force_inline proc "contextless" (r, c, cols: int) -> u64 {
    return u64(r * cols + c)
}

solution := lib.Solution {
    day            = 10,
    input          = INPUT,
    part1          = part1,
    part2          = part2,
    expected_part1 = EXPECTED_PART1,
    expected_part2 = EXPECTED_PART2,
}

part1 :: proc(s: []u8) -> (result: u64) {
    g := gr.create_grid_from_bytes(N, N, 0, byte, s)
    q: queue.Queue(gr.Pos)
    queue.init(&q, capacity = 8)

    seen: ba.Bit_Array
    _ = ba.init(&seen, max_index = N * N, min_index = 0)

    for pos in gr.find_positions(g, proc(v: u8) -> bool { return v == '0' }) {
        queue.clear(&q)
        queue.push_back(&q, pos)
        ba.clear(&seen)

        p: gr.Pos
        cr, cc, nr, nc: int
        was_seen: bool
        xs: [4][2]int
        for queue.len(q) > 0 {
            p = queue.pop_front(&q)
            cr, cc = p[0], p[1]
            xs = {{cr - 1, cc}, {cr, cc + 1}, {cr + 1, cc}, {cr, cc - 1}}
            for x in xs {
                nr, nc = x[0], x[1]
                if nr < 0 || nc < 0 || nr >= N || nc >= N { continue }
                if g.data[nr][nc] != g.data[cr][cc] + 1 { continue }
                idx := encode(nr, nc, N)

                // change to ba.unsafe_get
                was_seen, _ = ba.get(&seen, idx)

                if was_seen { continue }
                ba.set(&seen, idx)
                if g.data[nr][nc] == '9' {
                    result += 1
                } else {
                    queue.push_back(&q, gr.Pos{nr, nc})
                }
            }
        }

    }

    return
}

part2 :: proc(s: []u8) -> (result: u64) {
    g := gr.create_grid_from_bytes(N, N, 0, byte, s)
    q: queue.Queue([2]int)
    queue.init(&q, capacity = 8)
    seen: map[[2]int]u64
    seen = make_map_cap(map[[2]int]u64, capacity = 64)
    for pos in gr.find_positions(g, proc(v: u8) -> bool { return v == '0' }) {
        queue.clear(&q)
        queue.push_back(&q, pos)

        clear_map(&seen)
        seen[pos] = 1

        p: gr.Pos
        v: u64
        was_seen: bool
        cr, cc, nr, nc: int
        xs: [4][2]int
        for queue.len(q) > 0 {
            p = queue.pop_front(&q)
            cr, cc = p[0], p[1]
            if g.data[cr][cc] == '9' {
                v, _ = seen[p]
                result += v
            }
            xs = {{cr - 1, cc}, {cr, cc + 1}, {cr + 1, cc}, {cr, cc - 1}}
            for x in xs {
                nr, nc = x[0], x[1]
                if nr < 0 || nc < 0 || nr >= N || nc >= N { continue }
                if g.data[nr][nc] != g.data[cr][cc] + 1 { continue }

                _, was_seen = seen[x]
                v, _ = seen[p]
                if was_seen {
                    seen[x] += v
                    continue
                }
                seen[x] = v
                queue.push_back(&q, x)
            }
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
