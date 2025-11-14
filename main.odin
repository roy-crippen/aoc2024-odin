package main

import "core:fmt"
import "core:os"
import "src/day_01"
import "src/day_02"
import "src/day_99"
import "src/lib"
import "core:time"

main :: proc() {
// os.args is a []string
    fmt.println(os.args[0])  // executable name
    fmt.println(os.args[1:]) // the rest of the arguments

    sols := []lib.Solution{
        day_01.solution,
        day_02.solution,
        day_99.solution
    }

    tot_time := 0.0;
    for sol in sols {
        start := time.now()
        result := sol.part1(sol.input)
        end := time.now()
        elapsed := time.duration_microseconds(time.diff(start, end))
        tot_time += elapsed
        fmt.printfln("day %2d part 1: % 12d, % 9.2fus", sol.day, result, elapsed)

        start = time.now()
        result = sol.part2(sol.input)
        end = time.now()
        elapsed = time.duration_microseconds(time.diff(start, end))
        tot_time += elapsed
        fmt.printfln("day %2d part 2: % 12d, % 9.2fus", sol.day, result, elapsed)
    }
     fmt.printfln("\nTotal time: % 6.3fms", tot_time / 1000.0)
}
