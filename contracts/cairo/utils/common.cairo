%lang starknet

from starkware.cairo.common.math import split_felt
from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.uint256 import (
    Uint256,
    uint256_mul,
    assert_uint256_eq,
    uint256_eq,
    uint256_le,
    uint256_unsigned_div_rem,
)
from starkware.cairo.common.math import unsigned_div_rem

func felt_to_uint256{range_check_ptr}(x) -> (uint_x: Uint256) {
    let (high, low) = split_felt(x);
    return (Uint256(low=low, high=high),);
}

// Need to know the len to do the right pad
func pad_right{range_check_ptr}(num: Uint256, len: felt) -> (res: Uint256) {
    let len_base16 = len * 2;
    let base = 16;
    let exp = 64 - len_base16;
    let (power_16) = u256_pow(base, exp);

    // Left shift
    let (low, high) = uint256_mul(num, power_16);
    with_attr error_message("pad_right: Overflow happened") {
        assert high.low = 0;
        assert high.high = 0;
    }

    return (low,);
}

func u256_pow{range_check_ptr}(base: felt, exp: felt) -> (res: Uint256) {
    alloc_locals;

    if (exp == 0) {
        // Any number to the power of 0 is 1
        return (Uint256(1, 0),);
    } else {
        // Compute `base ** exp - 1`
        let (recursion) = u256_pow(base, exp - 1);
        let (uint256_base) = felt_to_uint256(base);
        // Multiply the result by `base`
        let (res, overflow) = uint256_mul(recursion, uint256_base);
        with_attr error_message("u256_pow: Overflow happened") {
            assert_uint256_eq(overflow, Uint256(0, 0));
        }

        return (res,);
    }
}

// Returns the number of digits needed to represent num in hexadecimal.
func get_base16_len{range_check_ptr}(num: Uint256) -> (res: felt) {
    let (is_eq) = uint256_eq(num, Uint256(0, 0));
    if (is_eq == TRUE) {
        return (0,);
    }
    let (lt) = uint256_le(Uint256(16 ** 32, 0), num);
    if (lt == TRUE) {
        let (divided, _) = uint256_unsigned_div_rem(num, Uint256(16 ** 32, 0));
        let (res_len) = get_base16_len(divided);
        return (res_len + 32,);
    }
    let (lt) = uint256_le(Uint256(16 ** 16, 0), num);
    if (lt == TRUE) {
        let (divided, _) = uint256_unsigned_div_rem(num, Uint256(16 ** 16, 0));
        let (res_len) = get_base16_len(divided);
        return (res_len + 16,);
    }
    let (lt) = uint256_le(Uint256(16 ** 8, 0), num);
    if (lt == TRUE) {
        let (divided, _) = uint256_unsigned_div_rem(num, Uint256(16 ** 8, 0));
        let (res_len) = get_base16_len(divided);
        return (res_len + 8,);
    }
    let (lt) = uint256_le(Uint256(16 ** 4, 0), num);
    if (lt == TRUE) {
        let (divided, _) = uint256_unsigned_div_rem(num, Uint256(16 ** 4, 0));
        let (res_len) = get_base16_len(divided);
        return (res_len + 4,);
    }
    let (lt) = uint256_le(Uint256(16 ** 2, 0), num);
    if (lt == TRUE) {
        let (divided, _) = uint256_unsigned_div_rem(num, Uint256(16 ** 2, 0));
        let (res_len) = get_base16_len(divided);
        return (res_len + 2,);
    }
    let (lt) = uint256_le(Uint256(16 ** 1, 0), num);
    if (lt == TRUE) {
        let (divided, _) = uint256_unsigned_div_rem(num, Uint256(16 ** 1, 0));
        let (res_len) = get_base16_len(divided);
        return (res_len + 1,);
    }
    return (1,);
}

func get_bytes_len{range_check_ptr}(num: Uint256) -> (res: felt) {
    let (len_base16) = get_base16_len(num);
    let (bytes_len, _) = unsigned_div_rem(len_base16 + 1, 2);
    return (bytes_len,);
}
