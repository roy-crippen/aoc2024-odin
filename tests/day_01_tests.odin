package tests

import "core:fmt"
import "core:testing"
import  d "../src/day_01/"


@(test)
test_example_part1 :: proc(t: ^testing.T) {
    p1_example := d.part1(example_str)
    expected :u64 = 42
    testing.expect(t, p1_example == expected, fmt.tprintf("Expected age %d, got %d", expected, p1_example))
}



example_str := `3   4
4   3
2   5
1   3
3   9
3   3`
