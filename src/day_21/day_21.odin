package day_21

import "../lib"
import "core:bytes"
import sa "core:container/small_array"
import "core:fmt"
import "core:testing"

// port of: https://github.com/p88h/aoc2024/blob/main/src/day21.zig

EXAMPLE :: false
when EXAMPLE {
    INPUT :: #load("example.txt", []u8)
    EXPECTED_PART1 :: 126384
    EXPECTED_PART2 :: 154115708116294
} else {
    INPUT :: #load("day_21.txt", []u8)
    EXPECTED_PART1 :: 205160
    EXPECTED_PART2 :: 252473394928452
}

solution := lib.Solution {
    day            = 21,
    input          = INPUT,
    part1          = part1,
    part2          = part2,
    expected_part1 = EXPECTED_PART1,
    expected_part2 = EXPECTED_PART2,
}

expand1 :: #force_inline proc(from, to: u8) -> sa.Small_Array(2, string) {
    res: sa.Small_Array(2, string)

    switch from {
    case '<':
        switch to {
        case '^':
            sa.push_back(&res, ">^A")
        case 'v':
            sa.push_back(&res, ">A")
        case '>':
            sa.push_back(&res, ">>A")
        case 'A':
            sa.push_back(&res, ">>^A")
        case:
            sa.push_back(&res, "A")
        }

    case 'v':
        switch to {
        case '^':
            sa.push_back(&res, "^A")
        case '<':
            sa.push_back(&res, "<A")
        case '>':
            sa.push_back(&res, ">A")
        case 'A':
            sa.push_back(&res, ">^A")
            sa.push_back(&res, "^>A")
        case:
            sa.push_back(&res, "A")
        }

    case '>':
        switch to {
        case 'v':
            sa.push_back(&res, "<A")
        case '<':
            sa.push_back(&res, "<<A")
        case 'A':
            sa.push_back(&res, "^A")
        case '^':
            sa.push_back(&res, "^<A")
            sa.push_back(&res, "<^A")
        case:
            sa.push_back(&res, "A")
        }

    case '^':
        switch to {
        case 'v':
            sa.push_back(&res, "vA")
        case '<':
            sa.push_back(&res, "v<A")
        case 'A':
            sa.push_back(&res, ">A")
        case '>':
            sa.push_back(&res, ">vA")
            sa.push_back(&res, "v>A")
        case:
            sa.push_back(&res, "A")
        }

    case 'A':
        switch to {
        case '^':
            sa.push_back(&res, "<A")
        case '>':
            sa.push_back(&res, "vA")
        case 'v':
            sa.push_back(&res, "<vA")
            sa.push_back(&res, "v<A")
        case '<':
            sa.push_back(&res, "v<<A")
        case:
            sa.push_back(&res, "A")
        }

    case:
    // remains empty
    }

    return res
}

