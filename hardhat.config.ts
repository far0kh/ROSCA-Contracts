import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import 'hardhat-abi-exporter';
import 'dotenv/config'

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.24",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
      viaIR: true,
    },
  },
  abiExporter: {
    path: `${process.env.CONTRACTS_ABI_PATH}/abi`,
    runOnCompile: true,
    clear: true,
    flat: true,
    spacing: 2,
  },
  defaultNetwork: process.env.DEFAULT_NETWORK,
  networks: {
    bob: {
      url: "https://rpc.gobob.xyz/",
      accounts: [process.env.SERVICE_ADMIN_PRIVATE_KEY || ""]
    },
    bobtestnet: {
      // url: "https://bob-sepolia.rpc.gobob.xyz",
      url: "https://testnet.rpc.gobob.xyz/",
      accounts: [process.env.SERVICE_ADMIN_PRIVATE_KEY || ""]
    }
  },
};

export default config;
