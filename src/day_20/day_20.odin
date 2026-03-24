package day_20

import "../lib"
import "core:fmt"
import "core:math"
import "core:sync"
import "core:testing"
import "core:thread"

// port of: https://github.com/p88h/aoc2024/blob/main/src/day22.zig

EXAMPLE :: false
when EXAMPLE {
    N :: 15
    INPUT :: #load("example.txt", []u8)
    EXPECTED_PART1 :: 0
    EXPECTED_PART2 :: 42
} else {
    N :: 141
    INPUT :: #load("day_20.txt", []u8)
    EXPECTED_PART1 :: 1422
    EXPECTED_PART2 :: 1009299
}

solution := lib.Solution {
    day            = 20,
    input          = INPUT,
    part1          = part1,
    part2          = part2,
    expected_part1 = EXPECTED_PART1,
    expected_part2 = EXPECTED_PART2,
}

v_type :: i16
scnt :: 24 // threads
acc: int

Ctx :: struct {
    grid:             []u8,
    start, end:       [2]v_type,
    best:             v_type,
    dimx, dimy, qidx: int,
    que:              [dynamic][2]v_type,
    work1, work2:     [N * (N + 1)]v_type,
}

parse :: proc(s: []u8) -> (ctx: Ctx) {
    row, col: v_type
    for ch in s {
        switch ch {
        case '\n':
            row += 1
            col = -1
        case 'S':
            ctx.start = {row, col}
        case 'E':
            ctx.end = {row, col}
        }
        col += 1
    }

    ctx.grid = s
    ctx.dimx = N + 1
    ctx.dimy = N
    ctx.que = make_dynamic_array_len_cap([dynamic][2]v_type, 0, 9440)
    return
}

bfs :: proc(ctx: ^Ctx, start, end: [2]v_type, dist: ^[N * (N + 1)]v_type) -> v_type {
    dirs: [4][2]v_type = {{0, -1}, {0, 1}, {-1, 0}, {1, 0}}
    clear_dynamic_array(&ctx.que)
    idimx := v_type(ctx.dimx)
    spos := int(start[0] * idimx + start[1])
    dist[spos] = 1
    append_elem(&ctx.que, start)
    ctx.qidx = 0
    idx, ecnt: int
    for idx < len(ctx.que) {
        cur := ctx.que[idx]
        cpos := int(cur[0] * idimx + cur[1])
        if ctx.qidx == 0 && dist[cpos] > 100 do ctx.qidx = idx
        ecnt += 1
        idx += 1
        for move in dirs {
            next := cur + move
            npos := int(next[0] * idimx + next[1])
            if dist[npos] == 0 && ctx.grid[npos] != '#' {
                dist[npos] = dist[cpos] + 1
                append_elem(&ctx.que, next)
            }
        }
    }
    epos := int(end[0] * idimx + end[1])
    return dist[epos]
}

search_range :: proc(ctx: ^Ctx, shard, scnt: int, lim: v_type) -> (tot: int) {
    idimx := v_type(ctx.dimx)
    dlimit := ctx.best - 100
    cdim := v_type(ctx.dimy)
    dist1 := ctx.work1
    dist2 := ctx.work2
    cdist, dy, ay, dx, clen, ddist: v_type
    pos: [2]v_type
    cpos, dpos: int
    for i in ctx.qidx ..< len(ctx.que) {
        if i % scnt != shard do continue
        pos = ctx.que[i]
        cpos = int(pos[0] * idimx + pos[1])
        cdist = dist1[cpos]
        dy = -lim
        for ; dy <= lim; dy += 1 {
            ay = math.abs(dy)
            if pos[0] + dy < 1 do continue
            if pos[0] + dy >= cdim do break
            dx = -lim + ay
            for ; dx <= lim - ay; dx += 1 {
                clen = math.abs(dx) + math.abs(dy)
                if pos[1] + dx < 1 do continue
                if pos[1] + dx >= cdim do break
                dpos = int((pos[0] + dy) * idimx + pos[1] + dx)
                ddist = dist2[dpos]
                if ddist > 0 && cdist + ddist - 2 + clen <= dlimit do tot += 1
            }
        }
    }
    return
}

Search_Range_Task :: struct {
    ctx: ^Ctx,
    i:   int,
    lim: v_type,
}

worker :: proc(task: thread.Task) {
    data := cast(^Search_Range_Task)task.data
    res := search_range(data.ctx, data.i, scnt, data.lim)
    sync.atomic_add(&acc, res)
}

run_threaded :: proc(ctx: ^Ctx, lim: v_type) -> int {
    pool: thread.Pool
    thread.pool_init(&pool, context.allocator, scnt)
    thread.pool_start(&pool)

    sync.atomic_store(&acc, 0)

    tasks: [scnt]Search_Range_Task
    for i in 0 ..< scnt {
        tasks[i] = Search_Range_Task{ctx, i, lim}
    }

    for &task in tasks {
        thread.pool_add_task(
            &pool,
            allocator = context.allocator,
            procedure = worker,
            data = &task, // pointer to stack-allocated task → thread safe
            user_index = task.i, // useful for logging/debug
        )
    }

    thread.pool_finish(&pool)

    return acc
}


part1 :: proc(s: []u8) -> (result: u64) {
    ctx := parse(s)
    _ = bfs(&ctx, ctx.start, ctx.end, &ctx.work1) - 1
    ctx.best = bfs(&ctx, ctx.end, ctx.start, &ctx.work2) - 1
    return u64(run_threaded(&ctx, 2))
}

part2 :: proc(s: []u8) -> (result: u64) {
    ctx := parse(s)
    _ = bfs(&ctx, ctx.start, ctx.end, &ctx.work1) - 1
    ctx.best = bfs(&ctx, ctx.end, ctx.start, &ctx.work2) - 1
    return u64(run_threaded(&ctx, 20))
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