expand2 :: #force_inline proc(from, to: u8) -> sa.Small_Array(2, string) {
    res: sa.Small_Array(2, string)

    switch from {
    case '0':
        switch to {
        case '7':
            sa.push_back(&res, "^^^<A")
        case '8':
            sa.push_back(&res, "^^^A")
        case '9':
            sa.push_back(&res, "^^^>A")
            sa.push_back(&res, ">^^^A")
        case '4':
            sa.push_back(&res, "^^<A")
        case '5':
            sa.push_back(&res, "^^A")
        case '6':
            sa.push_back(&res, "^^>A")
            sa.push_back(&res, ">^^A")
        case '1':
            sa.push_back(&res, "^<A")
        case '2':
            sa.push_back(&res, "^A")
        case '3':
            sa.push_back(&res, "^>A")
            sa.push_back(&res, ">^A")
        case '0':
            sa.push_back(&res, "A")
        case 'A':
            sa.push_back(&res, ">A")
        }

    case '1':
        switch to {
        case '7':
            sa.push_back(&res, "^^A")
        case '8':
            sa.push_back(&res, "^^>A")
            sa.push_back(&res, ">^^A")
        case '9':
            sa.push_back(&res, "^^>>A")
            sa.push_back(&res, ">>^^A")
        case '4':
            sa.push_back(&res, "^A")
        case '5':
            sa.push_back(&res, "^>A")
            sa.push_back(&res, ">^A")
        case '6':
            sa.push_back(&res, "^>>A")
            sa.push_back(&res, ">>^A")
        case '1':
            sa.push_back(&res, "A")
        case '2':
            sa.push_back(&res, ">A")
        case '3':
            sa.push_back(&res, ">>A")
        case '0':
            sa.push_back(&res, ">vA")
        case 'A':
            sa.push_back(&res, ">>vA")
        }

    case '2':
        switch to {
        case '7':
            sa.push_back(&res, "^^<A")
            sa.push_back(&res, "<^^A")
        case '8':
            sa.push_back(&res, "^^A")
        case '9':
            sa.push_back(&res, "^^>A")
            sa.push_back(&res, ">^^A")
        case '4':
            sa.push_back(&res, "^<A")
            sa.push_back(&res, "<^A")
        case '5':
            sa.push_back(&res, "^A")
        case '6':
            sa.push_back(&res, "^>A")
            sa.push_back(&res, ">^A")
        case '1':
            sa.push_back(&res, "<A")
        case '2':
            sa.push_back(&res, "A")
        case '3':
            sa.push_back(&res, ">A")
        case '0':
            sa.push_back(&res, "vA")
        case 'A':
            sa.push_back(&res, ">vA")
            sa.push_back(&res, "v>A")
        }

    case '3':
        switch to {
        case '7':
            sa.push_back(&res, "^^<<A")
            sa.push_back(&res, "<<^^A")
        case '8':
            sa.push_back(&res, "^^<A")
            sa.push_back(&res, "<^^A")
        case '9':
            sa.push_back(&res, "^^A")
        case '4':
            sa.push_back(&res, "^<<A")
            sa.push_back(&res, "<<^A")
        case '5':
            sa.push_back(&res, "^<A")
            sa.push_back(&res, "<^A")
        case '6':
            sa.push_back(&res, "^A")
        case '1':
            sa.push_back(&res, "<<A")
        case '2':
            sa.push_back(&res, "<A")
        case '3':
            sa.push_back(&res, "A")
        case '0':
            sa.push_back(&res, "<vA")
            sa.push_back(&res, "v<A")
        case 'A':
            sa.push_back(&res, "vA")
        }

    case '4':
        switch to {
        case '7':
            sa.push_back(&res, "^A")
        case '8':
            sa.push_back(&res, "^>A")
            sa.push_back(&res, ">^A")
        case '9':
            sa.push_back(&res, ">>^A")
            sa.push_back(&res, "^>>A")
        case '4':
            sa.push_back(&res, "A")
        case '5':
            sa.push_back(&res, ">A")
        case '6':
            sa.push_back(&res, ">>A")
        case '1':
            sa.push_back(&res, "vA")
        case '2':
            sa.push_back(&res, "v>A")
            sa.push_back(&res, ">vA")
        case '3':
            sa.push_back(&res, ">>vA")
            sa.push_back(&res, "v>>A")
        case '0':
            sa.push_back(&res, ">vvA")
        case 'A':
            sa.push_back(&res, ">>vvA")
        }

    case '5':
        switch to {
        case '7':
            sa.push_back(&res, "^<A")
            sa.push_back(&res, "<^A")
        case '8':
            sa.push_back(&res, "^A")
        case '9':
            sa.push_back(&res, "^>A")
            sa.push_back(&res, ">^A")
        case '4':
            sa.push_back(&res, "<A")
        case '5':
            sa.push_back(&res, "A")
        case '6':
            sa.push_back(&res, ">A")
        case '1':
            sa.push_back(&res, "v<A")
            sa.push_back(&res, "<vA")
        case '2':
            sa.push_back(&res, "vA")
        case '3':
            sa.push_back(&res, "v>A")
            sa.push_back(&res, ">vA")
        case '0':
            sa.push_back(&res, "vvA")
        case 'A':
            sa.push_back(&res, ">vvA")
            sa.push_back(&res, "vv>A")
        }

    case '6':
        switch to {
        case '7':
            sa.push_back(&res, "<<^A")
            sa.push_back(&res, "^<<A")
        case '8':
            sa.push_back(&res, "^<A")
            sa.push_back(&res, "<^A")
        case '9':
            sa.push_back(&res, "^A")
        case '4':
            sa.push_back(&res, "<<A")
        case '5':
            sa.push_back(&res, "<A")
        case '6':
            sa.push_back(&res, "A")
        case '1':
            sa.push_back(&res, "<<vA")
            sa.push_back(&res, "v<<A")
        case '2':
            sa.push_back(&res, "v<A")
            sa.push_back(&res, "<vA")
        case '3':
            sa.push_back(&res, "vA")
        case '0':
            sa.push_back(&res, "<vvA")
            sa.push_back(&res, "vv<A")
        case 'A':
            sa.push_back(&res, "vvA")
        }

    case '7':
        switch to {
        case '7':
            sa.push_back(&res, "A")
        case '8':
            sa.push_back(&res, ">A")
        case '9':
            sa.push_back(&res, ">>A")
        case '4':
            sa.push_back(&res, "vA")
        case '5':
            sa.push_back(&res, ">vA")
            sa.push_back(&res, "v>A")
        case '6':
            sa.push_back(&res, ">>vA")
            sa.push_back(&res, "v>>A")
        case '1':
            sa.push_back(&res, "vvA")
        case '2':
            sa.push_back(&res, ">vvA")
            sa.push_back(&res, "vv>A")
        case '3':
            sa.push_back(&res, ">>vvA")
            sa.push_back(&res, "vv>>A")
        case '0':
            sa.push_back(&res, ">vvvA")
        case 'A':
            sa.push_back(&res, ">>vvvA")
        }

    case '8':
        switch to {
        case '7':
            sa.push_back(&res, "<A")
        case '8':
            sa.push_back(&res, "A")
        case '9':
            sa.push_back(&res, ">A")
        case '4':
            sa.push_back(&res, "v<A")
            sa.push_back(&res, "<vA")
        case '5':
            sa.push_back(&res, "vA")
        case '6':
            sa.push_back(&res, "v>A")
            sa.push_back(&res, ">vA")
        case '1':
            sa.push_back(&res, "vv<A")
            sa.push_back(&res, "<vvA")
        case '2':
            sa.push_back(&res, "vvA")
        case '3':
            sa.push_back(&res, "vv>A")
            sa.push_back(&res, ">vvA")
        case '0':
            sa.push_back(&res, "vvvA")
        case 'A':
            sa.push_back(&res, ">vvvA")
            sa.push_back(&res, "vvv>A")
        }

    case '9':
        switch to {
        case '7':
            sa.push_back(&res, "<<A")
        case '8':
            sa.push_back(&res, "<A")
        case '9':
            sa.push_back(&res, "A")
        case '4':
            sa.push_back(&res, "<<vA")
            sa.push_back(&res, "v<<A")
        case '5':
            sa.push_back(&res, "<vA")
            sa.push_back(&res, "v<A")
        case '6':
            sa.push_back(&res, "vA")
        case '1':
            sa.push_back(&res, "<<vvA")
            sa.push_back(&res, "vv<<A")
        case '2':
            sa.push_back(&res, "<vvA")
            sa.push_back(&res, "vv<A")
        case '3':
            sa.push_back(&res, "vvA")
        case '0':
            sa.push_back(&res, "<vvvA")
            sa.push_back(&res, "vvv<A")
        case 'A':
            sa.push_back(&res, "vvvA")
        }

    case 'A':
        switch to {
        case '7':
            sa.push_back(&res, "^^^<<A")
        case '8':
            sa.push_back(&res, "^^^<A")
            sa.push_back(&res, "<^^^A")
        case '9':
            sa.push_back(&res, "^^^A")
        case '4':
            sa.push_back(&res, "^^<<A")
        case '5':
            sa.push_back(&res, "^^<A")
            sa.push_back(&res, "<^^A")
        case '6':
            sa.push_back(&res, "^^A")
        case '1':
            sa.push_back(&res, "^<<A")
        case '2':
            sa.push_back(&res, "^<A")
            sa.push_back(&res, "<^A")
        case '3':
            sa.push_back(&res, "^A")
        case '0':
            sa.push_back(&res, "<A")
        case 'A':
            sa.push_back(&res, "A")
        }
    }

    return res
}

