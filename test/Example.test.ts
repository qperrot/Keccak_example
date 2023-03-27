import { expect } from "chai";
import { starknet, ethers } from "hardhat";
import {
    StarknetContract,
    Account,
} from "hardhat/types/runtime";
import { uint256 } from "starknet";
import axios from "axios";
import { Contract } from "ethers";

async function mint(address: string, amount: number, lite = true) {
    await axios.post(`${starknet.networkConfig.url}/mint`, {
        amount,
        address,
        lite,
    });
}

describe("Example", function () {
    this.timeout(900_000);

    let owner: Account;
    let exampleContract: StarknetContract;
    let ethExample: Contract;

    before(async function () {

        owner = await starknet.OpenZeppelinAccount.createAccount();

        await mint(owner.address, 1e18);
        await owner.deployAccount({ maxFee: 1e18 });

        const exampleFactory = await starknet.getContractFactory("example");
        await owner.declare(exampleFactory, { maxFee: 1e18 });

        exampleContract = await owner.deploy(exampleFactory, {}, { maxFee: 1e18 });

        const signers = await ethers.getSigners();
        const aliceAddress = signers[0].address;
        const ethExampleFactory = await ethers.getContractFactory(
            "Example",
            aliceAddress
        );

        ethExample = await ethExampleFactory.deploy();
    });

    describe("Test getKeccak", function () {
        it("Should have the same hash than solidity", async function () {
            const { hash: hash } = await exampleContract.call("getKeccakHash", {
                value_uint256: uint256.bnToUint256(230), address: "0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266"
            });
            const solidityHash = await ethExample.getKeccak(230, "0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266");
            expect(solidityHash).to.deep.equal("0x" + uint256.uint256ToBN(hash).toString(16));
        });
    });
});