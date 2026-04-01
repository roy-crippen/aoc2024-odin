package day_24

import "../lib"
import "core:bytes"
import "core:fmt"
import "core:slice"
import "core:testing"

EXAMPLE :: false
when EXAMPLE {
    INPUT :: #load("example.txt", []u8)
    EXPECTED_PART1 :: 2024
    EXPECTED_PART2 :: 42
} else {
    INPUT :: #load("day_24.txt", []u8)
    EXPECTED_PART1 :: 56939028423824
    EXPECTED_PART2 :: 57488782206064 // [(frn, z05), (wnf, vtj), (z21, gmq), (wtt, z39)] => frn,gmq,vtj,wnf,wtt,z05,z21,z39
}

solution := lib.Solution {
    day            = 24,
    input          = INPUT,
    part1          = part1,
    part2          = part2,
    expected_part1 = EXPECTED_PART1,
    expected_part2 = EXPECTED_PART2,
}

Op :: enum {
    AND,
    OR,
    XOR,
}

Gate :: struct {
    op:                  Op,
    wire1, wire2, wire3: [3]u8,
}

Ctx :: struct {
    all_wires:       map[[3]u8]int,
    gates_to_run:    [dynamic]Gate,
    remaining_gates: [dynamic]Gate,
}

to_op :: proc(s: []u8) -> Op {
    switch slice.to_type(s, [2]u8) {
    case {'A', 'N'}:
        return Op.AND
    case {'X', 'O'}:
        return Op.XOR
    case:
        return Op.OR
    }
}

parse :: proc(s: []u8) -> (ctx: Ctx) {
    ctx.gates_to_run = make_dynamic_array([dynamic]Gate)
    ctx.remaining_gates = make_dynamic_array_len_cap([dynamic]Gate, 0, 256)
    ctx.all_wires = make_map(map[[3]u8]int)
    sections := bytes.split(s, {'\n', '\n'})
    for line in bytes.split(sections[1], {'\n'}) {
        parts := bytes.split(line, {' '})
        wire1, _ := slice.to_type(parts[0], [3]u8)
        wire2, _ := slice.to_type(parts[2], [3]u8)
        wire3, _ := slice.to_type(parts[4], [3]u8)
        gate := Gate {
            op    = to_op(parts[1]),
            wire1 = wire1,
            wire2 = wire2,
            wire3 = wire3,
        }
        append(&ctx.gates_to_run, gate)
        ctx.all_wires[wire1] = -1
        ctx.all_wires[wire2] = -1
        ctx.all_wires[wire2] = -1
    }

    for line in bytes.split(sections[0], {'\n'}) {
        parts := bytes.split(line, {':', ' '})
        wire := slice.to_type(parts[0], [3]u8)
        value := lib.unsafe_slice_u8_to_int(parts[1])
        ctx.all_wires[wire] = value
    }

    return
}

run_circut_once :: proc(ctx: ^Ctx) {
    for gate in ctx.gates_to_run {
        value1 := ctx.all_wires[gate.wire1]
        if value1 == -1 {
            append(&ctx.remaining_gates, gate)
            continue
        }

        value2 := ctx.all_wires[gate.wire2]
        if value2 == -1 {
            append(&ctx.remaining_gates, gate)
            continue
        }

        sum := value1 + value2
        output := 0

        if gate.op == Op.AND {
            if sum == 2 do output = 1
        } else if gate.op == Op.OR {
            if sum != 0 do output = 1
        } else if gate.op == Op.XOR {
            if sum == 1 do output = 1
        }

        ctx.all_wires[gate.wire3] = output
    }
    return
}

run_circut :: proc(ctx: ^Ctx) {
    for {
        run_circut_once(ctx)
        if len(ctx.gates_to_run) == 0 {
            break
        }
        ctx.gates_to_run = ctx.remaining_gates
        clear_dynamic_array(&ctx.remaining_gates)
    }
}

less :: proc(a, b: [3]u8) -> bool {
    for i in 0 ..< 3 {
        if a[i] != b[i] {
            return a[i] > b[i]
        }
    }
    return false
}

calc_result :: proc(ctx: Ctx) -> (result: u64) {
    zs := make_dynamic_array_len_cap([dynamic][3]u8, 0, 64)
    for wire, _ in ctx.all_wires {
        if wire[0] == 'z' do append_elem(&zs, wire)
    }
    slice.sort_by(zs[:], less)
    for z in zs {
        result = (result << 1) | u64(ctx.all_wires[z])
    }
    return
}

part1 :: proc(s: []u8) -> (result: u64) {
    ctx := parse(s)
    run_circut(&ctx)
    result = calc_result(ctx)
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
