import { ethers } from "hardhat";
import * as fs from 'fs';
import getRevertReason from './getRevertReason';

async function main() {
  const NETWORK = process.env.DEFAULT_NETWORK;
  const abiDir = `${process.env.CONTRACTS_ABI_PATH}/abi`;
  const outcomeAbiDir = `${process.env.OUTCOME_CONTRACTS_PATH}/abi`;
  const deploymentsDir = `${process.env.OUTCOME_CONTRACTS_PATH}/deployments/${NETWORK}`;

  const [deployer] = await ethers.getSigners();
  console.log("Deploying contract with the account:", deployer.address);

  // ContactList
  const ContactList = await ethers.deployContract("contracts/ContactList.sol:ContactList", [
    "https://piltonet.com/profile/"
  ], {
    gasLimit: 6000000
  });
  console.log("Deploying contract in expected address:", await ContactList.getAddress());
  
  try {
    await ContactList.waitForDeployment();

    const ContactsContract = {
      deployer: deployer.address,
      address: await ContactList.getAddress()
    }
    fs.writeFileSync(`${deploymentsDir}/ContactList.json`, JSON.stringify(ContactsContract))
    console.log("ContactList deployed to:", ContactsContract.address);
  
    // copy abi file to outcome/abi
    fs.copyFileSync(`${abiDir}/ContactList.json`, `${outcomeAbiDir}/ContactList.json`);
  } catch(error: any) {
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