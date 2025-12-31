package lib_grid

import sa "core:container/small_array"

//import "core:fmt"
//import "core:log"
//import "../../lib"

//import "core:mem"
//import "core:slice"
//import "core:strings"
import "core:testing"

Grid :: struct($R, $C: int, $T: typeid) where R > 0 {
    data: [R][C]T,
    rows: int, // = R
    cols: int, // = C
}

Pos :: [2]int
Dir :: enum {
    N,
    NW,
    W,
    SW,
    S,
    SE,
    E,
    NE,
}

// ────────────────────────────────────────────────
// Creation
// ────────────────────────────────────────────────

// Creates a grid filled with the zero value of T
create_grid :: proc "contextless" ($R, $C: int, $T: typeid) -> Grid(R, C, T) {
    grid: Grid(R, C, T)
    grid.rows = R
    grid.cols = C
    return grid
}

// Creates a grid filled with the given value
create_grid_with_value :: proc "contextless" ($R, $C: int, $T: typeid, value: T) -> Grid(R, C, T) {
    g := create_grid(R, C, T)
    for &row in g.data {
        for &cell in row {
            cell = value
        }
    }
    return g
}

// Creates a grid from slice 's' of type []byte
// Assumes each row is separated by '\n'
create_grid_from_bytes :: proc($R, $C: int, $T: typeid, s: []u8) -> Grid(R, C, T) {
    g := create_grid(R, C, u8)
    r, c: int
    for value in s {
        if value == '\n' {
            assert(c == g.cols, "grid is not rectangular")
            c = 0
            r += 1
            continue
        }
        g.data[r][c] = value
        c += 1
    }

    return g
}

// Creates a grid from slice 's' of type [][]T
create_grid_from_slice :: proc($R, $C: int, $T: typeid, s: [][]T) -> Grid(R, C, T) {
    // validate R
    rows := len(s)
    assert(rows == R, "invalid input in call to create_grid")

    // validate C
    for &row in s { assert(len(row) == C, "grid is not rectangular") }

    g := create_grid(R, C, T)
    r, c: int
    for row, r in s {
        for value, c in row {
            g.data[r][c] = value
        }
    }

    return g
}

// ────────────────────────────────────────────────
// Accessors (bounds-checked)
// ────────────────────────────────────────────────

//get :: proc "contextless" (g: Grid($R, $C, $T), r, c: int) -> (value: T, ok: bool) {
//    if r < 0 || r >= g.rows || c < 0 || c >= g.cols {
//        return {}, false
//    }
//    value = g.data[r][c]
//    return value, true
//}
//
//set :: proc "contextless" (g: ^Grid($R, $C, $T), r, c: int, value: T) -> bool {
//    if r < 0 || r >= g.rows || c < 0 || c >= g.cols {
//        return false
//    }
//    g.data[r][c] = value
//    return true
//}

get :: proc "contextless" (g: Grid($R, $C, $T), pos: Pos) -> (value: T, ok: bool) {
    r, c := pos[0], pos[1]
    if r < 0 || r >= g.rows || c < 0 || c >= g.cols {
        return {}, false
    }
    value = g.data[r][c]
    return value, true
}

set :: proc "contextless" (g: ^Grid($R, $C, $T), pos: Pos, value: T) -> bool {
    r, c := pos[0], pos[1]
    if r < 0 || r >= g.rows || c < 0 || c >= g.cols {
        return false
    }
    g.data[r][c] = value
    return true
}


// ────────────────────────────────────────────────
// Neighbors
// ────────────────────────────────────────────────


move :: proc "contextless" (r, c: int, dir: Dir) -> (int, int) {
    switch dir {
    case .N:
        return r - 1, c
    case .NW:
        return r - 1, c - 1
    case .W:
        return r, c - 1
    case .SW:
        return r + 1, c - 1
    case .S:
        return r + 1, c
    case .SE:
        return r + 1, c + 1
    case .E:
        return r, c + 1
    case .NE:
        return r - 1, c + 1
    }
    return r, c
}

move_pos :: proc "contextless" (pos: Pos, dir: Dir) -> Pos {
    in_r, in_c := pos[0], pos[1]
    r, c := move(in_r, in_c, dir)
    return {r, c}
}

north :: #force_inline proc "contextless" (pos: Pos) -> Pos { return move_pos(pos, .N) }
north_west :: #force_inline proc "contextless" (pos: Pos) -> Pos { return move_pos(pos, .NW) }
west :: #force_inline proc "contextless" (pos: Pos) -> Pos { return move_pos(pos, .W) }
south_west :: #force_inline proc "contextless" (pos: Pos) -> Pos { return move_pos(pos, .SW) }
south :: #force_inline proc "contextless" (pos: Pos) -> Pos { return move_pos(pos, .S) }
south_east :: #force_inline proc "contextless" (pos: Pos) -> Pos { return move_pos(pos, .SE) }
east :: #force_inline proc "contextless" (pos: Pos) -> Pos { return move_pos(pos, .E) }
north_east :: #force_inline proc "contextless" (pos: Pos) -> Pos { return move_pos(pos, .NE) }

