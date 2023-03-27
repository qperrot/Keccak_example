%lang starknet

from starkware.cairo.common.math import assert_in_range, assert_lt_felt, split_felt
from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.memcpy import memcpy
from starkware.cairo.common.registers import get_fp_and_pc
from starkware.starknet.common.syscalls import get_tx_info
from starkware.cairo.common.math import unsigned_div_rem
from starkware.cairo.common.math_cmp import is_le
from starkware.cairo.common.uint256 import (
    Uint256,
    uint256_eq,
    uint256_unsigned_div_rem,
    uint256_mul,
    assert_uint256_eq,
    uint256_le,
)
from starkware.cairo.common.cairo_keccak.keccak import keccak_bigend, keccak_add_uint256s

func assert_boolean{range_check_ptr}(bool: felt) {
    const lower_bound = 0;
    const upper_bound = 2;

    with_attr error_message("FormatError: non boolean value") {
        assert_in_range(bool, lower_bound, upper_bound);
    }
    return ();
}

func preserve_references{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    tempvar syscall_ptr: felt* = syscall_ptr;
    tempvar pedersen_ptr: HashBuiltin* = pedersen_ptr;
    tempvar range_check_ptr = range_check_ptr;

    return ();
}

func replace_range{dst: felt*}(
    src: felt*, src_size: felt, offset: felt, data: felt*, data_len: felt
) {
    alloc_locals;
    let (__fp__, _) = get_fp_and_pc();
    local tmp: felt* = dst;

    memcpy(tmp, src, offset);

    let tmp = tmp + offset;
    memcpy(tmp, data, data_len);

    let tmp = tmp + data_len;
    memcpy(tmp, src + offset + data_len, src_size - offset - data_len);

    return ();
}

func felt_to_uint256{range_check_ptr}(x) -> (uint_x: Uint256) {
    let (high, low) = split_felt(x);
    return (Uint256(low=low, high=high),);
}

func felts_to_uint256s{range_check_ptr}(dst: Uint256*, src: felt*, src_len: felt) {
    if (src_len == 0) {
        return ();
    }

    let (res: Uint256) = felt_to_uint256([src]);
    assert [dst] = res;

    return felts_to_uint256s(dst + 2, src + 1, src_len - 1);
}

func uint256_to_felt{range_check_ptr}(value: Uint256) -> (value: felt) {
    assert_lt_felt(value.high, 2 ** 123);
    return (value.high * (2 ** 128) + value.low,);
}

// return TRUE if a == b
func is_equal{range_check_ptr}(a: felt, b: felt) -> (value: felt) {
    if (a == b) {
        return (TRUE,);
    }
    return (FALSE,);
}

// return TRUE if a != b
func is_not_equal{range_check_ptr}(a: felt, b: felt) -> (value: felt) {
    if (a == b) {
        return (FALSE,);
    }
    return (TRUE,);
}

// return TRUE if val == 0
func is_zero(val: felt) -> (res: felt) {
    if (val == 0) {
        return (TRUE,);
    }
    return (FALSE,);
}

// return TRUE if a < b
func is_lt{range_check_ptr}(a: felt, b: felt) -> (value: felt) {
    let res = is_le(a, b - 1);
    return (res,);
}

func get_chain_id{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    chain_id: felt
) {
    let (tx_info) = get_tx_info();
    return (tx_info.chain_id,);
}

// Need to know the len to do right pad
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

func hash_uint256{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr,
    bitwise_ptr: BitwiseBuiltin*,
    keccak_ptr: felt*,
}(value: Uint256) -> (res: Uint256) {
    alloc_locals;

    let (bytes_len) = get_bytes_len(value);
    let (value_padd) = pad_right(value, bytes_len);

    let (data: Uint256*) = alloc();
    assert data[0] = value_padd;

    let (inputs) = alloc();
    let inputs_start = inputs;
    keccak_add_uint256s{inputs=inputs}(n_elements=1, elements=data, bigend=TRUE);

    let (hash) = keccak_bigend{keccak_ptr=keccak_ptr}(inputs=inputs_start, n_bytes=bytes_len);
    return (hash,);
}
