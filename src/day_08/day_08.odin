package day_08

import "../lib"
import gr "../lib/grid"
import "core:fmt"
import "core:testing"

EXAMPLE :: false
when EXAMPLE {
    N :: 12
    INPUT :: #load("example.txt", []u8)
    EXPECTED_PART1 :: 14
    EXPECTED_PART2 :: 34
} else {
    N :: 50
    INPUT :: #load("day_08.txt", []u8)
    EXPECTED_PART1 :: 396
    EXPECTED_PART2 :: 1200
}


get_antennas :: proc(g: gr.Grid(N, N, 0, byte)) -> (m: map[u8][dynamic][2]int) {
    vals: [dynamic][2]int
    val: [2]int
    ok: bool
    m = make_map(map[u8][dynamic][2]int)
    for row, r in g.data {
        for ch, c in row {
            if ch != '.' {
                vals, ok = m[ch]
                if !ok { vals = make_dynamic_array([dynamic][2]int) }
                val = {r, c}
                append_elem(&vals, val)
                m[ch] = vals
            }
        }
    }
    return
}


solution := lib.Solution {
    day            = 08,
    input          = INPUT,
    part1          = part1,
    part2          = part2,
    expected_part1 = EXPECTED_PART1,
    expected_part2 = EXPECTED_PART2,
}

part1 :: proc(s: []u8) -> (result: u64) {
    g := gr.create_grid_from_bytes(N, N, 0, byte, s)
    antennas_m := get_antennas(g)
    antinodes_set := make_map(map[[2]int]struct{})
    r1, c1, r2, c2, nr, nc: int
    for _, vs in antennas_m {
        for i in 0 ..< len(vs) {
            for j in i + 1 ..< len(vs) {
                r1, c1 = vs[i][0], vs[i][1]
                r2, c2 = vs[j][0], vs[j][1]
                nr, nc = 2 * r1 - r2, 2 * c1 - c2
                if nr >= 0 && nr < g.rows && nc >= 0 && nc < g.cols { antinodes_set[{nr, nc}] = {} }
                nr, nc = 2 * r2 - r1, 2 * c2 - c1
                if nr >= 0 && nr < g.rows && nc >= 0 && nc < g.cols { antinodes_set[{nr, nc}] = {} }
            }
        }
    }
    result = u64(len(antinodes_set))
    return
}

part2 :: proc(s: []u8) -> (result: u64) {
    g := gr.create_grid_from_bytes(N, N, 0, byte, s)
    antennas_m := get_antennas(g)
    antinodes_set := make_map(map[[2]int]struct{})
    r, c, r1, c1, r2, c2, dr, dc: int
    for _, vs in antennas_m {
        for i in 0 ..< len(vs) {
            for j in 0 ..< len(vs) {
                if i == j { continue }
                r1, c1 = vs[i][0], vs[i][1]
                r2, c2 = vs[j][0], vs[j][1]
                dr = r2 - r1
                dc = c2 - c1
                r = r1
                c = c1
                for r >= 0 && r < g.rows && c >= 0 && c < g.cols {
                    antinodes_set[{r, c}] = {}
                    r += dr
                    c += dc
                }
            }
        }
    }
    result = u64(len(antinodes_set))
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
