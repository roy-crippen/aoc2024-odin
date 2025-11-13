package main

import "core:fmt"
import "core:os"
import "src/lib"
import "src/day_01"
import "core:time"

main :: proc() {
// os.args is a []string
    fmt.println(os.args[0])  // executable name
    fmt.println(os.args[1:]) // the rest of the arguments

    sol := day_01.solution_01

    start := time.now()
    day_01_result := sol.part1(sol.input)
    end := time.now()
    elapsed := time.diff(start, end)

    fmt.printfln("day %d result = %d, %v", sol.day, day_01_result, elapsed)

}
