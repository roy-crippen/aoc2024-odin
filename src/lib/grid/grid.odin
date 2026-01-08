package lib_grid

import "core:mem"
import "core:testing"

// Grid: R=rows, C=cols, P=padding_count, T=grid_ty
Grid :: struct($R, $C, $P: int, $T: typeid) where R > 0 {
    data:    [R + 2 * P][C + 2 * P]T,
    rows:    int, // = R
    cols:    int, // = C
    pad_cnt: int, // = P
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
// creation
// ────────────────────────────────────────────────

// Creates a grid filled with the zero value of T
create_grid :: proc "contextless" ($R, $C, $P: int, $T: typeid) -> Grid(R, C, P, T) {
    grid: Grid(R, C, P, T)
    grid.rows = R + 2 * P
    grid.cols = C + 2 * P
    grid.pad_cnt = P
    return grid
}

// Creates a grid filled with the given value
create_grid_with_value :: proc "contextless" ($R, $C, $P: int, $T: typeid, value: T) -> Grid(R, C, P, T) {
    g := create_grid(R, C, P, T)
    mem.set(&g.data[0][0], transmute(u8)value, g.rows * g.cols)
    return g
}

// Creates a grid from slice 's' of type []byte
// Assumes each row is separated by '\n'
create_grid_from_bytes :: proc($R, $C, $P: int, $T: typeid, s: []u8, pad_val: u8 = '#') -> Grid(R, C, P, T) {
    // init whole grid with pad_val (fast bulk fill)
    g := create_grid_with_value(R, C, P, u8, pad_val)

    // overwrite inner grid only
    r, c: int = g.pad_cnt, g.pad_cnt
    for value in s {
        if value == '\n' {
            c = g.pad_cnt
            r += 1
            continue
        }
        g.data[r][c] = value
        c += 1
    }

    return g
}

// Creates a grid from slice 's' of type [][]T with padding size 0
create_grid_from_slice :: proc($R, $C, $P: int, $T: typeid, s: [][]T) -> Grid(R, C, P, T) {
    // validate R
    rows := len(s)
    assert(rows == R, "invalid input in call to create_grid")

    // validate C
    for &row in s { assert(len(row) == C, "grid is not rectangular") }

    g := create_grid(R, C, P, T)
    for row, r in s {
        for value, c in row {
            g.data[r][c] = value
        }
    }

    return g
}

// ────────────────────────────────────────────────
// accessors
// ────────────────────────────────────────────────

get :: proc "contextless" (g: Grid($R, $C, $P, $T), r, c: int) -> (value: T, ok: bool) {
    if r < 0 || r >= g.rows || c < 0 || c >= g.cols {
        return {}, false
    }
    value = g.data[r][c]
    return value, true
}

get_pos :: proc "contextless" (g: Grid($R, $C, $P, $T), pos: Pos) -> (value: T, ok: bool) {
    return get(g, pos[0], pos[1])
}

unsafe_get_pos :: #force_inline proc "contextless" (g: Grid($R, $C, $P, $T), pos: Pos) -> T {
    return g.data[pos[0]][pos[1]]
}

unsafe_get :: #force_inline proc "contextless" (g: Grid($R, $C, $P, $T), r, c: int) -> T {
    return g.data[r][c]
}


set :: proc "contextless" (g: ^Grid($R, $C, $P, $T), r, c: int, value: T) -> bool {
    if r < 0 || r >= g.rows || c < 0 || c >= g.cols {
        return false
    }
    g.data[r][c] = value
    return true
}

set_pos :: proc "contextless" (g: ^Grid($R, $C, $P, $T), pos: Pos, value: T) -> bool {
    return set(g, pos[0], pos[1], value)
}

unsafe_set_pos :: #force_inline proc "contextless" (g: ^Grid($R, $C, $P, $T), pos: Pos, value: T) {
    g.data[pos[0]][pos[1]] = value
}

unsafe_set :: #force_inline proc "contextless" (g: ^Grid($R, $C, $P, $T), r, c: int, value: T) {
    g.data[r][c] = value
}


// ────────────────────────────────────────────────
// neighbors
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
    r, c := move(pos[0], pos[1], dir)
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

