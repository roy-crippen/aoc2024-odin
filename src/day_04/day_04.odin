package day_04

import "../lib"
import gr "../lib/grid"
import "core:fmt"
import "core:testing"

INPUT :: #load("day_04.txt", []u8)
N :: 140

solution := lib.Solution {
    day            = 04,
    input          = INPUT,
    part1          = part1,
    part2          = part2,
    expected_part1 = 2573,
    expected_part2 = 1850,
}

cross_xmas :: proc "contextless" (g: gr.Grid(N, N, byte), pos: gr.Pos) -> u64 {
    // nw and se
    nw, nw_ok := gr.get_pos(g, gr.north_west(pos))
    if !nw_ok { return 0 }
    se, se_ok := gr.get_pos(g, gr.south_east(pos))
    if !se_ok { return 0 }
    nw_se_ok := (nw == 'M' && se == 'S') || (nw == 'S' && se == 'M')
    if !nw_se_ok { return 0 }

    // ne and sw
    ne, ne_ok := gr.get_pos(g, gr.north_east(pos))
    if !ne_ok { return 0 }
    sw, sw_ok := gr.get_pos(g, gr.south_west(pos))
    if !sw_ok { return 0 }
    ne_sw_ok := (ne == 'M' && sw == 'S') || (ne == 'S' && sw == 'M')
    if ne_sw_ok && nw_se_ok && ne_sw_ok { return 1 } else { return 0 }
}

part1 :: proc(s: []u8) -> (result: u64) {
    g := gr.create_grid_from_bytes(N, N, byte, s)
    mas: [3]u8 = {'M', 'A', 'S'}
    d8: [8]gr.Pos = {{-1, -1}, {-1, 0}, {-1, 1}, {0, -1}, {0, 1}, {1, -1}, {1, 0}, {1, 1}}

    pos: gr.Pos
    for r in 0 ..< N {
        for c in 0 ..< N {
            pos = {r, c}
            ch, ok := gr.get_pos(g, pos)
            if ok && ch == 'X' {
                for d in d8 {
                    failed := false
                    for test_val, i in mas {
                        dr, dc := d[0], d[1]
                        j := i + 1
                        move_pos: gr.Pos = {r + (dr * j), c + (dc * j)}
                        val, found := gr.get_pos(g, move_pos)
                        if !found || val != test_val {
                            failed = true
                            break
                        }
                    }
                    if !failed { result += 1 }
                }
            }
        }
    }

    return
}

part2 :: proc(s: []u8) -> (result: u64) {
    g := gr.create_grid_from_bytes(N, N, byte, s)

    pos: gr.Pos
    for r in 0 ..< N {
        for c in 0 ..< N {
            pos = {r, c}
            ch, ok := gr.get_pos(g, pos)
            if ok && ch == 'A' {
                result += cross_xmas(g, pos)
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
    p1 := part1(INPUT)
    expected := solution.expected_part1
    testing.expect(t, p1 == expected, fmt.tprintf("Expected result %d, got %d", expected, p1))
}

@(test)
test_part2 :: proc(t: ^testing.T) {
    p2 := part2(INPUT)
    expected := solution.expected_part2
    testing.expect(t, p2 == expected, fmt.tprintf("Expected result %d, got %d", expected, p2))
}
