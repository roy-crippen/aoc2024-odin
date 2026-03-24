package day_22

import "../lib"
import "core:bytes"
import "core:fmt"
import "core:sync"
import "core:testing"
import "core:thread"

EXAMPLE :: false
when EXAMPLE {
    INPUT :: #load("example.txt", []u8)
    EXPECTED_PART1 :: 37327623
    EXPECTED_PART2 :: 24
} else {
    INPUT :: #load("day_22.txt", []u8)
    EXPECTED_PART1 :: 21147129593
    EXPECTED_PART2 :: 2445
}

solution := lib.Solution {
    day            = 22,
    input          = INPUT,
    part1          = part1,
    part2          = part2,
    expected_part1 = EXPECTED_PART1,
    expected_part2 = EXPECTED_PART2,
}

scnt :: 24 // threads
pcnt :: 19 * 19 * 19 * 19
pcnt_pad :: ((pcnt + 63) / 64) * 64
beam :: 4
acc: u64
Vec8 :: [8]u32
Ctx :: struct {
    secrets: [dynamic]Vec8,
    results: [dynamic]u16,
}

parse :: proc(s: []u8) -> (ctx: Ctx) {
    lines := bytes.split(s, {'\n'})
    ssize := (len(lines) + 7) / 8
    for ; ssize % beam != 0; ssize += 1 {  }
    ctx.secrets, _ = make_dynamic_array_len_cap([dynamic]Vec8, ssize, ssize)
    for line, i in lines {
        num: u32
        for ch in line do num = num * 10 + u32(ch - '0')
        ctx.secrets[i / 8][i % 8] = num
    }
    cap := pcnt_pad * scnt
    ctx.results, _ = make_dynamic_array_len_cap([dynamic]u16, cap, cap)
    return
}

hash_smash :: #force_inline proc(v: Vec8) -> (s: Vec8) {
    // this is a power of 2, so pruning becomes masking
    pm: Vec8 = {16777215, 16777215, 16777215, 16777215, 16777215, 16777215, 16777215, 16777215}
    // multiply by 64
    r: Vec8 = {v[0] << 6, v[1] << 6, v[2] << 6, v[3] << 6, v[4] << 6, v[5] << 6, v[6] << 6, v[7] << 6}
    // mix
    s = {r[0] ~ v[0], r[1] ~ v[1], r[2] ~ v[2], r[3] ~ v[3], r[4] ~ v[4], r[5] ~ v[5], r[6] ~ v[6], r[7] ~ v[7]}
    // prune
    s &= pm
    // divide by 32, mix and prune
    r = {s[0] >> 5, s[1] >> 5, s[2] >> 5, s[3] >> 5, s[4] >> 5, s[5] >> 5, s[6] >> 5, s[7] >> 5}
    s ~= r
    s &= pm
    // multiply by 2048, mix and prune
    r = {s[0] << 11, s[1] << 11, s[2] << 11, s[3] << 11, s[4] << 11, s[5] << 11, s[6] << 11, s[7] << 11}
    s ~= r
    s &= pm
    return
}

hash_smash_loop_1 :: proc(nums: []Vec8, cnt: int) -> Vec8 {
    vv: [4]Vec8
    copy(vv[:], nums[:4])
    for _ in 0 ..< cnt {
        for i in 0 ..< beam do vv[i] = hash_smash(vv[i])
    }
    for i in 1 ..< beam do vv[0] += vv[i]
    return vv[0]
}

v_10: Vec8 = {10, 10, 10, 10, 10, 10, 10, 10}
v_19: Vec8 = {19, 19, 19, 19, 19, 19, 19, 19}

hash_smash_v2 :: #force_inline proc(v: Vec8, h: ^Vec8) -> Vec8 {
    // previous last digits
    pd := v % v_10
    nv := hash_smash(v)
    // new last digits,
    d := nv % v_10
    // digits delta plus 10 to make it non-negative (range 1..19 each)
    z := (d + v_10) - pd
    // store price delta in history
    h^ = ({h[0] << 8, h[1] << 8, h[2] << 8, h[3] << 8, h[4] << 8, h[5] << 8, h[6] << 8, h[7] << 8}) + z
    return nv
}

