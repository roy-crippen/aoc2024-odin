package day_23

import "../lib"
import "core:bytes"
import "core:fmt"
import "core:slice"
import "core:testing"

EXAMPLE :: false
when EXAMPLE {
    INPUT :: #load("example.txt", []u8)
    LINES :: 32
    EXPECTED_PART1 :: 7
    EXPECTED_PART2 :: 11
} else {
    INPUT :: #load("day_23.txt", []u8)
    LINES :: 3380
    EXPECTED_PART1 :: 1000
    EXPECTED_PART2 :: 38 // len "cf,ct,cv,cz,fi,lq,my,pa,sl,tt,vw,wz,yd"
}

solution := lib.Solution {
    day            = 23,
    input          = INPUT,
    part1          = part1,
    part2          = part2,
    expected_part1 = EXPECTED_PART1,
    expected_part2 = EXPECTED_PART2,
}

Node :: struct {
    id:    u16,
    conns: [dynamic]u16,
}

Ctx :: struct {
    conns: [dynamic]u32,
    nodes: [1024]Node,
    com1:  [dynamic]u16,
    com2:  [dynamic]u16,
    com3:  [dynamic]u16,
}

parse :: proc(int_str: []u8) -> (ctx: Ctx) {
    ctx.conns = make_dynamic_array_len_cap([dynamic]u32, LINES, LINES)
    ecnt: [1024]int

    // each connection is 20-bits, 10-bits per node id (32x32 chars top)
    id: u32
    i: int
    for line in bytes.split(int_str, {'\n'}) {
        id = u32(line[0] - 'a' + 1)
        id = id * 32
        id += u32(line[1] - 'a' + 1)
        id = id * 32
        id += u32(line[3] - 'a' + 1)
        id = id * 32
        id += u32(line[4] - 'a' + 1)
        ecnt[id >> 10] += 1
        ecnt[id & 1023] += 1
        ctx.conns[i] = id
        i += 1
    }

    // build the nodes from the counts
    for s, id in ecnt {
        ctx.nodes[id].id = u16(id)
        if (s > 0) {
            ctx.nodes[id].conns = make_dynamic_array_len_cap([dynamic]u16, s + 1, s + 1)
            ctx.nodes[id].conns[0] = u16(id)
            ecnt[id] = 1
        } // else {
        //     ctx.nodes[id].conns.len = 0
    }

    // and once again, go through connections but now assign them to the nodes
    for conn in ctx.conns {
        id1 := u16(conn >> 10)
        id2 := u16(conn & 1023)
        n1 := ctx.nodes[id1]
        n2 := ctx.nodes[id2]
        n1.conns[ecnt[id1]] = id2
        ecnt[id1] += 1
        n2.conns[ecnt[id2]] = id1
        ecnt[id2] += 1
    }

    for node in ctx.nodes {
        if len(node.conns) > 0 do slice.sort(node.conns[:])
    }

    ctx.com1 = make_dynamic_array_len_cap([dynamic]u16, 16, 16)
    ctx.com2 = make_dynamic_array_len_cap([dynamic]u16, 16, 16)
    ctx.com3 = make_dynamic_array_len_cap([dynamic]u16, 16, 16)

    return
}

ordered_key :: proc(id1, id2, id3: u16) -> u32 {
    min_id := min(id1, id2, id3)
    max_id := max(id1, id2, id3)
    mid_id := id1 + id2 + id3 - min_id - max_id
    return u32(min_id) << 20 | u32(mid_id) << 10 | u32(max_id)
}

common_count :: proc(conn1, conn2, com: ^[dynamic]u16) -> (ccnt: u64) {
    p1, p2: u64
    resize_dynamic_array(com, 16)

    for p1 < u64(len(conn1)) && p2 < u64(len(conn2)) {
        if conn1[p1] == conn2[p2] {
            com[ccnt] = conn1[p1] // write common value
            ccnt += 1
            p1 += 1
            p2 += 1
        } else if conn1[p1] < conn2[p2] {
            p1 += 1
        } else {
            p2 += 1
        }
    }

    resize_dynamic_array(com, int(ccnt))
    return
}

find_clique :: proc(ctx: ^Ctx, id1, id2: u16, threshold: u64) -> (min_count: u64) {
    min_count = common_count(&ctx.nodes[id1].conns, &ctx.nodes[id2].conns, &ctx.com3)
    if min_count < threshold do return 0
    resize(&ctx.com1, min_count)
    copy(ctx.com1[:], ctx.com3[0:min_count])
    // check common connections across all id1 neighbors
    for id3 in ctx.com1 {
        if id3 == id2 do continue
        count1 := common_count(&ctx.com3, &ctx.nodes[id3].conns, &ctx.com2)
        if count1 < min_count {
            min_count = count1
            resize(&ctx.com3, count1)
            copy(ctx.com3[:], ctx.com2[0:count1])
        }
        if threshold > 0 && min_count <= threshold do break
    }
    if min_count > threshold {
        return
    }
    return 0
}

format_party :: proc(ctx: ^Ctx) -> (ret: [dynamic]u8) {
    cap := len(ctx.com3) * 3
    ret = make_dynamic_array_len_cap([dynamic]u8, cap, cap)
    slice.sort(ctx.com3[:])
    for id, p in ctx.com3 {
        if p > 0 do ret[p * 3 - 1] = ','
        ret[p * 3] = u8(int('a' - 1 + (id >> 5)))
        ret[p * 3 + 1] = u8(int('a' - 1 + (id & 31)))
    }
    ret[cap - 1] = 0
    return
}

part1 :: proc(s: []u8) -> (result: u64) {
    ctx := parse(s)
    done := make_map_cap(map[u32]bool, 1024)
    for conn in ctx.conns {
        id1 := u16(conn >> 10)
        id2 := u16(conn & 1023)
        // any of them starts with a 't' ?
        if (id1 >> 5) != 20 && (id2 >> 5) != 20 do continue
        count := common_count(&ctx.nodes[id1].conns, &ctx.nodes[id2].conns, &ctx.com1)
        if count == 0 do continue
        for id3 in ctx.com1 {
            if id3 == id1 || id3 == id2 do continue
            key := ordered_key(id1, id2, id3)
            _, ok := done[key]
            if !ok do done[key] = true
        }
    }
    result = u64(len(done))
    return
}

part2 :: proc(s: []u8) -> (result: u64) {
    ctx := parse(s)
    max: u64
    ret: [dynamic]u8
    for conn in ctx.conns {
        id1 := u16(conn >> 10)
        id2 := u16(conn & 1023)
        t := find_clique(&ctx, id1, id2, 12)
        if t > max {
            max = t
            ret = format_party(&ctx)
            if max == u64(len(ctx.nodes[id1].conns) - 1) do break
        }
    }
    result = u64(len(ret) - 1)
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
