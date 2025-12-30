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

check_xmas_in_dir :: proc "contextless" (g: gr.Grid(N, N, byte), pos: gr.Pos, dir: gr.Dir) -> u64 {
    m_pos := gr.move(pos, dir)
    m, m_ok := gr.get(g, m_pos)
    if !m_ok || m != 'M' { return 0 }

    a_pos := gr.move(m_pos, dir)
    a, a_ok := gr.get(g, a_pos)
    if !a_ok || a != 'A' { return 0 }

    s_pos := gr.move(a_pos, dir)
    s, s_ok := gr.get(g, s_pos)
    if !s_ok || s != 'S' { return 0 }

    return 1
}

cross_xmas :: proc "contextless" (g: gr.Grid(N, N, byte), pos: gr.Pos) -> u64 {
    // nw and se
    nw, nw_ok := gr.get(g, gr.north_west(pos))
    if !nw_ok { return 0 }
    se, se_ok := gr.get(g, gr.south_east(pos))
    if !se_ok { return 0 }
    nw_se_ok := (nw == 'M' && se == 'S') || (nw == 'S' && se == 'M')
    if !nw_se_ok { return 0 }

    // ne and sw
    ne, ne_ok := gr.get(g, gr.north_east(pos))
    if !ne_ok { return 0 }
    sw, sw_ok := gr.get(g, gr.south_west(pos))
    if !sw_ok { return 0 }
    ne_sw_ok := (ne == 'M' && sw == 'S') || (ne == 'S' && sw == 'M')
    if ne_sw_ok && nw_se_ok && ne_sw_ok { return 1 } else { return 0 }
}

part1 :: proc(s: []u8) -> (result: u64) {
    g := gr.create_grid_from_bytes(N, N, byte, s)

    pos: gr.Pos
    for r in 0 ..< N {
        for c in 0 ..< N {
            pos = {r, c}
            ch, ok := gr.get(g, pos)
            if ok && ch == 'X' {
                result += check_xmas_in_dir(g, pos, .N)
                result += check_xmas_in_dir(g, pos, .NW)
                result += check_xmas_in_dir(g, pos, .W)
                result += check_xmas_in_dir(g, pos, .SW)
                result += check_xmas_in_dir(g, pos, .S)
                result += check_xmas_in_dir(g, pos, .SE)
                result += check_xmas_in_dir(g, pos, .E)
                result += check_xmas_in_dir(g, pos, .NE)
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
            ch, ok := gr.get(g, pos)
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
