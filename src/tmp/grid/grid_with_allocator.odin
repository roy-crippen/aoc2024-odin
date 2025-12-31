package lib_grid

import "core:bytes"
//import sa "core:container/small_array"
import "core:log"
import "core:mem"
import "core:strings"
import "core:testing"
//import "core:fmt"

Grid :: struct($T: typeid) {
    data: [][]T,
    rows: int,
    cols: int,
}

//Pos :: [2]int
//Direction :: enum {
//    N,
//    NW,
//    W,
//    SW,
//    S,
//    SE,
//    E,
//    NE,
//}

// ────────────────────────────────────────────────
// Creation
// ────────────────────────────────────────────────

// Creates a grid filled with the zero value of T.
// Proc assumes that input byte rows are seperated by '\n'.
create_grid_u8 :: proc(input: []u8, allocator := context.allocator) -> Grid(u8) {
    lines := bytes.split(input, {'\n'}, allocator = context.temp_allocator)

    rows := len(lines)
    log.assert(rows > 0, "empty input in call to create_grid")
    cols := len(lines[0])

    // validate rectangular
    for &line in lines { log.assert(len(line) == cols, "grid is not rectangular") }

    // allocate and copy data
    grid: Grid(u8)
    grid.rows = rows
    grid.cols = cols
    grid.data = make([][]u8, rows, allocator)

    for line, i in lines {
        grid.data[i] = make([]u8, cols, allocator)
        copy(grid.data[i], line)
    }

    return grid
}


// // Creates a grid filled with the zero value of T
// create_grid :: proc($R, $C: int, $T: typeid) -> Grid(R, C, T) {
//     grid: Grid(R, C, T)
//     grid.rows = R
//     grid.cols = C
//     // _data already zero-initialized
//     return grid
// }

// // Creates a grid filled with the given value
// create_grid_with_value :: proc($R, $C: int, $T: typeid, value: T) -> Grid(R, C, T) {
//     grid: Grid(R, C, T)
//     grid.rows = R
//     grid.cols = C

//     for &row in grid._data {
//         for &cell in row {
//             cell = value
//         }
//     }

//     return grid
// }

// ────────────────────────────────────────────────
// Accessors (bounds-checked)
// ────────────────────────────────────────────────

get :: proc(g: Grid($T), r, c: int) -> (value: T, ok: bool) {
    if r < 0 || r >= g.rows || c < 0 || c >= g.cols {
        return {}, false
    }
    value = g.data[r][c]
    return value, true
}

set :: proc(g: ^Grid($T), r, c: int, value: T) -> (ok: bool) {
    if r < 0 || r >= g.rows || c < 0 || c >= g.cols {
        return false
    }
    g.data[r][c] = value
    return true
}

// // ────────────────────────────────────────────────
// // Display
// // ────────────────────────────────────────────────

// // Basic multi-line string (each row using default %v formatting)
// show :: proc(g: $A/Grid) -> (res_str: string) {
//     b: strings.Builder
//     strings.builder_init(&b, context.temp_allocator)
//     defer strings.builder_destroy(&b)

//     for row, ri in g._data {
//         if ri > 0 {
//             strings.write_byte(&b, '\n')
//         }
//         fmt.sbprint(&b, row)
//     }

//     return strings.to_string(b)
// }

// // Pretty-printed version with aligned columns
// show_pretty :: proc(g: $A/Grid) -> string {
//     b: strings.Builder
//     strings.builder_init(&b, context.temp_allocator)
//     defer strings.builder_destroy(&b)

//     // Find max width for alignment
//     max_w := 0
//     for row in g._data {
//         for v in row {
//             w := len(fmt.tprintf("%v", v))
//             if w > max_w {max_w = w}
//         }
//     }

//     for row, ri in g._data {
//         if ri > 0 {strings.write_byte(&b, '\n')}
//         for v, ci in row {
//             if ci > 0 {strings.write_string(&b, "  ")}
//             fmt.sbprintf(&b, "%*v", max_w, v)
//         }
//     }

