package lib_dijkstra

import pq "core:container/priority_queue"
import "core:fmt"
import "core:log"
import "core:math"
import "core:slice"
import "core:strings"
import "core:testing"

Neighbor :: struct {
    vertex: int,
    dist:   f64,
}

dijkstra_compute_paths :: proc(
    $N: int,
    source: int,
    adj_list: [N][dynamic]Neighbor,
    allocator := context.allocator,
) -> (
    []f64,
    []int,
) {

    min_distance := make_dynamic_array_len_cap([dynamic]f64, N, N, allocator = allocator)
    for i in 0 ..< N do min_distance[i] = math.INF_F64
    defer delete_dynamic_array(min_distance)

    previous := make_dynamic_array_len_cap([dynamic]int, N, N, allocator = allocator)
    for i in 0 ..< N do previous[i] = -1
    defer delete_dynamic_array(previous)

    // min-heap priority queue
    less :: proc "odin" (a, b: Neighbor) -> bool { return a.dist < b.dist }
    queue: pq.Priority_Queue(Neighbor)
    pq.init(&queue, less, pq.default_swap_proc(Neighbor), allocator = allocator)
    defer pq.destroy(&queue)

    pq.push(&queue, Neighbor{dist = 0, vertex = source})
    for pq.len(queue) > 0 {
        item := pq.pop(&queue)
        dist := item.dist
        u := item.vertex

        // skip outdated entries
        if dist > min_distance[u] {
            continue
        }

        for &nb in adj_list[u] {
            v := nb.vertex
            w := nb.dist

            alt := dist + w
            if alt < min_distance[v] {
                min_distance[v] = alt
                previous[v] = u
                pq.push(&queue, Neighbor{dist = alt, vertex = v})
            }
        }
    }
    return min_distance[:], previous[:]
}

get_shortest_path_to :: proc(
    start_vertex: int,
    end_vertex: int,
    previous: []int,
    allocator := context.temp_allocator,
) -> []int {
    path: [dynamic]int
    max_len := 2 * len(previous)
    path = make_dynamic_array_len_cap([dynamic]int, 0, max_len)

    current := end_vertex
    cnt: int
    for current != start_vertex && current != -1 && cnt < max_len {
        append(&path, current)
        current = previous[current]
        cnt += 1
    }
    append(&path, start_vertex)
    slice.reverse(path[:])
    return slice.clone(path[:], allocator)
}

show_path :: proc(path: []int, allocator := context.temp_allocator) -> string {
    b: strings.Builder
    strings.builder_init(&b, allocator)


    fmt.sbprint(&b, "Path: ")
    for v, i in path {
        if i > 0 do fmt.sbprint(&b, " → ")
        fmt.sbprint(&b, v)
    }
    fmt.sbprint(&b, "\n")
    return strings.to_string(b)
}

@(test)
test_dijkstra_int :: proc(t: ^testing.T) {
    context.allocator = context.temp_allocator
    // 6 vertices (0..5)
    N :: 6
    adj: [N][dynamic]Neighbor
    for i in 0 ..< N do adj[i] = make_dynamic_array_len_cap([dynamic]Neighbor, 0, 8)

    // directed graph — one directions
    append(&adj[0], Neighbor{1, 7})
    append(&adj[0], Neighbor{2, 9})
    append(&adj[0], Neighbor{5, 14})
    append(&adj[1], Neighbor{2, 10})
    append(&adj[1], Neighbor{3, 15})
    append(&adj[2], Neighbor{3, 11})
    append(&adj[2], Neighbor{5, 2})
    append(&adj[3], Neighbor{4, 6})
    append(&adj[4], Neighbor{5, 9})

    start_vertex := 0
    min_dist, prev := dijkstra_compute_paths(N, start_vertex, adj)

    end_vertex := 4
    path := get_shortest_path_to(start_vertex, end_vertex, prev[:])
    testing.expect(t, min_dist[end_vertex] == 26)
    // log.info(min_dist[end_vertex])
    // log.info(show_path(path))

    end_vertex = 5
    path = get_shortest_path_to(start_vertex, end_vertex, prev[:])
    testing.expect(t, min_dist[end_vertex] == 11)
    // log.info(min_dist[end_vertex])
    // log.info(show_path(path))

    // non-directed graph — add reverse directions
    append(&adj[1], Neighbor{0, 7})
    append(&adj[2], Neighbor{0, 9})
    append(&adj[5], Neighbor{0, 14})
    append(&adj[2], Neighbor{1, 10})
    append(&adj[3], Neighbor{1, 15})
    append(&adj[3], Neighbor{2, 11})
    append(&adj[5], Neighbor{2, 2})
    append(&adj[4], Neighbor{3, 6})
    append(&adj[5], Neighbor{4, 9})

    start_vertex = 0
    min_dist, prev = dijkstra_compute_paths(N, start_vertex, adj)

    end_vertex = 4
    path = get_shortest_path_to(start_vertex, end_vertex, prev[:])
    testing.expect(t, min_dist[end_vertex] == 20)
    // log.info(min_dist[end_vertex])
    // log.info(show_path(path))

    end_vertex = 5
    path = get_shortest_path_to(start_vertex, end_vertex, prev[:])
    testing.expect(t, min_dist[end_vertex] == 11)
    // log.info(min_dist[end_vertex])
    // log.info(show_path(path))
}
