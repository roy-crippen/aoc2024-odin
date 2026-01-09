package day_04

import "../lib"
import gr "../lib/grid"
import "core:fmt"
import "core:testing"

INPUT :: #load("day_04.txt", []u8)
PAD_CNT :: 3
N :: 140 + (2 * PAD_CNT)
BORDER_CHAR: byte = '$'

solution := lib.Solution {
    day            = 04,
    input          = INPUT,
    part1          = part1,
    part2          = part2,
    expected_part1 = 2573,
    expected_part2 = 1850,
}

cross_xmas :: proc "contextless" (g: gr.Grid(N, N, PAD_CNT, byte), pos: gr.Pos) -> u64 {
    // nw and se
    nw := gr.unsafe_get_pos(g, gr.north_west(pos))
    se := gr.unsafe_get_pos(g, gr.south_east(pos))
    nw_se_ok := (nw == 'M' && se == 'S') || (nw == 'S' && se == 'M')
    if !nw_se_ok { return 0 }

    // ne and sw
    ne := gr.unsafe_get_pos(g, gr.north_east(pos))
    sw := gr.unsafe_get_pos(g, gr.south_west(pos))
    ne_sw_ok := (ne == 'M' && sw == 'S') || (ne == 'S' && sw == 'M')
    if ne_sw_ok && nw_se_ok && ne_sw_ok { return 1 } else { return 0 }
}

part1 :: proc(s: []u8) -> (result: u64) {
    g := gr.create_grid_from_bytes(N, N, PAD_CNT, byte, s, pad_val = BORDER_CHAR)

    // flatten grid
    flat := ([^]byte)(&g.data[0][0])[:g.rows * g.cols]
    stride_row := g.cols

    // direction strides (delta in flat index)
    d8_strides: [8]int = {
        -stride_row - 1, // NW
        -stride_row, // N
        -stride_row + 1, // NE
        -1, // W
        +1, // E
        +stride_row - 1, // SW
        +stride_row, // S
        +stride_row + 1, // SE
    }

    idx, row_base: int
    for r in PAD_CNT ..< N - PAD_CNT {
        row_base = r * stride_row
        for c in PAD_CNT ..< N - PAD_CNT {
            idx = row_base + c
            if flat[idx] != 'X' { continue }

            for stride in d8_strides {
                if flat[idx + stride * 1] != 'M' { continue }
                if flat[idx + stride * 2] != 'A' { continue }
                if flat[idx + stride * 3] == 'S' { result += 1 }
            }
        }
    }

    return
}


part2 :: proc(s: []u8) -> (result: u64) {
    g := gr.create_grid_from_bytes(N, N, PAD_CNT, byte, s, pad_val = BORDER_CHAR)

    pos: gr.Pos
    for r in PAD_CNT ..< N - PAD_CNT {
        for c in PAD_CNT ..< N - PAD_CNT {
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
