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


make_disk_part1 :: proc(s: []u8) -> ([]File, []Blank) {
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

make_disk_part2 :: proc(s: []u8) -> ([]File, [10][dynamic]Blank) {
    files := make_dynamic_array_len_cap([dynamic]File, 0, CAP)
    blank_group: [10][dynamic]Blank
    for i in 0 ..= 9 { blank_group[i] = make_dynamic_array([dynamic]Blank) }

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
            append_elem(&blank_group[x], blank)
        }
        idx += x
    }

    return files[:], blank_group
}

next_blank :: proc(blank_group: ^[10][dynamic]Blank, file_pos: int, file_size: int) -> (blank: Blank, ok: bool) {
    best_idx := 1_000_000
    min_pos := 1_000_000
    for i in file_size ..< 10 {
        if len(blank_group[i]) > 0 &&
           blank_group[i][0].pos < file_pos &&
           blank_group[i][0].size >= file_size &&
           blank_group[i][0].pos < min_pos {
            best_idx = i
            min_pos = blank_group[i][0].pos
        }
    }
    if best_idx == 1_000_000 { return }

    ok = true
    blank = pop_front(&blank_group[best_idx])
    // update blank_group if blank.size > file_size
    if blank.size > file_size {
        new_size := blank.size - file_size
        new_pos := blank.pos + file_size
        remaining_blank := Blank {
            pos  = new_pos,
            size = new_size,
        }
        // find index to insert
        insert_idx: int
        for ; insert_idx < len(blank_group[new_size]); insert_idx += 1 {
            if blank_group[new_size][insert_idx].pos > new_pos { break }
        }
        inject_at_elem(&blank_group[new_size], insert_idx, remaining_blank)
    }

    return
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
    files, blanks := make_disk_part1(s)

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

    return
}


part2 :: proc(s: []u8) -> (result: u64) {
    files, blank_group := make_disk_part2(s)

    blank: Blank
    ok: bool
    #reverse for file in files {
        blank, ok = next_blank(&blank_group, file.pos, file.size)
        if ok {
            for k in blank.pos ..< blank.pos + file.size {
                result += u64(file.fid * k)
            }
        } else {
            for k in file.pos ..< file.pos + file.size {
                result += u64(file.fid * k)
            }
        }
    }

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
