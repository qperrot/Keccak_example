%lang starknet

from starkware.cairo.common.math import split_felt
from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.uint256 import Uint256, uint256_mul, assert_uint256_eq

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