Ctx :: struct {
    lines: [5][4]u8,
    cache: map[u64]u64,
}

parse :: proc(s: []u8) -> (ctx: Ctx) {
    s_mut := s
    i: int
    for line in bytes.split_iterator(&s_mut, {'\n'}) {
        ctx.lines[i] = {line[0], line[1], line[2], line[3]}
        i += 1
    }
    ctx.cache = make_map(map[u64]u64)
    return
}

cache_key :: #force_inline proc(code: string, depth: int) -> u64 {
    ck: u64
    for ch in code {
        ck = (ck << 8) | u64(ch)
    }
    return (ck << 8) + u64(depth)
}

compute_length :: proc(ctx: ^Ctx, code: string, depth: int) -> (tot_len: u64) {
    ck := cache_key(code, depth)
    if depth == 0 do return u64(len(code))
    if ck in ctx.cache do return ctx.cache[ck]
    prev := 'A'
    for ch in code {
        candidates := expand1(u8(prev), u8(ch))
        min_len: u64
        for candidate in sa.slice(&candidates) {
            sub := compute_length(ctx, candidate, depth - 1)
            if min_len == 0 || sub < min_len do min_len = sub
        }
        prev = ch
        tot_len += min_len
    }
    ctx.cache[ck] = tot_len
    return
}

