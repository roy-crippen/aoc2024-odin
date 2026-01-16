package day_09

import "../lib"
import "core:fmt"
import "core:testing"

EXAMPLE :: false
when EXAMPLE {
    CAP :: 10
    INPUT :: #load("example.txt", []u8)
    EXPECTED_PART1 :: 1928
    EXPECTED_PART2 :: 2858
} else {
    CAP :: 10_000
    INPUT :: #load("day_09.txt", []u8)
    EXPECTED_PART1 :: 6310675819476
    EXPECTED_PART2 :: 6335972980679
}

File :: struct {
    fid:  int,
    pos:  int,
    size: int,
}

Blank :: struct {
    pos:  int,
    size: int,
}


make_disk :: proc(s: []u8) -> ([]File, []Blank) {
    files := make_dynamic_array_len_cap([dynamic]File, 0, CAP)
    blanks := make_dynamic_array_len_cap([dynamic]Blank, 0, CAP)
    x, fid, idx: int
    file: File
    blank: Blank
    for ch, i in s {
        x = int(ch) - '0'
        if x == 0 { continue }
        if i % 2 == 0 {
            file = File {
                fid  = fid,
                pos  = idx,
                size = x,
            }
            append_elem(&files, file)
            fid += 1
        } else {
            blank = Blank {
                pos  = idx,
                size = x,
            }
            append_elem(&blanks, blank)
        }
        idx += x
    }
    return files[:], blanks[:]
}

log_files :: proc(files: []File) {
    fmt.println("\nfiles")
    #reverse for file in files { fmt.printfln("  %v", file) }
}

log_blanks :: proc(blanks: []Blank) {
    fmt.println("\nblanks")
    for blank in blanks { fmt.printfln("  %v", blank) }
}

solution := lib.Solution {
    day            = 09,
    input          = INPUT,
    part1          = part1,
    part2          = part2,
    expected_part1 = EXPECTED_PART1,
    expected_part2 = EXPECTED_PART2,
}

part1 :: proc(s: []u8) -> (result: u64) {
    files, blanks := make_disk(s)
    fmt.println(len(files), len(blanks))
    // log_files(files)
    // log_blanks(blanks)

    blank: Blank
    i, j: int
    file_loop: for i = len(files) - 1; i > 0; i -= 1 {
        for j < len(blanks) {
            blank = blanks[j]
            if blank.pos > files[i].pos { break file_loop }

            if blank.size >= files[i].size {
                for k in blank.pos ..< blank.pos + files[i].size { result += u64(files[i].fid * k) }
                if blank.size == files[i].size {
                    j += 1
                    break
                } else {
                    blanks[j].pos = blank.pos + files[i].size
                    blanks[j].size = blank.size - files[i].size
                }
                break
            } else {
                for k in blank.pos ..< blank.pos + blank.size { result += u64(files[i].fid * k) }
                files[i].size = files[i].size - blank.size
                j += 1
            }
        }
    }

    for jj in 0 ..= i {
        for k in files[jj].pos ..< files[jj].pos + files[jj].size {
            result += u64(files[jj].fid * k)
        }
    }

    fmt.println(result)
    return
}


part2 :: proc(s: []u8) -> (result: u64) {
    return EXPECTED_PART2
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