pack_patterns :: #force_inline proc(pat: Vec8) -> (r: Vec8) {
    t := pat
    for _ in 0 ..< 4 {
        r = r * v_19 + (t & {255, 255, 255, 255, 255, 255, 255, 255}) - {1, 1, 1, 1, 1, 1, 1, 1}
        t = {t[0] >> 8, t[1] >> 8, t[2] >> 8, t[3] >> 8, t[4] >> 8, t[5] >> 8, t[6] >> 8, t[7] >> 8}
    }
    return r
}

hash_smash_loop_3 :: proc(nums: []Vec8, cnt: int, totals: ^[pcnt]u16) {
    // we'll process beam x 8 merchants at a time, using 32 bits for presence detection.
    history := make_dynamic_array_len_cap([dynamic]u32, len = pcnt, cap = pcnt, allocator = context.temp_allocator)
    v := nums
    // local history
    h: [beam]Vec8
    v_1_8: Vec8 = {0, 1, 2, 3, 4, 5, 6, 7}
    for k in 0 ..< cnt {
        for i in 0 ..< beam {
            v_b: Vec8 = {
                8 * u32(i),
                8 * u32(i),
                8 * u32(i),
                8 * u32(i),
                8 * u32(i),
                8 * u32(i),
                8 * u32(i),
                8 * u32(i),
            }
            v_s := v_b + v_1_8
            bits: Vec8 = {
                1 << v_s[0],
                1 << v_s[1],
                1 << v_s[2],
                1 << v_s[3],
                1 << v_s[4],
                1 << v_s[5],
                1 << v_s[6],
                1 << v_s[7],
            }
            v[i] = hash_smash_v2(v[i], &h[i])
            if k >= 3 {
                p := pack_patterns(h[i])
                for j in 0 ..< 8 {
                    // this pattern was not seen for this merchant
                    if history[p[j]] & bits[j] == 0 {
                        totals^[p[j]] += u16(v[i][j] % 10)
                        history[p[j]] |= bits[j]
                    }
                }
            }
        }
    }
}

max_pattern :: proc(totals: ^[pcnt]u16) -> u64 {
    midx: int
    for p in 1 ..< pcnt {
        if totals[p] > totals[midx] do midx = p
    }
    return u64(midx)
}

hash_smash_loop_shard :: proc(ctx: ^Ctx, shard: int, iter: int, p2: bool) -> (tot: u64) {
    ofs := shard * beam
    len := len(ctx.secrets)
    results := cast(^[pcnt]u16)(&ctx.results[shard * pcnt_pad])
    for ; ofs < len; ofs += scnt * beam {
        if p2 {
            hash_smash_loop_3(ctx.secrets[ofs:ofs + beam], iter, results)
        } else {
            rv := hash_smash_loop_1(ctx.secrets[ofs:ofs + beam], iter)
            t := rv[0] + rv[1] + rv[2] + rv[3] + rv[4] + rv[5] + rv[6] + rv[7]
            tot += u64(t)
        }
    }
    return
}

Run_Task :: struct {
    ctx:         ^Ctx,
    shard, iter: int,
    p2:          bool,
}

worker :: proc(task: thread.Task) {
    data := cast(^Run_Task)task.data
    res := hash_smash_loop_shard(data.ctx, data.shard, data.iter, data.p2)
    sync.atomic_add(&acc, res)
}

