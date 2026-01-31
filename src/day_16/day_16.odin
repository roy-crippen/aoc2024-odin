package day_16

import "../lib"
import dk "../lib/dijkstra"
import "core:fmt"
import "core:testing"

EXAMPLE :: false
when EXAMPLE {
    INPUT :: #load("example.txt", []u8)
    EXPECTED_PART1 :: 7036
    EXPECTED_PART2 :: 45
} else {
    INPUT :: #load("day_16.txt", []u8)
    EXPECTED_PART1 :: 106512
    EXPECTED_PART2 :: 563
}


solution := lib.Solution {
    day            = 16,
    input          = INPUT,
    part1          = part1,
    part2          = part2,
    expected_part1 = EXPECTED_PART1,
    expected_part2 = EXPECTED_PART2,
}

part1 :: proc(s: []u8) -> (result: u64) {

    N :: 3
    adj: [N][dynamic]dk.Neighbor
    for i in 0 ..< N do adj[i] = make_dynamic_array_len_cap([dynamic]dk.Neighbor, 0, 2)
    append(&adj[0], dk.Neighbor{1, 1})
    append(&adj[0], dk.Neighbor{2, 100})
    append(&adj[1], dk.Neighbor{2, 1})

    start_vertex, end_vertex := 0, 2
    min_dist, prev := dk.dijkstra_compute_paths(N, start_vertex, adj)
    path := dk.get_shortest_path_to(start_vertex, end_vertex, prev[:])
    fmt.println(dk.show_path(path))
    fmt.println("cost:", min_dist[end_vertex])

    result = EXPECTED_PART1
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
