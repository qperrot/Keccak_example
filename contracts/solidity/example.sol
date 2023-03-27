// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.7;

contract Example {
    constructor() {}

    /// @dev Calculates keccak hash.
    /// @param _value A value of type uint256.
    /// @param _address An address.
    function getKeccak(
        uint256 _value,
        address _address
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_address, _value));
    }
}
