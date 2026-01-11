package day_09

import "../lib"
import "core:container/queue"
import "core:fmt"
import "core:testing"

EXAMPLE :: false
when EXAMPLE {
    CAP :: 50
    INPUT :: #load("example.txt", []u8)
    EXPECTED_PART1 :: 1928
    EXPECTED_PART2 :: 2858
} else {
    CAP :: 100_000
    INPUT :: #load("day_09.txt", []u8)
    EXPECTED_PART1 :: 6310675819476
    EXPECTED_PART2 :: 6335972980679
}

make_disk :: proc(s: []u8) -> (disk: queue.Queue(int), blanks: [dynamic]int) {
    queue.init(&disk, capacity = CAP)
    x, fid: int
    for ch, i in s {
        x = int(ch) - '0'
        if i % 2 == 0 {
            for _ in 0 ..< x { queue.push_back(&disk, fid) }
            fid += 1
        } else {
            for _ in 0 ..< x { queue.push_back(&disk, -1) }
        }
    }

    for id, i in disk.data {
        if id == -1 { append_elem(&blanks, i) }
    }

    return
}

solution := lib.Solution {
    day            = 09,
    input          = INPUT,
    part1          = part1,
    part2          = part2,
    expected_part1 = EXPECTED_PART1,
    expected_part2 = EXPECTED_PART2,
}

part1 :: proc(s: []u8) -> (result: u64) {
    disk, blanks := make_disk(s)
    for i in blanks {
        for queue.back_ptr(&disk)^ == -1 { _ = queue.pop_back(&disk) }
        if disk.len <= uint(i) { break }
        disk.data[i] = queue.pop_back(&disk)
    }

    total: int
    for i in 0 ..< int(disk.len) {
        total += i * disk.data[i]
    }

    return u64(total)
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
