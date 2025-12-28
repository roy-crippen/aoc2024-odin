package lib_grid

import sa "core:container/small_array"
import "core:fmt"
import "core:mem"
import "core:slice"
import "core:strings"
import "core:testing"

Grid :: struct($R, $C: int, $T: typeid) where R >= 1 && C >= 1 {
    _data: [R][C]T,
    rows:  int, // = R
    cols:  int, // = C
}

// ────────────────────────────────────────────────
// Creation
// ────────────────────────────────────────────────

// Creates a grid filled with the zero value of T
create_grid :: proc($R, $C: int, $T: typeid) -> Grid(R, C, T) {
    grid: Grid(R, C, T)
    grid.rows = R
    grid.cols = C
    // _data already zero-initialized
    return grid
}

// Creates a grid filled with the given value
create_grid_with_value :: proc($R, $C: int, $T: typeid, value: T) -> Grid(R, C, T) {
    grid: Grid(R, C, T)
    grid.rows = R
    grid.cols = C

    for &row in grid._data {
        for &cell in row {
            cell = value
        }
    }

    return grid
}

// ────────────────────────────────────────────────
// Accessors (bounds-checked)
// ────────────────────────────────────────────────

get :: proc(g: Grid($R, $C, $T), r, c: int) -> (value: T, ok: bool) {
    if r < 0 || r >= g.rows || c < 0 || c >= g.cols {
        return {}, false
    }
    value = g._data[r][c]
    return value, true
}

set :: proc(g: ^Grid($R, $C, $T), r, c: int, value: T) -> (ok: bool) {
    if r < 0 || r >= g.rows || c < 0 || c >= g.cols {
        return false
    }
    g._data[r][c] = value
    return true
}

// ────────────────────────────────────────────────
// Display
// ────────────────────────────────────────────────

// Basic multi-line string (each row using default %v formatting)
show :: proc(g: $A/Grid) -> (res_str: string) {
    context.allocator = context.temp_allocator

    b: strings.Builder
    strings.builder_init(&b)
    defer strings.builder_destroy(&b)

    for row, ri in g._data {
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
    for row in g._data {
        for v in row {
            w := len(fmt.tprintf("%v", v))
            if w > max_w {max_w = w}
        }
    }

    for row, ri in g._data {
        if ri > 0 {strings.write_byte(&b, '\n')}
        for v, ci in row {
            if ci > 0 {strings.write_string(&b, "  ")}
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

    for row, ri in g._data {
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
// Neighbors (very useful for AoC grid problems)
// ────────────────────────────────────────────────

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
// Tests
// ────────────────────────────────────────────────

@(test)
test_grid :: proc(t: ^testing.T) {
    // Zero-init
    g0 := create_grid(2, 3, i32)
    testing.expect(t, g0.rows == 2)
    testing.expect(t, g0.cols == 3)
    testing.expect(t, g0._data[0][0] == 0)

    // Value-init
    g1: Grid(3, 3, u8) = create_grid_with_value(3, 3, u8, '.')
    testing.expect(t, g1._data[1][1] == '.')

    // Accessors
    v, ok := get(g1, 1, 1)
    testing.expect(t, ok && v == '.')
    _, ok2 := get(g1, 10, 10)
    testing.expect(t, !ok2)

    ok = set(&g1, 1, 1, '#')
    testing.expect(t, g1._data[1][1] == '#')

    // Display
    // fmt.eprintln("\nbasic show:")
    // fmt.eprintln(show(g1))
    // fmt.eprintln("\npretty show:")
    // fmt.eprintln(show_pretty(g1))
    // fmt.eprintln("\npretty char show:")
    // fmt.eprintln(show_pretty_char(g1))

    // Neighbors
    nbs, ok_n := neighbors(g1, 1, 1, true)
    // fmt.eprintln(nbs)
    testing.expect(t, ok_n && len(nbs) == 8)
}
