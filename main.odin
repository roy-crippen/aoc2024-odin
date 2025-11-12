package main

import "core:fmt"
import "core:os"
import "src/lib"
import "src/day_01"

main :: proc() {
	// os.args is a []string
	fmt.println(os.args[0])  // executable name
	fmt.println(os.args[1:]) // the rest of the arguments

    fmt.println(lib.add(2, 42))

	sol := day_01.solution_01

	day_01_result := sol.part1(sol.input)
	fmt.printfln("day %d result = %d", sol.day, day_01_result)

}
