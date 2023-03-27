%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.pow import pow
from starkware.cairo.common.bool import FALSE
from starkware.cairo.common.math import unsigned_div_rem, split_int
from starkware.cairo.common.math_cmp import is_le
from starkware.cairo.common.memcpy import memcpy

const UINT256_BYTES_SIZE = 32;

func compute_half_uint256{range_check_ptr}(val: felt*, i: felt, res: felt) -> (res: felt) {
    if (i == 1) {
        return (res=res + [val]);
    }
    let (temp_pow) = pow(256, i - 1);
    let (res) = compute_half_uint256(val + 1, i - 1, res + [val] * temp_pow);
    return (res=res);
}

func bytes_i_to_uint256{range_check_ptr}(val: felt*, i: felt) -> Uint256 {
    alloc_locals;

    if (i == 0) {
        let res = Uint256(0, 0);
        return res;
    }

    let is_sequence_32_bytes_or_less = is_le(i, 32);
    with_attr error_message("number must be shorter than 32 bytes") {
        assert is_sequence_32_bytes_or_less = 1;
    }

    let is_sequence_16_bytes_or_less = is_le(i, 16);

    // 1 - 16 bytes
    if (is_sequence_16_bytes_or_less != FALSE) {
        let (low) = compute_half_uint256(val=val, i=i, res=0);
        let res = Uint256(low=low, high=0);

        return res;
    }

    // 17 - 32 bytes
    let (low) = compute_half_uint256(val=val + i - 16, i=16, res=0);
    let (high) = compute_half_uint256(val=val, i=i - 16, res=0);
    let res = Uint256(low=low, high=high);

    return res;
}

func felt_to_bytes_little{range_check_ptr}(value: felt, bytes_len: felt, bytes: felt*) -> (
    bytes_len: felt
) {
    let is_le_256 = is_le(value, 256);
    if (is_le_256 != FALSE) {
        assert [bytes] = value;
        return (bytes_len=bytes_len + 1);
    } else {
        let (q, r) = unsigned_div_rem(value, 256);
        assert [bytes] = r;
        return felt_to_bytes_little(value=q, bytes_len=bytes_len + 1, bytes=bytes + 1);
    }
}

// transform a felt to little endian bytes
func felt_to_bytes{range_check_ptr}(value: felt, bytes_len: felt, bytes: felt*) -> (
    bytes_len: felt
) {
    alloc_locals;
    let (local little: felt*) = alloc();
    let little_res = felt_to_bytes_little(value, bytes_len, little);
    reverse(little_res.bytes_len, little, little_res.bytes_len, bytes);
    return little_res;
}

func uint256_to_dest_bytes_array{range_check_ptr}(
    value: Uint256,
    byte_array_offset: felt,
    byte_array_len: felt,
    dest_offset: felt,
    dest_len: felt,
    dest: felt*,
) -> (updated_dest_len: felt) {
    alloc_locals;
    let (_, bytes_array) = uint256_to_bytes_array(value);
    memcpy(dst=dest + dest_offset, src=bytes_array + byte_array_offset, len=byte_array_len);
    return (updated_dest_len=dest_len + byte_array_len);
}

func uint256_to_bytes_array{range_check_ptr}(value: Uint256) -> (
    bytes_array_len: felt, bytes_array: felt*
) {
    alloc_locals;
    // Split the stack popped value from Uint to bytes array
    let (local temp_value: felt*) = alloc();
    let (local value_as_bytes_array: felt*) = alloc();
    split_int(value=value.high, n=16, base=2 ** 8, bound=2 ** 128, output=temp_value + 16);
    split_int(value=value.low, n=16, base=2 ** 8, bound=2 ** 128, output=temp_value);
    // Reverse the temp_value array into value_as_bytes_array as memory is arranged in big endian order
    reverse(old_arr_len=32, old_arr=temp_value, new_arr_len=32, new_arr=value_as_bytes_array);
    return (bytes_array_len=32, bytes_array=value_as_bytes_array);
}

func reverse(old_arr_len: felt, old_arr: felt*, new_arr_len: felt, new_arr: felt*) {
    if (old_arr_len == 0) {
        return ();
    }
    assert new_arr[old_arr_len - 1] = [old_arr];
    return reverse(old_arr_len - 1, &old_arr[1], new_arr_len + 1, new_arr);
}

func bytes_to_felt{range_check_ptr}(data_len: felt, data: felt*, n: felt) -> (n: felt) {
    if (data_len == 0) {
        return (n=n);
    }
    let e: felt = data_len - 1;
    let byte: felt = data[0];
    let (res) = pow(256, e);
    return bytes_to_felt(data_len=data_len - 1, data=data + 1, n=n + byte * res);
}

func bytes32_to_uint256(val: felt*) -> Uint256 {
    let res = Uint256(
        low=[val + 16] * 256 ** 15 + [val + 17] * 256 ** 14 + [val + 18] * 256 ** 13 + [val + 19] *
        256 ** 12 + [val + 20] * 256 ** 11 + [val + 21] * 256 ** 10 + [val + 22] * 256 ** 9 + [
            val + 23
        ] * 256 ** 8 + [val + 24] * 256 ** 7 + [val + 25] * 256 ** 6 + [val + 26] * 256 ** 5 + [
            val + 27
        ] * 256 ** 4 + [val + 28] * 256 ** 3 + [val + 29] * 256 ** 2 + [val + 30] * 256 + [
            val + 31
        ],
        high=[val] * 256 ** 15 + [val + 1] * 256 ** 14 + [val + 2] * 256 ** 13 + [val + 3] * 256 **
        12 + [val + 4] * 256 ** 11 + [val + 5] * 256 ** 10 + [val + 6] * 256 ** 9 + [val + 7] *
        256 ** 8 + [val + 8] * 256 ** 7 + [val + 9] * 256 ** 6 + [val + 10] * 256 ** 5 + [
            val + 11
        ] * 256 ** 4 + [val + 12] * 256 ** 3 + [val + 13] * 256 ** 2 + [val + 14] * 256 + [
            val + 15
        ],
    );
    return res;
}
