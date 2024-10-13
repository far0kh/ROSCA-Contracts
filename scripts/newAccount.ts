import { ethers } from "hardhat";
import * as fs from 'fs';

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contract with the account:", deployer.address);

  // ERC6551Account
  const TBA = "0x7A1887Ae460B3137DdEb7D9BbC2e8e7B673bE606";
  // const factory = new ethers.ContractFactory("contracts/tba/ERC6551Account.sol:ERC6551Account", this.signer)
  //   return await factory.deploy(...deployArgs, {
	// 		gasLimit: 6000000
	// 	})
  
  // const ContractFactory = await ethers.getContractAt("contracts/tba/ERC6551Account.sol:ERC6551Account", TBA);
  let ContractFactory = await ethers.getContractFactory("contracts/tba/ERC6551Account.sol:ERC6551Account");
  // let contract_owner = await ethers.getSigner(network.config.from);
  const ERC6551Account = await ContractFactory.deploy({
    gasLimit: 4000000
  });
  // console.log("Contract address:", contract.address);
  // console.log("Contract owner:", contract_owner);
  // console.log("Contract creation transaction:", contract.deployTransaction.hash);
  
  // const ERC6551Account = await ethers.deployContract("contracts/tba/ERC6551Account.sol:ERC6551Account", {
  //   gasLimit: 4000000
  // });
  const ERC6551AccountContract = {
    deployer: deployer.address,
    address: await ERC6551Account.getAddress()
  }
  console.log("ERC6551Account deployed to:", ERC6551AccountContract.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});