package main

import "core:fmt"
import va "core:mem/virtual"
import "core:os"
import "core:time"
import "src/day_01"
import "src/day_02"
import "src/day_03"
import "src/day_04"
import "src/day_05"
import "src/day_06"
import "src/day_07"
import "src/day_08"
import "src/day_09"
import "src/day_10"
import "src/day_11"
import "src/day_12"
import "src/day_13"
import "src/day_14"
import "src/day_15"
import "src/day_16"
import "src/day_17"
import "src/day_18"
import "src/day_19"
import "src/day_20"
import "src/day_21"
import "src/day_22"
import "src/lib"

ARENA_SIZE :: 8 * 1024 * 1024 // 4 MiB

log_allocator :: proc(day: u8, part: u8, a: ^va.Arena) -> string {
    used_kib := a.total_used / 1024
    used_percent := f64(a.total_used) / f64(ARENA_SIZE) * 100
    return fmt.tprintf("  day %2d part %d: allocations: % 7d KiB (% 4.1f%%)", day, part, used_kib, used_percent)
}

main :: proc() {
    arena: va.Arena
    err := va.arena_init_static(&arena, ARENA_SIZE)
    if err != nil {
        fmt.eprintf("Failed to init static arena: %v\n", err)
        os.exit(1)
    }
    alloc := va.arena_allocator(&arena)
    context.allocator = alloc
    mem_metrics := make_dynamic_array([dynamic]string, allocator = context.temp_allocator)

    sols := []lib.Solution {
        day_01.solution,
        day_02.solution,
        day_03.solution,
        day_04.solution,
        day_05.solution,
        day_06.solution,
        day_07.solution,
        day_08.solution,
        day_09.solution,
        day_10.solution,
        day_11.solution,
        day_12.solution,
        day_13.solution,
        day_14.solution,
        day_15.solution,
        day_16.solution,
        day_17.solution,
        day_18.solution,
        day_19.solution,
        day_20.solution,
        day_21.solution,
        day_22.solution,
    }

    tot_time: f64
    for sol in sols {
        va.arena_free_all(&arena)
        start := time.now()
        result := sol.part1(sol.input)
        end := time.now()

        elapsed := time.duration_microseconds(time.diff(start, end))
        tot_time += elapsed
        if result == sol.expected_part1 {
            fmt.printfln("day %2d part 1: % 16d, % 9.2fus", sol.day, result, elapsed)
        } else {
            fmt.printfln("ERROR day %2d part 1. got %d, expected %d", sol.day, result, sol.expected_part1)
        }
        append(&mem_metrics, log_allocator(sol.day, 1, &arena))

        va.arena_free_all(&arena)
        start = time.now()
        result = sol.part2(sol.input)
        end = time.now()
        elapsed = time.duration_microseconds(time.diff(start, end))
        tot_time += elapsed
        if result == sol.expected_part2 {
            fmt.printfln("day %2d part 2: % 16d, % 9.2fus", sol.day, result, elapsed)
        } else {
            fmt.printfln("ERROR day %2d part 2. got %d, expected %d", sol.day, result, sol.expected_part2)
        }
        append(&mem_metrics, log_allocator(sol.day, 2, &arena))
    }
    fmt.printfln("\nTotal time: % 6.3fms\n", tot_time / 1000.0)

    fmt.printfln("allocator usage metrics, capacity %d KiB", ARENA_SIZE / 1024)
    for s in mem_metrics {
        fmt.println(s)
    }

    va.arena_free_all(&arena)
}
