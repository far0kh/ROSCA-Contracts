import { ethers } from "hardhat";
import * as fs from 'fs';
import getRevertReason from './getRevertReason';

async function main() {
  const NETWORK = process.env.DEFAULT_NETWORK;
  const abiDir = `${process.env.CONTRACTS_ABI_PATH}/abi`;
  const outcomeAbiDir = `${process.env.OUTCOME_CONTRACTS_PATH}/abi`;
  const deploymentsDir = `${process.env.OUTCOME_CONTRACTS_PATH}/deployments/${NETWORK}`;

  const deployedERC6551Account = require(`.${deploymentsDir}/ERC6551Account.json`);
  const deployedERC6551Registry = require(`.${deploymentsDir}/ERC6551Registry.json`);

  const [deployer] = await ethers.getSigners();
  console.log("Deploying contract with the account:", deployer.address);

  // ERC721Profile
  const ERC721Profile = await ethers.deployContract("contracts/tba/ERC721Profile.sol:ERC721Profile", [
    "https://piltonet.com/profile/",
    deployedERC6551Account.address,
    deployedERC6551Registry.address
  ], {
    gasLimit: 6000000
  });
  console.log("Deploying contract in expected address:", await ERC721Profile.getAddress());
  
  try {
    await ERC721Profile.waitForDeployment();

    const ProfileContract = {
      deployer: deployer.address,
      address: await ERC721Profile.getAddress()
    }
    fs.writeFileSync(`${deploymentsDir}/ERC721Profile.json`, JSON.stringify(ProfileContract))
    console.log("ERC721Profile deployed to:", ProfileContract.address);
  
    // copy abi file to outcome/abi
    fs.copyFileSync(`${abiDir}/ERC721Profile.json`, `${outcomeAbiDir}/ERC721Profile.json`);

    // add service admin to profile
    let createProfile = await ERC721Profile.createProfile(process.env.SERVICE_ADMIN_PUBLIC_KEY, {
      gasLimit: 4000000
    });
    await createProfile.wait();
    console.log('Service admin has been added to the profile.');
    

  } catch(error: any) {
    if(error.receipt) {
      const result = await getRevertReason(error.receipt.hash);
      console.error(result);
    } else {
      console.log(error);
    }
  }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});