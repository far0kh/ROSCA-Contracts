import { ethers } from "hardhat";
import * as fs from 'fs';
import getRevertReason from './getRevertReason';

async function main() {
  const NETWORK = process.env.DEFAULT_NETWORK;
  // const abiDir = `${process.env.CONTRACTS_ABI_PATH}/abi`;
  // const outcomeAbiDir = `${process.env.OUTCOME_CONTRACTS_PATH}/abi`;
  // const deploymentsDir = `${process.env.OUTCOME_CONTRACTS_PATH}/deployments/${NETWORK}`;
  // if (!fs.existsSync(deploymentsDir)) fs.mkdirSync(deploymentsDir);

  const [deployer] = await ethers.getSigners();
  console.log("Deploying contract with the account:", deployer.address);

  // Test1
  const Test1 = await ethers.deployContract("contracts/Storage.sol:Storage", {
    // gasLimit: 4000000
  });
  console.log("Deploying contract in expected address:", await Test1.getAddress());

  try {
    await Test1.waitForDeployment();

    const Test1Contract = {
      deployer: deployer.address,
      address: await Test1.getAddress()
    }
    // fs.writeFileSync(`${deploymentsDir}/Test1.json`, JSON.stringify(Test1Contract))
    // console.log("Test1 deployed to:", Test1Contract.address);

    // // copy abi file to outcome/abi
    // fs.copyFileSync(`${abiDir}/Test1.json`, `${outcomeAbiDir}/Test1.json`);
  } catch (error: any) {
    const result = await getRevertReason(error.receipt.hash);
    console.error(result);
  }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});