compute_top :: proc(ctx: ^Ctx, depth: int) -> (ctot: u64) {
    prev: u8 = 'A'
    for line in ctx.lines {
        tot_len, entry: u64
        for ch in line {
            if ch != 'A' do entry = entry * 10 + u64(int(ch - '0'))
            candidates := expand2(prev, ch)
            min_len: u64
            for candidate in sa.slice(&candidates) {
                sub := compute_length(ctx, candidate, depth - 1)
                if min_len == 0 || sub < min_len do min_len = sub
            }
            prev = ch
            tot_len += min_len
        }
        ctot += entry * tot_len
    }
    return
}

part1 :: proc(s: []u8) -> (result: u64) {
    ctx := parse(s)
    result = compute_top(&ctx, 3)
    return
}

part2 :: proc(s: []u8) -> (result: u64) {
    ctx := parse(s)

    // populate the ~top-level cache
    ctx.cache[cache_key("<A", 24)] = 9009012838
    ctx.cache[cache_key("A", 24)] = 1
    ctx.cache[cache_key("v<A", 24)] = 12192864309
    ctx.cache[cache_key(">>^A", 24)] = 10218188222
    ctx.cache[cache_key("v<<A", 24)] = 12192864310
    ctx.cache[cache_key(">^A", 24)] = 10218188221
    ctx.cache[cache_key(">A", 24)] = 5743602246
    ctx.cache[cache_key("<vA", 24)] = 11104086645
    ctx.cache[cache_key("^>A", 24)] = 9686334009
    ctx.cache[cache_key("vA", 24)] = 8357534516
    ctx.cache[cache_key("^A", 24)] = 5930403600
    ctx.cache[cache_key(">vA", 24)] = 10874983363
    ctx.cache[cache_key("v>A", 24)] = 9156556999
    ctx.cache[cache_key("^<A", 24)] = 12630544843
    ctx.cache[cache_key("<^A", 24)] = 11317884431

    result = compute_top(&ctx, 26)
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
