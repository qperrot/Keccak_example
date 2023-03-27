import { HardhatUserConfig } from "hardhat/types";
import "@shardlabs/starknet-hardhat-plugin";
import "@nomiclabs/hardhat-ethers";
import "@openzeppelin/hardhat-upgrades";
import "hardhat-deploy";
import "@nomiclabs/hardhat-truffle5";
import "@nomiclabs/hardhat-waffle";
import "@openzeppelin/hardhat-upgrades";
import "hardhat-contract-sizer";
import "hardhat-gas-reporter";
import "@nomiclabs/hardhat-solhint";
import "prettier-plugin-solidity";
import "solidity-coverage";
import "@typechain/hardhat";
import "@nomiclabs/hardhat-etherscan";

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
const config: HardhatUserConfig = {
    solidity: {
        compilers: [
            {
                version: "0.8.7",
                settings: {
                    optimizer: {
                        enabled: true,
                        runs: 200,
                    },
                },
            },
        ],
    },

    starknet: {
        // dockerizedVersion: "0.10.3",
        network: "devnet",
        venv: "active",
        wallets: {
            OpenZeppelin: {
                accountName: "OpenZeppelin",
                modulePath:
                    "starkware.starknet.wallets.open_zeppelin.OpenZeppelinAccount",
                accountPath: "~/.starknet_accounts",
            },
        },
    },
    networks: {
        devnet: {
            url: "http://127.0.0.1:5050",
        },
        integratedDevnet: {
            url: "http://127.0.0.1:5050",
            venv: "active",
            args: ["--timeout", "10000"],
        },
    },
    paths: {
        sources: "./contracts",
        starknetSources: "./contracts/cairo",
        artifacts: "./artifacts",
    },
};
export default config;
