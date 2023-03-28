// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.7;

contract Example {
    constructor() {}

    /// @dev Calculates keccak hash.
    /// @param _a_uint A value of type uint256.
    /// @param _b_uint A value of type uint256.
    function getKeccakOnlyUint(
        uint256 _a_uint,
        uint256 _b_uint
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_a_uint, _b_uint));
    }

    /// @dev Calculates keccak hash.
    /// @param _value A value of type uint256.
    /// @param _address An address.
    function getKeccakUintAddress(
        uint256 _value,
        address _address
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_value, _address));
    }

    /// @dev Calculates keccak hash.
    /// @param _address An address.
    /// @param _value A value of type uint256.
    function getKeccakAddressUint(
        address _address,
        uint256 _value
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_address, _value));
    }

    // / @dev Return abi.,encodePacked hash.
    // / @param _address An address.
    // / @param _value A value of type uint256.
    // function getAbiEncodePacked(
    //     address _address,
    //     uint256 _value
    // ) public pure returns (bytes memory) {
    //     return abi.encodePacked(_address, _value);
    // }
}
