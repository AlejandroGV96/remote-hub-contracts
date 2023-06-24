import { HardhatUserConfig } from "hardhat/config";
import "dotenv/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomiclabs/hardhat-etherscan";

const ALCHEMY_SEPOLIA_RPC_URL = process.env.ALCHEMY_SEPOLIA_RPC_URL ?? "";
const WALLET_PRIVATE_KEY = process.env.WALLET_PRIVATE_KEY ?? "";
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY ?? "";

const config: HardhatUserConfig = {
    solidity: "0.8.7",
    defaultNetwork: "hardhat",
    networks: {
        sepolia: {
            url: ALCHEMY_SEPOLIA_RPC_URL,
            accounts: [WALLET_PRIVATE_KEY],
            gasPrice: 10000000000,
            chainId: 11155111,
        },
        localhost: {
            url: "http://127.0.0.1:8545/",
            chainId: 31337,
        },
    },
    etherscan: {
        apiKey: ETHERSCAN_API_KEY,
    },
};

export default config;

