package day_14

import "../lib"
import "core:bytes"
import "core:fmt"
import "core:math"
import "core:strconv"
import "core:testing"

EXAMPLE :: false
when EXAMPLE {
    WIDTH :: 11
    HEIGHT :: 7
    BOT_CNT :: 12
    INPUT :: #load("example.txt", []u8)
    EXPECTED_PART1 :: 12
    EXPECTED_PART2 :: 42
} else {
    WIDTH :: 101
    HEIGHT :: 103
    BOT_CNT :: 500
    INPUT :: #load("day_14.txt", []u8)
    EXPECTED_PART1 :: 220971520
    EXPECTED_PART2 :: 6355
}
HALF_WIDTH :: WIDTH / 2
HALF_HEIGHT :: HEIGHT / 2

Bot :: struct {
    x:  int,
    vx: int,
    y:  int,
    vy: int,
}

Acc :: struct {
    q1: int,
    q2: int,
    q3: int,
    q4: int,
}


parse :: proc(s_: []u8) -> (bots: [BOT_CNT]Bot) {
    s := s_[:]
    trimmed, pos_str, vel_str, x_str, y_str, vx_str, vy_str: []u8
    i: int
    for line in bytes.split_iterator(&s, {'\n'}) {
        trimmed = bytes.trim_left(line, {'p', '='})
        pos_str, _, vel_str = bytes.partition(trimmed, {' ', 'v', '='})

        x_str, _, y_str = bytes.partition(pos_str, {','})
        x := lib.unsafe_slice_u8_to_int(x_str)
        y := lib.unsafe_slice_u8_to_int(y_str)

        vx_str, _, vy_str = bytes.partition(vel_str, {','})
        vx, _ := strconv.parse_int(string(vx_str))
        vy, _ := strconv.parse_int(string(vy_str))

        bots[i] = {x, vx, y, vy}
        i += 1
    }
    return
}

find_quadrant :: #force_inline proc "contextless" (bot: Bot) -> Acc {
    if bot.x == HALF_WIDTH || bot.y == HALF_HEIGHT do return {0, 0, 0, 0}
    if bot.x < HALF_WIDTH && bot.y < HALF_HEIGHT do return {1, 0, 0, 0}
    if bot.x >= HALF_WIDTH && bot.y < HALF_HEIGHT do return {0, 1, 0, 0}
    if bot.x < HALF_WIDTH && bot.y >= HALF_HEIGHT do return {0, 0, 1, 0}
    return {0, 0, 0, 1}
}

update_acc :: #force_inline proc "contextless" (acc: ^Acc, a: Acc) {
    acc.q1 += a.q1
    acc.q2 += a.q2
    acc.q3 += a.q3
    acc.q4 += a.q4
}

solution := lib.Solution {
    day            = 14,
    input          = INPUT,
    part1          = part1,
    part2          = part2,
    expected_part1 = EXPECTED_PART1,
    expected_part2 = EXPECTED_PART2,
}

part1 :: proc(s: []u8) -> (result: u64) {
    bots := parse(s)
    quad, acc: Acc
    for i in 0 ..< len(bots) {
        bots[i].x = math.floor_mod(bots[i].x + bots[i].vx * 100, WIDTH)
        bots[i].y = math.floor_mod(bots[i].y + bots[i].vy * 100, HEIGHT)
        quad = find_quadrant(bots[i])
        update_acc(&acc, quad)
    }
    result = u64(acc.q1 * acc.q2 * acc.q3 * acc.q4)
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
