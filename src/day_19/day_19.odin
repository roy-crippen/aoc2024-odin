package day_19

import "../lib"
import "core:bytes"
import "core:fmt"
import "core:testing"

EXAMPLE :: false
when EXAMPLE {
    INPUT :: #load("example.txt", []u8)
    EXPECTED_PART1 :: 6
    EXPECTED_PART2 :: 16
} else {
    INPUT :: #load("day_19.txt", []u8)
    EXPECTED_PART1 :: 242
    EXPECTED_PART2 :: 595975512785325
}

index := [256]int {
    'b' = 0,
    'w' = 1,
    'u' = 2,
    'r' = 3,
    'g' = 4,
}

Trie :: struct {
    term: bool,
    n:    [5]int,
}

t: [dynamic]Trie

build_trie :: proc(patterns: []u8) {
    t = make_dynamic_array([dynamic]Trie)
    append_elem(&t, Trie{})
    ti, ch, ni: int
    for p in patterns {
        if p == ',' do continue
        if p == ' ' {
            t[ti].term = true
            ti = 0
            continue
        }
        ch = index[p]
        ni = t[ti].n[ch]
        if ni == 0 {
            ni = len(t)
            t[ti].n[ch] = ni
            append_elem(&t, Trie{})
        }
        ti = ni
    }
    t[ti].term = true
}

match_trie :: proc(towel: string, lengths: ^[dynamic]int) {
    for i, ti := 0, 0;; i += 1 {
        if t[ti].term {
            append_elem(lengths, i)
        }
        if i == len(towel) {
            break
        }
        ti = t[ti].n[index[towel[i]]]
        if ti == 0 {
            break
        }
    }
}

count :: proc(towel: string, ls: ^[dynamic]int) -> int {
    towel_len := len(towel) + 1
    d := make_dynamic_array_len_cap([dynamic]int, len = towel_len, cap = towel_len, allocator = context.temp_allocator)
    d[0] = 1
    for i := 0; i < len(towel); i += 1 {
        clear_dynamic_array(ls)
        match_trie(towel[i:], ls)
        for l in ls {
            d[i + l] += d[i]
        }
    }
    return d[len(d) - 1]
}


solution := lib.Solution {
    day            = 19,
    input          = INPUT,
    part1          = part1,
    part2          = part2,
    expected_part1 = EXPECTED_PART1,
    expected_part2 = EXPECTED_PART2,
}

part1 :: proc(s: []u8) -> (result: u64) {
    s_mut := s
    patterns, _ := bytes.split_iterator(&s_mut, {'\n'})
    build_trie(patterns)

    bytes.split_iterator(&s_mut, {'\n'}) // consume blank line

    bs: []u8
    ok: bool
    sum, cnt: int
    ls := make_dynamic_array_len_cap([dynamic]int, len = 0, cap = 64)
    for {
        bs, ok = bytes.split_iterator(&s_mut, {'\n'})
        if !ok do break
        cnt = count(string(bs), &ls)
        if cnt > 0 do sum += 1
    }
    return u64(sum)
}

part2 :: proc(s: []u8) -> (result: u64) {
    s_mut := s
    patterns, _ := bytes.split_iterator(&s_mut, {'\n'})
    build_trie(patterns)

    bytes.split_iterator(&s_mut, {'\n'}) // consume blank line

    bs: []u8
    ok: bool
    sum: int
    ls := make_dynamic_array_len_cap([dynamic]int, len = 0, cap = 64)
    for {
        bs, ok = bytes.split_iterator(&s_mut, {'\n'})
        if !ok do break
        sum += count(string(bs), &ls)
    }
    return u64(sum)
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
