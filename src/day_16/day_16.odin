package day_16

import "../lib"
import gr "../lib/grid"

EXAMPLE :: false
when EXAMPLE {
    N :: 15
    INPUT :: #load("example.txt", []u8)
    EXPECTED_PART1 :: 7036
    EXPECTED_PART2 :: 45
} else {
    N :: 141
    INPUT :: #load("day_16.txt", []u8)
    EXPECTED_PART1 :: 106512
    EXPECTED_PART2 :: 563
}
BIG :: max(int)
N_BUCKETS :: 64

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

is_valid_pos :: #force_inline proc "contextless" (pos: gr.Pos) -> bool {
    return pos[0] < N && pos[1] < N && pos[0] >= 0 && pos[1] >= 0
}

move_if_true :: proc "contextless" (node: Node) -> lib.Optional(Node) {
    next_pos := move_pos(node.pos, node.dir)
    if is_valid_pos(next_pos) && map_g.data[next_pos[0]][next_pos[1]] {
        return {{next_pos, node.dir, node.cost + 1}, true}
    }
    return {node, false}
}

rotate_dir_counter_90 :: proc "contextless" (dir: Dir) -> Dir {
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

rotate_dir_90 :: proc "contextless" (dir: Dir) -> Dir {
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

reverse_dir :: proc "contextless" (dir: Dir) -> Dir {
    switch dir {
    case .N:
        return .S
    case .W:
        return .E
    case .S:
        return .N
    case .E:
        return .W
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
                result = u64(bucket.cost)
                return
            }

            options = {
                move_if_true(bucket),
                lib.Optional(Node){{bucket.pos, rotate_dir_counter_90(bucket.dir), bucket.cost + 1000}, true},
                lib.Optional(Node){{bucket.pos, rotate_dir_90(bucket.dir), bucket.cost + 1000}, true},
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
    return
}

part2 :: proc(s: []u8) -> (result: u64) {
    start_pos, end_pos := parse(s)
    append_elem(&buckets[0], Node{start_pos, .E, 0})
    cost_g.data[start_pos[0]][start_pos[1]][Dir.E] = 0

    idx, cost: int
    bucket: Node
    pos: gr.Pos
    dir: Dir
    cs: ^[4]int
    options: [3]Node
    lowest := lib.Optional(int){-1, false}
    traversal: for {
        for len(buckets[idx % N_BUCKETS]) > 0 {
            bucket = pop(&buckets[idx % N_BUCKETS])
            if bucket.pos == end_pos {
                if lowest.ok {
                    if bucket.cost > lowest.value {
                        break traversal
                    }
                } else {
                    lowest = {bucket.cost, true}
                }
            }

            options = {
                {move_pos(bucket.pos, bucket.dir), bucket.dir, bucket.cost + 1},
                {bucket.pos, rotate_dir_counter_90(bucket.dir), bucket.cost + 1000},
                {bucket.pos, rotate_dir_90(bucket.dir), bucket.cost + 1000},
            }

            for option in options {
                pos, dir, cost = option.pos, option.dir, option.cost
                if is_valid_pos(pos) && map_g.data[pos[0]][pos[1]] {
                    cs = &cost_g.data[pos[0]][pos[1]]
                    if cost < cs[dir] {
                        cs[dir] = cost
                        append_elem(&buckets[cost % N_BUCKETS], option)
                    }
                }
            }
        }
        idx += 1
    }

    visted := gr.create_grid(N, N, 0, bool)
    gr.unsafe_set_pos(&visted, end_pos, true)
    if lowest.ok {
        queue := make_dynamic_array([dynamic]Node)
        for direction in 0 ..= 3 {
            if cost_g.data[end_pos[0]][end_pos[1]][direction] == lowest.value {
                append_elem(&queue, Node{end_pos, Dir(direction), lowest.value})
            }
        }

        for len(queue) > 0 {
            bucket = pop(&queue)

            if bucket.cost < 1 {
                continue
            }

            options = {
                {move_pos(bucket.pos, reverse_dir(bucket.dir)), bucket.dir, bucket.cost - 1},
                {bucket.pos, rotate_dir_counter_90(bucket.dir), bucket.cost - 1000},
                {bucket.pos, rotate_dir_90(bucket.dir), bucket.cost - 1000},
            }

            for option in options {
                pos, dir, cost = option.pos, option.dir, option.cost
                if is_valid_pos(pos) {
                    cs = &cost_g.data[pos[0]][pos[1]]
                    if cost == cs[dir] {
                        visted.data[pos[0]][pos[1]] = true
                        append_elem(&queue, option)
                    }
                }

            }

        }
    }

    for i in 0 ..< N {
        for j in 0 ..< N {
            if visted.data[i][j] do result += 1
        }
    }
    return
}