//     return strings.to_string(b)
// }

// Prints u8 grid as characters with single space separator, no fancy alignment
// Very clean for mazes, tile maps, cellular automata, etc.
show_pretty_char :: proc(g: Grid(u8)) -> string {
    b: strings.Builder
    strings.builder_init(&b, context.temp_allocator)

    for row, ri in g.data {
        if ri > 0 {
            strings.write_byte(&b, '\n')
        }
        for cell, ci in row {
            if ci > 0 {
                strings.write_byte(&b, ' ')
            }
            strings.write_rune(&b, rune(cell))
        }
    }

    return strings.to_string(b)
}

// // ────────────────────────────────────────────────
// // Neighbors (very useful for AoC grid problems)
// // ────────────────────────────────────────────────

// directions_cardinal := [][2]int{{-1, 0}, {1, 0}, {0, -1}, {0, 1}}
// directions_diagonal := [][2]int{{-1, -1}, {-1, 1}, {1, -1}, {1, 1}}

// neighbors :: proc(g: $A/Grid, r, c: int, include_diagonal := false) -> (result: [][2]int, ok: bool) {
//     allocator := context.temp_allocator
//     defer free_all(allocator)
//     sa_dirs: sa.Small_Array(8, [2]int)

//     dirs := directions_cardinal[:]
//     if include_diagonal {
//         sa.push_back_elems(&sa_dirs, ..directions_cardinal[:])
//         sa.push_back_elems(&sa_dirs, ..directions_diagonal[:])
//         dirs = sa.slice(&sa_dirs)
//     }

//     sa.clear(&sa_dirs)

//     for d in dirs {
//         nr := r + d[0]
//         nc := c + d[1]
//         if nr >= 0 && nr < g.rows && nc >= 0 && nc < g.cols {
//             sa.push_back(&sa_dirs, [2]int{nr, nc})
//         }
//     }

//     count := sa.len(sa_dirs)
//     if count == 0 {
//         return
//     }

//     // Copy to returned slice (safe lifetime)
//     sl, err := make([][2]int, count, allocator)
//     if err != nil {
//         return
//     }
//     copy(sl, sa.slice(&sa_dirs))
//     return sl, true
// }

// // ────────────────────────────────────────────────
// // Tests
// // ────────────────────────────────────────────────

@(test)
test_grid :: proc(t: ^testing.T) {
    // create grid arena allocator
    buffer: [64]byte
    arena: mem.Arena
    mem.arena_init(&arena, buffer[:])
    grid_arena_allocator := mem.arena_allocator(&arena)
    defer mem.free_all(grid_arena_allocator)

    // Grid(u8) create
    s := "...\n.$.\n..."
    s_u8 := transmute([]u8)s
    g0: Grid(u8) = create_grid_u8(s_u8, grid_arena_allocator)
    testing.expect(t, g0.rows == 3)
    testing.expect(t, g0.cols == 3)
    testing.expect(t, g0.data[1][1] == '$')

    // Accessors
    v, ok := get(g0, 1, 1)
    testing.expect(t, ok && v == '$')
    _, ok2 := get(g0, 10, 10)
    testing.expect(t, !ok2)

    ok = set(&g0, 1, 1, '#')
    testing.expect(t, g0.data[1][1] == '#')

    // Display
    // log.info(strings.concatenate({"\nbasic show:\n", show(g1), "\n"}, context.temp_allocator))
    // log.info(strings.concatenate({"\npretty show:\n", show_pretty(g1), "\n"}, context.temp_allocator))
    log.info(strings.concatenate({"\npretty char show:\n", show_pretty_char(g0), "\n"}, context.temp_allocator))

    //     // Neighbors
    //     nbs, ok_n := neighbors(g1, 1, 1, true)
    //     // fmt.eprintln(nbs)
    //     testing.expect(t, ok_n && len(nbs) == 8)
}
