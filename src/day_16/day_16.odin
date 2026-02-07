package day_16

import "../lib"
import gr "../lib/grid"
import "core:container/queue"
import "core:fmt"
import "core:testing"

EXAMPLE :: false
when EXAMPLE {
    N :: 15
    NQ :: 64

    INPUT :: #load("example.txt", []u8)
    EXPECTED_PART1 :: 7036
    EXPECTED_PART2 :: 45
} else {
    N :: 141
    NQ :: 768
    INPUT :: #load("day_16.txt", []u8)
    EXPECTED_PART1 :: 106512
    EXPECTED_PART2 :: 563
}

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

grid: gr.Grid(N, N, 0, u8)
seen_: [N][N][4]int : max(int)
seen := seen_


find_start_and_end :: proc(s: []u8) -> (start_pos, end_pos: gr.Pos) {
    r, c: int
    for ch in s {
        switch ch {
        case '\n':
            {
                r += 1
                c = 0
                continue
            }
        case 'S':
            start_pos = gr.Pos{r, c}
        case 'E':
            end_pos = gr.Pos{r, c}
        }
        c += 1
    }
    return
}

move_pos :: #force_inline proc "contextless" (pos: gr.Pos, dir: Dir) -> gr.Pos {
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

// is_valid_pos :: #force_inline proc "contextless" (pos: gr.Pos) -> bool {
//     return pos[0] < N && pos[1] < N && pos[0] >= 0 && pos[1] >= 0
// }
// rotate_dir_counter_90 :: proc "contextless" (dir: Dir) -> Dir {
//     switch dir {
//     case .N:
//         return .W
//     case .W:
//         return .S
//     case .S:
//         return .E
//     case .E:
//         return .N
//     }
//     return dir
// }

// rotate_dir_90 :: proc "contextless" (dir: Dir) -> Dir {
//     switch dir {
//     case .N:
//         return .E
//     case .W:
//         return .N
//     case .S:
//         return .W
//     case .E:
//         return .S
//     }
//     return dir
// }

dfs :: proc(first_q: ^queue.Queue(Node), second_q: ^queue.Queue(Node), lowest: ^int, end_pos: gr.Pos) {
    node, ok := queue.pop_front_safe(first_q)
    // fmt.println(node)
    if !ok {
        return
    }

    if node.cost >= lowest^ {
        dfs(first_q, second_q, lowest, end_pos)
        return
    }

    if node.pos == end_pos {
        lowest^ = node.cost
        dfs(first_q, second_q, lowest, end_pos)
        return
    }

    nodes := [3]Node {
        {move_pos(node.pos, node.dir), node.dir, node.cost + 1},
        {node.pos, Dir((int(node.dir) + 3) % 4), node.cost + 1000},
        {node.pos, Dir((int(node.dir) + 1) % 4), node.cost + 1000},
    }

    for n in nodes {
        if gr.unsafe_get_pos(grid, n.pos) != '#' && n.cost < seen[n.pos[0]][n.pos[1]][n.dir] {
            seen[n.pos[0]][n.pos[1]][n.dir] = n.cost
            if int(node.dir) == int(n.dir) {
                queue.push_back(first_q, n)
            } else {
                queue.push_back(second_q, n)
            }
        }
    }

    dfs(first_q, second_q, lowest, end_pos)
    return
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
    start_pos, end_pos := find_start_and_end(s)
    grid = gr.create_grid_from_bytes(N, N, 0, u8, s)

    first_q: queue.Queue(Node)
    queue.init(&first_q, capacity = NQ)
    second_q: queue.Queue(Node)
    queue.init(&second_q, capacity = NQ)
    lowest := max(int)


    seen[start_pos[0]][start_pos[1]][Dir.E] = 0
    queue.push_back(&first_q, Node{start_pos, .E, 0})
    for queue.len(first_q) != 0 {
        dfs(&first_q, &second_q, &lowest, end_pos)
        first_q, second_q = second_q, first_q
    }

    return u64(lowest)
}

part2 :: proc(s: []u8) -> (result: u64) {
    return EXPECTED_PART2
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