directions_cardinal := [4][2]int{{-1, 0}, {1, 0}, {0, -1}, {0, 1}}
directions_diagonal := [4][2]int{{-1, -1}, {-1, 1}, {1, -1}, {1, 1}}
directions_all := [8][2]int{{-1, 0}, {1, 0}, {0, -1}, {0, 1}, {-1, -1}, {-1, 1}, {1, -1}, {1, 1}}

neighbors_8 :: proc(pos: Pos) -> (xs: [8]Pos) {
    r := pos[0]
    c := pos[1]
    for d, i in directions_all {
        xs[i] = {r + d[0], c + d[1]}
    }
    return
}

find_first_position :: proc(g: ^Grid($R, $C, $P, $T), v: T) -> (position: Pos, ok: bool) {
    for row, r in g.data {
        for val, c in row {
            if val == v {
                return {r, c}, true
            }
        }
    }
    return
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
show_pretty_char :: proc(g: Grid($R, $C, $P, u8)) -> string {
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
    g0 := create_grid(2, 3, 0, i32)
    testing.expect(t, g0.rows == 2)
    testing.expect(t, g0.cols == 3)
    testing.expect(t, g0.data[0][0] == 0)

    // Value-init
    g1: Grid(3, 3, 0, u8) = create_grid_with_value(3, 3, 0, u8, '.')
    testing.expect(t, g1.data[1][1] == '.')

    // Accessors
    v, ok := get_pos(g1, {1, 1})
    testing.expect(t, ok && v == '.')
    _, ok2 := get_pos(g1, {10, 10})
    testing.expect(t, !ok2)

    ok = set_pos(&g1, {1, 1}, '#')
    testing.expect(t, g1.data[1][1] == '#')


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
    g := create_grid_from_slice(2, 3, 0, u16, s)
    testing.expect(t, g.rows == 2)
    testing.expect(t, g.cols == 3)
    testing.expect(t, g.data[0][0] == 1)
}

@(test)
test_grid_create_grid_from_bytes :: proc(t: ^testing.T) {
    s: []u8 = {'.', '#', '.', '\n', '.', '.', '.'}
    g := create_grid_from_bytes(2, 3, 0, u8, s)
    testing.expect(t, g.rows == 2)
    testing.expect(t, g.cols == 3)
    testing.expect(t, g.data[0][1] == '#')

    // g1 := create_grid_from_bytes(2, 3, 1, u8, s)
    // log.info(lib.dbg(show_pretty_char(g1)))
}

@(test)
test_grid_padding :: proc(t: ^testing.T) {
    g0 := create_grid(2, 3, 2, i32)
    testing.expect(t, g0.rows == 6)
    testing.expect(t, g0.cols == 7)

    g1 := create_grid_with_value(3, 3, 1, u8, '.')
    testing.expect(t, g1.rows == 5)
    testing.expect(t, g1.cols == 5)
    testing.expect(t, g1.data[1][1] == '.')

    s: []u8 = {'.', '#', '.', '\n', '.', '.', '.'}
    g := create_grid_from_bytes(2, 3, 1, u8, s)
    testing.expect(t, g.rows == 4)
    testing.expect(t, g.cols == 5)
    testing.expect(t, g.data[1][1] == '.')
    testing.expect(t, g.data[1][2] == '#')


}

@(test)
test_neighbors_8 :: proc(t: ^testing.T) {
    expected: [8]Pos = {{0, 1}, {2, 1}, {1, 0}, {1, 2}, {0, 0}, {0, 2}, {2, 0}, {2, 2}}
    ns8 := neighbors_8({1, 1})
    testing.expect(t, ns8 == expected)
}

@(test)
test_usafe :: proc(t: ^testing.T) {
    s: []u8 = {'.', '#', '.', '\n', '.', '.', '.'}
    g := create_grid_from_bytes(2, 3, 0, u8, s)
    testing.expect(t, unsafe_get_pos(g, {0, 1}) == '#')
    unsafe_set_pos(&g, {0, 1}, '$')
    testing.expect(t, unsafe_get_pos(g, {0, 1}) == '$')
}
