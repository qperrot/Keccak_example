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

from utils.common import felt_to_uint256, pad_right, get_bytes_len
from utils.bytes import bytes32_to_uint256, bytes_i_to_uint256, uint256_to_bytes_array

@constructor
func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    return ();
}

// Similar to keccak256(abi.encodePacked(a_uint256, b_uint256));
@view
func getKeccakOnlyUint{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr, bitwise_ptr: BitwiseBuiltin*
}(a_uint256: Uint256, b_uint256: Uint256) -> (hash: Uint256) {
    alloc_locals;
    let (local keccak_ptr: felt*) = alloc();
    let keccak_ptr_start = keccak_ptr;

    let (data_uint: Uint256*) = alloc();
    assert data_uint[0] = a_uint256;
    assert data_uint[1] = b_uint256;

    // Compute the hash
    let (hash) = keccak_uint256s_bigend{keccak_ptr=keccak_ptr}(n_elements=2, elements=data_uint);

    finalize_keccak(keccak_ptr_start=keccak_ptr_start, keccak_ptr_end=keccak_ptr);
    return (hash,);
}

// Similar to keccak256(abi.encodePacked(uint256, address));
@view
func getKeccakUintAddress{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr, bitwise_ptr: BitwiseBuiltin*
}(a_uint256: Uint256, address: felt) -> (hash: Uint256) {
    alloc_locals;
    let (local keccak_ptr: felt*) = alloc();
    let keccak_ptr_start = keccak_ptr;

    let (address_uint256) = felt_to_uint256(address);
    // Do right padding if address len is less than 32
    let (padded_address) = pad_right(address_uint256, 20);

    let (data_uint: Uint256*) = alloc();
    assert data_uint[0] = a_uint256;
    assert data_uint[1] = padded_address;

    let (signable_bytes) = alloc();
    let signable_bytes_start = signable_bytes;
    keccak_add_uint256s{inputs=signable_bytes}(n_elements=2, elements=data_uint, bigend=TRUE);

    // Compute the hash
    let (hash) = keccak_bigend{keccak_ptr=keccak_ptr}(inputs=signable_bytes_start, n_bytes=32 + 20);

    finalize_keccak(keccak_ptr_start=keccak_ptr_start, keccak_ptr_end=keccak_ptr);
    return (hash,);
}

// Similar to keccak256(abi.encodePacked(address, uint256));
@view
func getKeccakAddressUint{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr, bitwise_ptr: BitwiseBuiltin*
}(address: felt, value_uint256: Uint256) -> (hash: Uint256) {
    alloc_locals;
    let (local keccak_ptr: felt*) = alloc();
    let keccak_ptr_start = keccak_ptr;

    let (address_uint256) = felt_to_uint256(address);
    // Move bytes so only last array will be less than 32 bytes
    let (address_uint256, value_uint256) = _fill_bytes_array(address_uint256, value_uint256, 20);

    // Do right padding if address len is less than 32
    let (padded_value_uint256) = pad_right(value_uint256, 20);

    let (data_uint: Uint256*) = alloc();
    assert data_uint[0] = address_uint256;
    assert data_uint[1] = padded_value_uint256;

    let (signable_bytes) = alloc();
    let signable_bytes_start = signable_bytes;
    keccak_add_uint256s{inputs=signable_bytes}(n_elements=2, elements=data_uint, bigend=TRUE);

    // Compute the hash
    let (hash) = keccak_bigend{keccak_ptr=keccak_ptr}(inputs=signable_bytes_start, n_bytes=32 + 20);

    finalize_keccak(keccak_ptr_start=keccak_ptr_start, keccak_ptr_end=keccak_ptr);
    return (hash,);
}

// Similar to keccak256(abi.encodePacked(a_uint8, b_uint8));
@view
func getKeccakUint8{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr, bitwise_ptr: BitwiseBuiltin*
}(a_uint8: Uint256, b_uint8: Uint256) -> (hash: Uint256) {
    alloc_locals;
    let (local keccak_ptr: felt*) = alloc();
    let keccak_ptr_start = keccak_ptr;
    let (a_bytes_len) = get_bytes_len(a_uint8);
    let (b_bytes_len) = get_bytes_len(b_uint8);

    // Do right padding if address len is less than 32
    let (b_uint8_pad) = pad_right(b_uint8, b_bytes_len);

    let (a_uint8, b_uint8_pad) = _fill_bytes_array(a_uint8, b_uint8_pad, a_bytes_len);
    let (a_bytes_len) = get_bytes_len(a_uint8);

    let (b_bytes_len) = get_bytes_len(b_uint8_pad);

    let (data_uint: Uint256*) = alloc();
    assert data_uint[0] = a_uint8;

    let (signable_bytes) = alloc();
    let signable_bytes_start = signable_bytes;
    keccak_add_uint256s{inputs=signable_bytes}(n_elements=1, elements=data_uint, bigend=TRUE);

    // Compute the hash
    let (hash) = keccak_bigend{keccak_ptr=keccak_ptr}(inputs=signable_bytes_start, n_bytes=2);

    finalize_keccak(keccak_ptr_start=keccak_ptr_start, keccak_ptr_end=keccak_ptr);

    return (hash,);
}

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
