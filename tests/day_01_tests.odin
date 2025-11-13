package tests

import "core:fmt"
import "core:testing"
import  d "../src/day_01/"


@(test)
test_example_part1 :: proc(t: ^testing.T) {
    p1_example := d.part1(example_str)
    expected :int = 11
    testing.expect(t, p1_example == expected, fmt.tprintf("Expected result %d, got %d", expected, p1_example))
}

@(test)
test_part1 :: proc(t: ^testing.T) {
    p1 := d.part1(d.INPUT)
    expected := d.solution_01.expected_part1
    testing.expect(t, p1 == expected, fmt.tprintf("Expected result %d, got %d", expected, p1))
}

@(test)
test_example_part2 :: proc(t: ^testing.T) {
    p2_example := d.part2(example_str)
    expected :int = 31
    testing.expect(t, p2_example == expected, fmt.tprintf("Expected result %d, got %d", expected, p2_example))
}

@(test)
test_part2 :: proc(t: ^testing.T) {
    p2 := d.part2(d.INPUT)
    expected := d.solution_01.expected_part2
    testing.expect(t, p2 == expected, fmt.tprintf("Expected result %d, got %d", expected, p2))
}

example_str := `3   4
4   3
2   5
1   3
3   9
3   3`
