package lib

add :: proc(a:int, b:int) -> int {return a + b}


Solution :: struct {
day : int,
input : string,
part1 : proc(s: string) -> u64,
part2 : proc(s: string) -> u64,
expected_part1 : u64,
expected_part2 : u64,
}

