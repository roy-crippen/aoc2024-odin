package main

import "core:flags"
import "core:fmt"
import va "core:mem/virtual"
import "core:os"
import "core:slice"
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
import "src/day_23"
import "src/day_24"
import "src/day_25"
import "src/lib"

ARENA_SIZE :: 8 * 1024 * 1024 // 4 MiB
MAX_ITERS :: 10

Options :: struct {
    best: bool `usage:"Calculate best time of 10 iterations for each day/part"`,
    mem:  bool `usage:"Enable allocator memory usage output"`,
    day:  u16 `usage:"Run a single day"`,
}

Answer :: struct {
    result:  u64,
    elapsed: f64,
}

opts: Options
ts: [MAX_ITERS]Answer
arena: va.Arena
all_sols := [25]lib.Solution {
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
    day_23.solution,
    day_24.solution,
    day_25.solution,
}

log_allocator :: proc(day: u8, part: u8, a: ^va.Arena) -> string {
    used_kib := a.total_used / 1024
    used_percent := f64(a.total_used) / f64(ARENA_SIZE) * 100
    return fmt.tprintf("  day %2d part %d: allocations: % 7d KiB (% 4.1f%%)", day, part, used_kib, used_percent)
}

run :: proc(iters: int, input: []u8, f: proc(_: []u8) -> u64) {
    for i in 0 ..< iters {
        va.arena_free_all(&arena)

        start := time.now()
        result := f(input)
        end := time.now()
        elapsed := time.duration_microseconds(time.diff(start, end))
        ts[i] = {
            result  = result,
            elapsed = elapsed,
        }
    }

    if opts.best {
        slice.sort_by(ts[:], proc(a, b: Answer) -> bool {
            return a.elapsed < b.elapsed
        })
    }
}

main :: proc() {
    // parse command line into the struct
    err_args := flags.parse(&opts, os.args[1:])
    if err_args != nil {
        switch e in err_args {
        case flags.Help_Request:
            program_name := os.args[0] if len(os.args) > 0 else "program"
            flags.write_usage(os.stream_from_handle(os.stdout), Options, program_name) // fixed
            os.exit(0)

        case flags.Parse_Error, flags.Validation_Error:
            fmt.eprintf("Error: %v\n\n", e)
            flags.write_usage(os.stream_from_handle(os.stderr), Options, os.args[0]) // fixed
            os.exit(1)

        case flags.Open_File_Error:
            fmt.eprintf("Open file error: %v (filename: %s)\n", e.errno, e.filename)
            os.exit(1)

        case:
            fmt.eprintf("Unexpected error: %v\n", err_args)
            os.exit(1)
        }
    }

    // setup allocator
    err := va.arena_init_static(&arena, ARENA_SIZE)
    if err != nil {
        fmt.eprintf("Failed to init static arena: %v\n", err)
        os.exit(1)
    }
    alloc := va.arena_allocator(&arena)
    context.allocator = alloc
    mem_metrics := make_dynamic_array([dynamic]string, allocator = context.temp_allocator)


    // run solutions
    sols: []lib.Solution
    if opts.day == 0 {
        sols = all_sols[:]
    } else {
        if opts.day > 25 {
            fmt.eprintfln("Day %d is invalid, should be 1 - 25", opts.day)
            os.exit(1)
        }
        sols = all_sols[opts.day - 1:opts.day]
    }

    result: u64
    tot_time, elapsed: f64
    iters := MAX_ITERS if opts.best else 1
    for sol in sols {
        // part1
        run(iters, sol.input, sol.part1)
        result = ts[0].result
        elapsed = ts[0].elapsed
        tot_time += elapsed

        if result == sol.expected_part1 {
            fmt.printfln("day %2d part 1: % 16d, % 9.2fus", sol.day, result, elapsed)
        } else {
            fmt.printfln("ERROR day %2d part 1. got %d, expected %d", sol.day, result, sol.expected_part1)
        }
        append(&mem_metrics, log_allocator(sol.day, 1, &arena))

        // part2
        run(iters, sol.input, sol.part2)
        result = ts[0].result
        elapsed = ts[0].elapsed
        tot_time += elapsed

        if result == sol.expected_part2 {
            fmt.printfln("day %2d part 2: % 16d, % 9.2fus", sol.day, result, elapsed)
        } else {
            fmt.printfln("ERROR day %2d part 2. got %d, expected %d", sol.day, result, sol.expected_part2)
        }
        append(&mem_metrics, log_allocator(sol.day, 2, &arena))
    }
    fmt.printfln("\nTotal time: % 6.3fms\n", tot_time / 1000.0)

    if opts.mem {
        fmt.printfln("allocator usage metrics, capacity %d KiB", ARENA_SIZE / 1024)
        for s in mem_metrics {
            fmt.println(s)
        }
    }

    va.arena_free_all(&arena)
}
