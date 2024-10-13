import { ethers } from "hardhat";
import * as fs from 'fs';
import getRevertReason from './getRevertReason';

async function main() {
  const NETWORK = process.env.DEFAULT_NETWORK;
  const abiDir = `${process.env.CONTRACTS_ABI_PATH}/abi`;
  const outcomeAbiDir = `${process.env.OUTCOME_CONTRACTS_PATH}/abi`;
  const deploymentsDir = `${process.env.OUTCOME_CONTRACTS_PATH}/deployments/${NETWORK}`;
  if (!fs.existsSync(deploymentsDir)) fs.mkdirSync(deploymentsDir);

  const [deployer] = await ethers.getSigners();
  console.log("Deploying contract with the account:", deployer.address);

  // ERC6551Account
  const ERC6551Account = await ethers.deployContract("contracts/tba/ERC6551Account.sol:ERC6551Account", {
    gasLimit: 4000000
  });
  console.log("Deploying contract in expected address:", await ERC6551Account.getAddress());

  try {
    await ERC6551Account.waitForDeployment();

    const ERC6551AccountContract = {
      deployer: deployer.address,
      address: await ERC6551Account.getAddress()
    }
    fs.writeFileSync(`${deploymentsDir}/ERC6551Account.json`, JSON.stringify(ERC6551AccountContract))
    console.log("ERC6551Account deployed to:", ERC6551AccountContract.address);

    // copy abi file to outcome/abi
    fs.copyFileSync(`${abiDir}/ERC6551Account.json`, `${outcomeAbiDir}/ERC6551Account.json`);
  } catch (error: any) {
    if (error.receipt) {
      const result = await getRevertReason(error.receipt.hash);
      console.error(result);
    } else {
      console.error(error);
    }
  }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});