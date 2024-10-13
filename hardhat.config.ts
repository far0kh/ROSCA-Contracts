import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import 'dotenv/config'

const config: HardhatUserConfig = {
  solidity: "0.8.24",
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
