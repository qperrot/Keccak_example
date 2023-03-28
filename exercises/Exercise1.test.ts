import { expect } from "chai";
import { starknet, ethers } from "hardhat";
import {
    StarknetContract,
    Account,
} from "hardhat/types/runtime";
import { uint256 } from "starknet";
import axios from "axios";

async function mint(address: string, amount: number, lite = true) {
    await axios.post(`${starknet.networkConfig.url}/mint`, {
        amount,
        address,
        lite,
    });
}

describe("Exercise 1", function () {
    this.timeout(900_000);

    let owner: Account;
    let exerciseContract: StarknetContract;

    before(async function () {
        owner = await starknet.OpenZeppelinAccount.createAccount();

        await mint(owner.address, 1e18);
        await owner.deployAccount({ maxFee: 1e18 });

        const exerciseFactory = await starknet.getContractFactory("exercises");
        await owner.declare(exerciseFactory, { maxFee: 1e18 });

        exerciseContract = await owner.deploy(exerciseFactory, {}, { maxFee: 1e18 });
    });

    describe("Test exercise 1", function () {
        it("Should have the same hash as solidity keccak256(abi.encodePacked(uint256, uint256, uint256, uint256))", async function () {
            const { hash: hash } = await exerciseContract.call("exercise1", {
                a_uint256: uint256.bnToUint256(230), b_uint256: uint256.bnToUint256(30), c_uint256: uint256.bnToUint256(1287), d_uint256: uint256.bnToUint256(2)
            });
            const solidityHash = ethers.utils.solidityKeccak256(
                ["uint256", "uint256", "uint256", "uint256"],
                [230, 30, 1287, 2]
            );
            const starknetHash = "0x" + uint256.uint256ToBN(hash).toString(16);
            console.log("Solidity hash: ", solidityHash);
            console.log("Starknet hash: ", starknetHash);
            expect(solidityHash).to.deep.equal(starknetHash);
        });
    });
});