run_threaded :: proc(ctx: ^Ctx, iter: int, p2: bool) -> u64 {
    pool: thread.Pool
    thread.pool_init(&pool, context.allocator, scnt)
    thread.pool_start(&pool)

    sync.atomic_store(&acc, 0)

    tasks: [scnt]Run_Task
    for i in 0 ..< scnt {
        tasks[i] = Run_Task{ctx, i, iter, p2}
    }

    for &task in tasks {
        thread.pool_add_task(
            &pool,
            allocator = context.allocator,
            procedure = worker,
            data = &task, // pointer to stack-allocated task → thread safe
            user_index = task.shard, // useful for logging/debug
        )
    }

    thread.pool_finish(&pool)

    if !p2 {
        return acc
    }

    // part 2
    mmax: u16
    for p in 0 ..< pcnt {
        ct: u16
        for s in 0 ..< scnt do ct += ctx.results[s * pcnt_pad + p]
        if ct > mmax {
            mmax = ct
        }
    }
    return u64(mmax)
}

part1 :: proc(s: []u8) -> (result: u64) {
    ctx := parse(s)
    result = run_threaded(&ctx, 2000, false)
    return
}

part2 :: proc(s: []u8) -> (result: u64) {
    ctx := parse(s)
    result = run_threaded(&ctx, 2000, true)
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

@(test)
test_hulk_smash :: proc(t: ^testing.T) {
    v: Vec8
    v[0] = 123
    v = hash_smash(v)
    testing.expect(t, v[0] == 15887950)
    v = hash_smash(v)
    testing.expect(t, v[0] == 16495136)
    v = hash_smash(v)
    testing.expect(t, v[0] == 527345)
    v = hash_smash(v)
    testing.expect(t, v[0] == 704524)
    v = hash_smash(v)
    testing.expect(t, v[0] == 1553684)
    v = hash_smash(v)
    sum: u32
    for value in v do sum += value
    testing.expect(t, sum == 12683156)
}


@(test)
test_hulk_smash_many :: proc(t: ^testing.T) {
    nums: [beam]Vec8
    nums[0][0] = 1
    nums[0][5] = 10
    nums[1][1] = 100
    nums[1][4] = 2024
    rv := hash_smash_loop_1(nums[:], 2000)
    testing.expect(t, rv[0] == 8685429)
    testing.expect(t, rv[5] == 4700978)
    testing.expect(t, rv[1] == 15273692)
    testing.expect(t, rv[4] == 8667524)
    testing.expect(t, rv[2] == 0)
    testing.expect(t, rv[3] == 0)
    testing.expect(t, rv[7] == 0)
    testing.expect(t, rv[6] == 0)
    sum: u32
    for value in rv do sum += value
    testing.expect(t, sum == 37327623)
}

make_pattern :: #force_inline proc(a, b, c, d: u64) -> u32 {
    return u32((a << 24) + (b << 16) + (c << 8) + d)
}

@(test)
test_hash_smash_v2 :: proc(t: ^testing.T) {
    v, h: Vec8
    v[0] = 123
    v = hash_smash_v2(v, &h)
    v = hash_smash_v2(v, &h)
    v = hash_smash_v2(v, &h)
    v = hash_smash_v2(v, &h)
    testing.expect(t, h[0] == make_pattern(10 - 3, 10 + 6, 10 - 1, 10 - 1))
    v = hash_smash_v2(v, &h)
    v = hash_smash_v2(v, &h)
    v = hash_smash_v2(v, &h)
    v = hash_smash_v2(v, &h)
    testing.expect(t, h[0] == make_pattern(10, 10 + 2, 10 - 2, 10))
}

@(test)
test_hash_smash_loop_3 :: proc(t: ^testing.T) {
    nums: [beam]Vec8
    totals: [pcnt]u16
    nums[0] = Vec8{1, 2, 3, 2024, 0, 0, 0, 0}
    pat := make_pattern(10 - 2, 10 + 1, 10 - 1, 10 + 3)
    pats: Vec8 = {pat, pat, pat, pat, pat, pat, pat, pat}
    idx := pack_patterns(pats)[0]
    hash_smash_loop_3(nums[:], 2000, &totals)
    testing.expect(t, totals[idx] == 23)
    m := max_pattern(&totals)
    testing.expect(t, m == u64(idx))
}
