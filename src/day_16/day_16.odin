package day_16

import "../lib"
import gr "../lib/grid"
import "core:fmt"
import "core:testing"

EXAMPLE :: false
when EXAMPLE {
    N :: 15
    N_BUCKETS :: 64
    INPUT :: #load("example.txt", []u8)
    EXPECTED_PART1 :: 7036
    EXPECTED_PART2 :: 45
} else {
    N :: 141
    N_BUCKETS :: 320
    INPUT :: #load("day_16.txt", []u8)
    EXPECTED_PART1 :: 106512
    EXPECTED_PART2 :: 563
}
BIG :: max(int)

Node :: struct {
    pos:  gr.Pos,
    dir:  Dir,
    cost: int,
}

Dir :: enum {
    N = 0,
    W,
    S,
    E,
}


map_g: gr.Grid(N, N, 0, bool)
cost_g: gr.Grid(N, N, 0, [4]int)
buckets: [N_BUCKETS][dynamic]Node // used as a circular array/queue

parse :: proc(s: []u8) -> (start_pos, end_pos: gr.Pos) {
    map_g = gr.allocate_grid_with_value(gr.Grid(N, N, 0, bool), true)
    cost_g = gr.allocate_grid_with_value(gr.Grid(N, N, 0, [4]int), [4]int{BIG, BIG, BIG, BIG})
    r, c: int
    for ch in s {
        switch ch {
        case '\n':
            {
                r += 1
                c = 0
                continue
            }
        case '#':
            map_g.data[r][c] = false
        case 'S':
            start_pos = gr.Pos{r, c}
        case 'E':
            end_pos = gr.Pos{r, c}
        }
        c += 1
    }

    for i in 0 ..< N_BUCKETS {
        buckets[i] = make_dynamic_array([dynamic]Node)
    }

    return
}

move_pos :: proc "contextless" (pos: gr.Pos, dir: Dir) -> gr.Pos {
    r, c := pos[0], pos[1]
    switch dir {
    case .N:
        return {r - 1, c}
    case .W:
        return {r, c - 1}
    case .S:
        return {r + 1, c}
    case .E:
        return {r, c + 1}
    }
    return {r, c}
}

move_if_true :: proc(node: Node) -> lib.Optional(Node) {
    next_pos := move_pos(node.pos, node.dir)
    if map_g.data[next_pos[0]][next_pos[1]] {
        return {{next_pos, node.dir, node.cost + 1}, true}
    }
    return {node, false}
}

rotate_counter_90 :: proc(dir: Dir) -> Dir {
    switch dir {
    case .N:
        return .W
    case .W:
        return .S
    case .S:
        return .E
    case .E:
        return .N
    }
    return dir
}

rotate_90 :: proc(dir: Dir) -> Dir {
    switch dir {
    case .N:
        return .E
    case .W:
        return .N
    case .S:
        return .W
    case .E:
        return .S
    }
    return dir
}

solution := lib.Solution {
    day            = 16,
    input          = INPUT,
    part1          = part1,
    part2          = part2,
    expected_part1 = EXPECTED_PART1,
    expected_part2 = EXPECTED_PART2,
}

part1 :: proc(s: []u8) -> (result: u64) {
    start_pos, end_pos := parse(s)
    append_elem(&buckets[0], Node{start_pos, .E, 0})
    cost_g.data[start_pos[0]][start_pos[1]][Dir.E] = 0

    idx, cost: int
    bucket: Node
    pos: gr.Pos
    dir: Dir
    cs: ^[4]int
    options: [3]lib.Optional(Node)
    for {
        for len(buckets[idx % N_BUCKETS]) > 0 {
            bucket = pop(&buckets[idx % N_BUCKETS])
            if bucket.pos == end_pos {
                return u64(bucket.cost)
            }

            options = {
                move_if_true(bucket),
                lib.Optional(Node){{bucket.pos, rotate_counter_90(bucket.dir), bucket.cost + 1000}, true},
                lib.Optional(Node){{bucket.pos, rotate_90(bucket.dir), bucket.cost + 1000}, true},
            }

            for option in options {
                if option.ok {
                    pos, dir, cost = option.value.pos, option.value.dir, option.value.cost
                    cs = &cost_g.data[pos[0]][pos[1]]
                    if cost < cs[dir] {
                        cs[dir] = cost
                        append_elem(&buckets[cost % N_BUCKETS], option.value)
                    }
                }
            }
        }
        idx += 1
    }

    result = EXPECTED_PART1
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
