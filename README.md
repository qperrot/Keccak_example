# Keccak_example
Example of How to make Cairo's Keccak hash to match with Solidity’s Keccak and vice-versa?

## Contracts
The `contracts` directory contains the following subfolders:

```
contracts/cairo
	utils/ - contains utility functions as bytes and some other common functions
	exemple.cairo - the main contract that calculate keccak256(abi.encodePacked(...)) in cairo;

contracts/solidity
	exemple.sol - the main contract that return keccak256(abi.encodePacked(...));
```

## Functions

- `getKeccakOnlyUint` return keccak256(abi.encodePacked(uint256, uint256));

- `getKeccakUintAddress` return keccak256(abi.encodePacked(uint256, address));

- `getKeccakAddressUint` return keccak256(abi.encodePacked(address, uint256));
```
contracts/cairo
	utils/ - contains utility functions as bytes and some other common functions
	exemple.cairo - the main contract that calculate keccak256(abi.encodePacked(...)) in cairo;

contracts/solidity
	exemple.sol - the main contract that return keccak256(abi.encodePacked(...));
```

## Running the tests
1. Make sure to have docker installed and running.

1. `yarn install` to install the required packages including [StarkNet.js](https://www.starknetjs.com/), [HardHat](https://hardhat.org/), and the [StarkNet Hardhat Plugin](https://shard-labs.github.io/starknet-hardhat-plugin/).

1. `yarn compile` to create `./starknet-artifacts/` with the compiled contracts.

1. Open another terminal, then run `npx hardhat node`.

1. Open another terminal, then run `starknet-devnet`.

1. `yarn test` to execute the test.