directions_cardinal := [][2]int{{-1, 0}, {1, 0}, {0, -1}, {0, 1}}
directions_diagonal := [][2]int{{-1, -1}, {-1, 1}, {1, -1}, {1, 1}}

neighbors :: proc(
    g: $A/Grid,
    r, c: int,
    include_diagonal := false,
    allocator := context.temp_allocator,
) -> (
    result: [][2]int,
    ok: bool,
) {
    sa_dirs: sa.Small_Array(8, [2]int)

    dirs := directions_cardinal[:]
    if include_diagonal {
        sa.push_back_elems(&sa_dirs, ..directions_cardinal[:])
        sa.push_back_elems(&sa_dirs, ..directions_diagonal[:])
        dirs = sa.slice(&sa_dirs)
    }

    sa.clear(&sa_dirs)

    for d in dirs {
        nr := r + d[0]
        nc := c + d[1]
        if nr >= 0 && nr < g.rows && nc >= 0 && nc < g.cols {
            sa.push_back(&sa_dirs, [2]int{nr, nc})
        }
    }

    count := sa.len(sa_dirs)
    if count == 0 {
        return
    }

    // Copy to returned slice (safe lifetime)
    sl, err := make([][2]int, count, allocator)
    if err != nil {
        return
    }
    copy(sl, sa.slice(&sa_dirs))
    return sl, true
}

// ────────────────────────────────────────────────
// Display
// ────────────────────────────────────────────────

// Basic multi-line string (each row using default %v formatting)
show :: proc(g: $A/Grid) -> string {
    context.allocator = context.temp_allocator

    b: strings.Builder
    strings.builder_init(&b)
    defer strings.builder_destroy(&b)

    for row, ri in g.data {
        if ri > 0 {
            strings.write_byte(&b, '\n')
        }
        fmt.sbprint(&b, row)
    }

    return strings.to_string(b)
}

// Pretty-printed version with aligned columns
show_pretty :: proc(g: $A/Grid, allocator := context.allocator) -> string {
    b: strings.Builder
    strings.builder_init(&b, allocator)
    defer strings.builder_destroy(&b)

    // Find max width for alignment
    max_w := 0
    for row in g.data {
        for v in row {
            w := len(fmt.tprintf("%v", v))
            if w > max_w { max_w = w }
        }
    }

    for row, ri in g.data {
        if ri > 0 { strings.write_byte(&b, '\n') }
        for v, ci in row {
            if ci > 0 { strings.write_string(&b, "  ") }
            fmt.sbprintf(&b, "%*v", max_w, v)
        }
    }

    return strings.to_string(b)
}

// Prints u8 grid as characters with single space separator, no fancy alignment
// Very clean for mazes, tile maps, cellular automata, etc.
show_pretty_char :: proc(g: Grid($R, $C, u8)) -> string {
    context.allocator = context.temp_allocator

    b: strings.Builder
    strings.builder_init(&b)
    defer strings.builder_destroy(&b)

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

// ────────────────────────────────────────────────
// Tests
// ────────────────────────────────────────────────

@(test)
test_grid :: proc(t: ^testing.T) {
    // Zero-init
    g0 := create_grid(2, 3, i32)
    testing.expect(t, g0.rows == 2)
    testing.expect(t, g0.cols == 3)
    testing.expect(t, g0.data[0][0] == 0)

    // Value-init
    g1: Grid(3, 3, u8) = create_grid_with_value(3, 3, u8, '.')
    testing.expect(t, g1.data[1][1] == '.')

    // Accessors
    v, ok := get(g1, {1, 1})
    testing.expect(t, ok && v == '.')
    _, ok2 := get(g1, {10, 10})
    testing.expect(t, !ok2)

    ok = set(&g1, {1, 1}, '#')
    testing.expect(t, g1.data[1][1] == '#')

    // Neighbors
    nbs, ok_n := neighbors(g1, 1, 1, true)
    // fmt.eprintln(nbs)
    testing.expect(t, ok_n && len(nbs) == 8)

    // Display
    // fmt.eprintln("\nbasic show:")
    // fmt.eprintln(show(g1))
    // fmt.eprintln("\npretty show:")
    // fmt.eprintln(show_pretty(g1))
    // fmt.eprintln("\npretty char show:")
    // fmt.eprintln(show_pretty_char(g1))

}

@(test)
test_grid_create_grid_from_slice :: proc(t: ^testing.T) {
    s: [][]u16 = {{1, 2, 3}, {4, 5, 6}}
    g := create_grid_from_slice(2, 3, u16, s)
    testing.expect(t, g.rows == 2)
    testing.expect(t, g.cols == 3)
    testing.expect(t, g.data[0][0] == 1)
}

@(test)
test_grid_create_grid_from_bytes :: proc(t: ^testing.T) {
    s: []u8 = {'.', '#', '.', '\n', '.', '.', '.'}
    g := create_grid_from_bytes(2, 3, u8, s)
    testing.expect(t, g.rows == 2)
    testing.expect(t, g.cols == 3)
    testing.expect(t, g.data[0][1] == '#')
}
