package day_24

import "../lib"
import "core:bytes"
import sa "core:container/small_array"
import "core:fmt"
import "core:slice"
import "core:strings"
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

Gate :: struct {
    op:                  string,
    wire1, wire2, wire3: [3]u8,
    paste, forward:      strings.Builder,
}

Ctx :: struct {
    gates_to_run, remaining_gates: [dynamic]Gate,
    all_wires:                     map[[3]u8]int,
    all_gates:                     [dynamic]Gate,
    gates_by_input:                map[[3]u8]sa.Small_Array(2, ^Gate),
    gates_by_output:               map[[3]u8]^Gate,
    xy_slots_length:               int,
    misplaced_output_wires:        sa.Small_Array(16, [3]u8),
}

parse :: proc(s: []u8) -> (ctx: Ctx) {
    ctx.gates_to_run = make_dynamic_array([dynamic]Gate)
    ctx.remaining_gates = make_dynamic_array_len_cap([dynamic]Gate, 0, 256)
    ctx.all_wires = make_map(map[[3]u8]int)
    ctx.all_gates = make_dynamic_array_len_cap([dynamic]Gate, 0, 256)
    ctx.gates_by_input = make_map(map[[3]u8]sa.Small_Array(2, ^Gate))
    ctx.gates_by_output = make_map(map[[3]u8]^Gate)
    sections := bytes.split(s, {'\n', '\n'})
    idx: int
    for line in bytes.split(sections[1], {'\n'}) {
        parts := bytes.split(line, {' '})
        wire1, _ := slice.to_type(parts[0], [3]u8)
        wire2, _ := slice.to_type(parts[2], [3]u8)
        wire3, _ := slice.to_type(parts[4], [3]u8)
        gate := Gate {
            op    = strings.clone_from_bytes(parts[1]),
            wire1 = wire1,
            wire2 = wire2,
            wire3 = wire3,
        }
        append(&ctx.gates_to_run, gate)
        append(&ctx.all_gates, gate)
        g_ptr := &ctx.all_gates[idx]
        idx += 1

        sa_wire1 := ctx.gates_by_input[wire1]
        sa.push_back(&sa_wire1, g_ptr)
        ctx.gates_by_input[wire1] = sa_wire1

        sa_wire2 := ctx.gates_by_input[wire2]
        sa.push_back(&sa_wire2, g_ptr)
        ctx.gates_by_input[wire2] = sa_wire2

        ctx.gates_by_output[wire3] = g_ptr
        ctx.all_wires[wire1] = -1
        ctx.all_wires[wire2] = -1
        ctx.all_wires[wire2] = -1
    }

    for line in bytes.split(sections[0], {'\n'}) {
        parts := bytes.split(line, {':', ' '})
        wire := slice.to_type(parts[0], [3]u8)
        value := lib.unsafe_slice_u8_to_int(parts[1])
        ctx.all_wires[wire] = value
        ctx.xy_slots_length += 1
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

        if gate.op == "AND" {
            if sum == 2 do output = 1
        } else if gate.op == "OR" {
            if sum != 0 do output = 1
        } else if gate.op == "XOR" {
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

// part 2 procs

find_gate_forward :: proc(ctx: Ctx, wire: [3]u8) -> string {
    if wire[0] == 'z' do return "FINAL"

    xs: sa.Small_Array(2, string)
    for g in sa.slice(&ctx.gates_by_input[wire]) {
        sa.push_back(&xs, g.op)
    }
    slice.sort(sa.slice(&xs))
    return strings.join(sa.slice(&xs), "-")
}

process_bottom_gates :: proc(ctx: ^Ctx) -> []^Gate {
    bottom_gates := make_dynamic_array_len_cap([dynamic]^Gate, ctx.xy_slots_length, ctx.xy_slots_length)
    for _, gate in ctx.gates_by_output {
        if gate.wire1[0] != 'x' && gate.wire1[0] != 'y' do continue
        index := 2 * lib.unsafe_slice_u8_to_int(gate.wire1[1:]) + (0 if gate.op == "AND" else 1)
        strings.write_string(&gate.paste, "xy")
        strings.write_string(&gate.forward, find_gate_forward(ctx^, gate.wire3))
        bottom_gates[index] = gate
    }
    return bottom_gates[:]
}

is_last_z_slot :: #force_inline proc "contextless" (gate: Gate, xy_slots_length: int) -> bool {
    if gate.wire3[0] != 'z' {
        return false
    }

    t := gate.wire3
    z_slot := lib.unsafe_slice_u8_to_int(t[1:])
    b := z_slot == xy_slots_length / 2
    return b
}

is_first_xy_slot :: proc "contextless" (gate: Gate) -> bool {
    b := gate.wire1[1] == '0' && gate.wire1[1] == '0'
    return b
}

is_special_case :: proc "contextless" (gate: Gate, pattern: string, xy_slots_length: int) -> bool {
    switch pattern {
    case "xy . XOR . FINAL":
        return is_first_xy_slot(gate)
    case "xy . AND . AND-XOR":
        return is_first_xy_slot(gate)
    case "xy AND . OR . FINAL":
        return is_last_z_slot(gate, xy_slots_length)
    }
    return false
}

search_misplaced_wires :: proc(ctx: ^Ctx, gates: []^Gate) {
    patterns := make_map_cap(map[string]sa.Small_Array(64, [3]u8), 8)
    for gate in gates {
        ls: []string = {strings.to_string(gate.paste), gate.op, strings.to_string(gate.forward)}
        pattern := strings.join(ls, " . ")
        if is_special_case(gate^, pattern, ctx.xy_slots_length) do continue

        xs := patterns[pattern]
        sa.push_back(&xs, gate.wire3)
        patterns[pattern] = xs
    }
    for _, vs in patterns {
        if sa.len(vs) > 8 do continue
        vs_copy := vs
        for wire in sa.slice(&vs_copy) do sa.push_back(&ctx.misplaced_output_wires, wire)
    }
}

process_next_level_gates :: proc(ctx: Ctx, parent_gates: []^Gate) -> []^Gate {
    child_gates := make_dynamic_array_len_cap([dynamic]^Gate, 0, len(parent_gates))
    for parent in parent_gates {
        wire := parent.wire3
        if wire[0] == 'z' do continue
        t := ctx.misplaced_output_wires
        if slice.contains(sa.slice(&t), wire) do continue

        for g in sa.slice(&ctx.gates_by_input[wire]) {
            next_gate := g
            strings.builder_reset(&next_gate.paste)
            strings.write_string(&next_gate.paste, strings.to_string(parent.paste))
            strings.write_string(&next_gate.paste, " ")
            strings.write_string(&next_gate.paste, parent.op)

            strings.builder_reset(&next_gate.forward)
            strings.write_string(&next_gate.forward, find_gate_forward(ctx, next_gate.wire3))
            append_elem(&child_gates, next_gate)
        }
    }

    return child_gates[:]
}


part1 :: proc(s: []u8) -> (result: u64) {
    ctx := parse(s)
    run_circut(&ctx)
    result = calc_result(ctx)
    return
}

part2 :: proc(s: []u8) -> (result: u64) {
    ctx := parse(s)
    gates := process_bottom_gates(&ctx)
    for {
        search_misplaced_wires(&ctx, gates)
        if sa.len(ctx.misplaced_output_wires) >= 8 do break
        gates = process_next_level_gates(ctx, gates)
    }

    // sa_slice := sa.slice(&ctx.misplaced_output_wires)
    // fmt.printfln("misplaced_output_wires: %s", sa_slice)
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
