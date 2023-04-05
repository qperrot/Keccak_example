%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.cairo_keccak.keccak import (
    finalize_keccak,
    keccak_bigend,
    keccak_add_uint256s,
    keccak_uint256s_bigend,
)
from starkware.cairo.common.bool import TRUE
from starkware.cairo.common.memcpy import memcpy

from utils.common import felt_to_uint256, pad_right
from utils.bytes import bytes32_to_uint256, bytes_i_to_uint256, uint256_to_bytes_array

@constructor
func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    return ();
}

// Similar to keccak256(abi.encodePacked(a_uint256, b_uint256));
// @view
// func exercise1{
//     syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr, bitwise_ptr: BitwiseBuiltin*
// }(a_uint256: Uint256, b_uint256: Uint256, c_uint256: Uint256, d_uint256: Uint256) -> (
//     hash: Uint256
// ) {
// }

// Similar to keccak256(abi.encodePacked(uint256,bytes32, address));
// @view
// func exercise2{
//     syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr, bitwise_ptr: BitwiseBuiltin*
// }(a_uint256: Uint256, b_uint256: Uint256, address: felt) -> (hash: Uint256) {
// }

// Similar to keccak256(abi.encodePacked(uint256, address, uint256, uint256));
// @view
// func exercise3{
//     syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr, bitwise_ptr: BitwiseBuiltin*
// }(a_uint256: Uint256, address: felt, b_uint256: Uint256, c_uint256: Uint256) -> (hash: Uint256) {
// }

// Similar to keccak256(abi.encodePacked(uint256, address, uint8, uint8));
// @view
// func exercise4{
//     syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr, bitwise_ptr: BitwiseBuiltin*
// }(a_uint256: Uint256, address: felt, b_uint8: Uint256, c_uint8: Uint256) -> (hash: Uint256) {
// }

func _fill_bytes_array{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr, bitwise_ptr: BitwiseBuiltin*
}(first: Uint256, second: Uint256, len: felt) -> (first: Uint256, second: Uint256) {
    alloc_locals;

    let offset = 32 - len;
    // Convert uint256 to byte array
    let (first_array_len, first_byte_array) = uint256_to_bytes_array(first);
    let (second_array_len, second_byte_array) = uint256_to_bytes_array(second);

    // Move bytes from second array to first array to make it 32 bytes
    let (local new_first_byte_array: felt*) = alloc();
    memcpy(dst=new_first_byte_array, src=first_byte_array + offset, len=len);
    memcpy(dst=new_first_byte_array + len, src=second_byte_array, len=offset);

    // Move bytes left from second array to new_second_array
    let (local new_second_byte_array: felt*) = alloc();
    memcpy(dst=new_second_byte_array, src=second_byte_array + offset, len=len);

    let first = bytes32_to_uint256(new_first_byte_array);
    let second = bytes_i_to_uint256(new_second_byte_array, len);

    return (first, second);
}
