package lib_dijkstra

import pq "core:container/priority_queue"
import "core:fmt"
import "core:log"
import "core:math"
import "core:slice"
import "core:strings"
import "core:testing"

Neighbor :: struct($V: typeid) {
    vertex: V,
    dist:   f64,
}

dijkstra_compute_paths :: proc(
    adj_list: $T/map[$V][dynamic]Neighbor(V),
    source: V,
    allocator := context.allocator,
) -> (
    map[V]f64,
    map[V]V,
) {

    // init return maps
    adj_list_len := len(adj_list)
    min_distance := make_map_cap(map[V]f64, adj_list_len, allocator = allocator)
    for v in adj_list do min_distance[v] = math.INF_F64
    previous := make_map_cap(map[V]V, adj_list_len, allocator = allocator)

    // min-heap priority queue
    less :: proc "odin" (a, b: Neighbor(V)) -> bool { return a.dist < b.dist }
    queue: pq.Priority_Queue(Neighbor(V))
    pq.init(&queue, less, pq.default_swap_proc(Neighbor(V)), allocator = allocator)
    defer pq.destroy(&queue)

    pq.push(&queue, Neighbor(V){dist = 0, vertex = source})
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
                pq.push(&queue, Neighbor(V){dist = alt, vertex = v})
            }
        }
    }
    return min_distance, previous
}

get_shortest_path_to :: proc(
    start_vertex: $V,
    end_vertex: V,
    previous: map[V]V,
    allocator := context.allocator,
) -> []V {
    path: [dynamic]V
    max_len := len(previous)
    path = make_dynamic_array_len_cap([dynamic]V, 0, max_len)
    defer delete_dynamic_array(path)

    current := end_vertex
    cnt: int
    for current != start_vertex && cnt < max_len {
        append(&path, current)
        current = previous[current]
        cnt += 1
    }
    append(&path, start_vertex)
    slice.reverse(path[:])
    return slice.clone(path[:], allocator)
}

show_path :: proc(path: []$V, sufix := '\n', allocator := context.temp_allocator) -> string {
    b: strings.Builder
    strings.builder_init(&b, allocator)

    fmt.sbprint(&b, "Path: \n")
    for v, i in path {
        if i > 0 do fmt.sbprintf(&b, " →%v", sufix)
        fmt.sbprintf(&b, "  %v", v)
    }
    fmt.sbprint(&b, "\n")
    return strings.to_string(b)
}

@(test)
test_dijkstra_int :: proc(t: ^testing.T) {
    context.allocator = context.temp_allocator
    // 6 vertices (0..5)
    N :: 6
    adj: map[int][dynamic]Neighbor(int)
    for i in 0 ..< N do adj[i] = make_dynamic_array_len_cap([dynamic]Neighbor(int), 0, 4)

    // directed graph — one directions
    append(&adj[0], Neighbor(int){1, 7})
    append(&adj[0], Neighbor(int){2, 9})
    append(&adj[0], Neighbor(int){5, 14})
    append(&adj[1], Neighbor(int){2, 10})
    append(&adj[1], Neighbor(int){3, 15})
    append(&adj[2], Neighbor(int){3, 11})
    append(&adj[2], Neighbor(int){5, 2})
    append(&adj[3], Neighbor(int){4, 6})
    append(&adj[4], Neighbor(int){5, 9})

    start_vertex := 0
    min_dist, prev := dijkstra_compute_paths(adj, start_vertex)

    end_vertex := 4
    path := get_shortest_path_to(start_vertex, end_vertex, prev)
    testing.expect(t, min_dist[end_vertex] == 26)
    log.info(min_dist[end_vertex])
    log.info(show_path(path))

    end_vertex = 5
    path = get_shortest_path_to(start_vertex, end_vertex, prev)
    testing.expect(t, min_dist[end_vertex] == 11)
    log.info(min_dist[end_vertex])
    log.info(show_path(path))

    // non-directed graph — add reverse directions
    append(&adj[1], Neighbor(int){0, 7})
    append(&adj[2], Neighbor(int){0, 9})
    append(&adj[5], Neighbor(int){0, 14})
    append(&adj[2], Neighbor(int){1, 10})
    append(&adj[3], Neighbor(int){1, 15})
    append(&adj[3], Neighbor(int){2, 11})
    append(&adj[5], Neighbor(int){2, 2})
    append(&adj[4], Neighbor(int){3, 6})
    append(&adj[5], Neighbor(int){4, 9})

    start_vertex = 0
    min_dist, prev = dijkstra_compute_paths(adj, start_vertex)

    end_vertex = 4
    path = get_shortest_path_to(start_vertex, end_vertex, prev)
    testing.expect(t, min_dist[end_vertex] == 20)
    log.info(min_dist[end_vertex])
    log.info(show_path(path))

    end_vertex = 5
    path = get_shortest_path_to(start_vertex, end_vertex, prev)
    testing.expect(t, min_dist[end_vertex] == 11)
    log.info(min_dist[end_vertex])
    log.info(show_path(path))
}
