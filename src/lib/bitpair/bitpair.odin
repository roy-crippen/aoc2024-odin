package lib_bitpair

import "../../lib"
import "core:container/bit_array"
import "core:testing"

// BitPairSet – compact bitset storing presence of (a,b) where a,b ∈ [0..10^N]
BitPairSet :: struct {
    max_value: u64,
    bits:      bit_array.Bit_Array,
}

// Create a new empty set (all pairs false)
// max_digits in range 0..=4
create :: proc(max_digits: u64, allocator := context.allocator) -> (s: BitPairSet, ok: bool) {
    if max_digits < 1 || max_digits > 4 { return s, false }
    s.max_value = lib.pow(10, max_digits + 1)
    total := int(s.max_value * s.max_value)
    ok = bit_array.init(&s.bits, total, 0, allocator)
    return
}

// Destroy / free the bitset
destroy :: proc(s: ^BitPairSet) {
    bit_array.destroy(&s.bits)
}

// Encode pair (a,b) where a,b ∈ [0..999] into a flat index
_encode :: proc "contextless" (a, b: u16, max_value: u64) -> u64 {
    // a is "row", b is "column" → linear index = a*1000 + b
    return u64(a) * max_value + u64(b)
}

// Decode flat index back to (a,b)
_decode :: proc "contextless" (idx: u64, max_value: u64) -> (a, b: u16) {
    a = u16(idx / max_value)
    b = u16(idx % max_value)
    return
}

// Set pair (a,b) to true
set :: proc(s: ^BitPairSet, a, b: u16) -> bool {
    idx := _encode(a, b, s.max_value)
    return bit_array.set(&s.bits, idx)
}

// Set pair (a,b) to true without bounds check
unsafe_set :: #force_inline proc(s: ^BitPairSet, a, b: u16) {
    idx := _encode(a, b, s.max_value)
    bit_array.unsafe_set(&s.bits, int(idx))
}

// Test if pair (a,b) is present (true)
get :: proc(s: ^BitPairSet, a, b: u16) -> (res: bool, ok: bool) {
    idx := _encode(a, b, s.max_value)
    return bit_array.get(&s.bits, idx)
}

// Test if pair (a,b) is present (true) without bounds check
unsafe_get :: #force_inline proc(s: ^BitPairSet, a, b: u16) -> bool {
    idx := _encode(a, b, s.max_value)
    return bit_array.unsafe_get(&s.bits, idx)
}

// Set pair (a,b) to true
unset :: proc(s: ^BitPairSet, a, b: u16) -> bool {
    idx := _encode(a, b, s.max_value)
    return bit_array.unset(&s.bits, idx)
}

// Set pair (a,b) to true without bounds check
unsafe_unset :: #force_inline proc(s: ^BitPairSet, a, b: u16) {
    idx := _encode(a, b, s.max_value)
    bit_array.unsafe_unset(&s.bits, int(idx))
}

// Clear / reset all bits to false+
clear :: proc(s: ^BitPairSet) {
    bit_array.clear(&s.bits)
}


@(test)
test_bitpair_3 :: proc(t: ^testing.T) {
    s, ok := create(3)
    testing.expect(t, ok)
    defer destroy(&s)

    // mark some pairs
    set(&s, 123, 456)
    set(&s, 0, 999)
    set(&s, 999, 0)
    set(&s, 12, 24)
    set(&s, 777, 777)

    testing.expect(t, unsafe_get(&s, 123, 456))
    unsafe_unset(&s, 123, 456)
    testing.expect(t, !unsafe_get(&s, 123, 456))

    testing.expect(t, unsafe_get(&s, 12, 24) && unsafe_get(&s, 0, 999))
    clear(&s)
    testing.expect(t, !unsafe_get(&s, 12, 24) && !unsafe_get(&s, 0, 999))
}

@(test)
test_bitpair_2 :: proc(t: ^testing.T) {
    s, ok := create(2)
    testing.expect(t, ok)
    defer destroy(&s)

    // mark some pairs
    set(&s, 12, 45)
    set(&s, 0, 99)
    set(&s, 42, 42)

    testing.expect(t, unsafe_get(&s, 12, 45))
    unsafe_unset(&s, 12, 45)
    testing.expect(t, !unsafe_get(&s, 12, 45))

    testing.expect(t, unsafe_get(&s, 42, 42) && unsafe_get(&s, 0, 99))
    clear(&s)
    testing.expect(t, !unsafe_get(&s, 12, 45) && !unsafe_get(&s, 0, 99))
}

@(test)
test_encode :: proc(t: ^testing.T) {
    s, ok := create(2)
    testing.expect(t, ok)
    defer destroy(&s)

    idx := _encode(12, 45, s.max_value)
    a, b := _decode(idx, s.max_value)
    testing.expect(t, a == 12 && b == 45)
}
@(test)
test_max_size :: proc(t: ^testing.T) {
    s, ok := create(0)
    defer destroy(&s)
    testing.expect(t, !ok)

    s, ok = create(5)
    testing.expect(t, !ok)

    s, ok = create(3)
    testing.expect(t, ok)
}
