import { ethers } from "hardhat";

async function main() {
  const NETWORK = process.env.DEFAULT_NETWORK;
  const chainId = 89;
  const deploymentsDir = `.${process.env.OUTCOME_CONTRACTS_PATH}/deployments/${NETWORK}`;

  const deployedDIDNFTs = require(`${deploymentsDir}/DIDNFTs.json`);
  const deployedDIDAccount = require(`${deploymentsDir}/DIDAccount.json`);
  const deployedDIDRegistry = require(`${deploymentsDir}/DIDRegistry.json`);

  const DIDNFTs = await ethers.getContractAt("DIDNFTs", deployedDIDNFTs.address);
  const DIDAccount = await ethers.getContractAt("DIDAccount", deployedDIDAccount.address);
  const DIDRegistry = await ethers.getContractAt("DIDRegistry", deployedDIDRegistry.address);

  // const _to = "0xf2137CF292bfBdF6B5C5458941E38Ea117AfC0f4";
  const _to = "0x94688d177029574FE9013006811261377FE52DD2";
  const _id = parseInt((await DIDNFTs.totalSupply()).toString()) + 1;
  
  // Mint New DIDNFTs if account has not one
  if((await DIDNFTs.balanceOf(_to)).toString() == "0") {
    console.log(`Minting new DIDNFTs to: ${_to} id: ${_id}`);
    await DIDNFTs.safeMint(_to, "https://api.piltonet.com/did/{id}", {
      gasLimit: 6000000
    });
    console.log("Minting DIDNFTs Successfuly");
  } else {
    console.log("The DIDNFTs has been already minted.");
  }


  // New DIDAccount Registry
  console.log("Creating a new DIDAccount");
  const newDIDAccount = await DIDRegistry.createAccount(
    deployedDIDAccount.address, // implementation contract
    chainId,
    deployedDIDNFTs.address, // parent NFT
    _id, // token ID
    0, // salt
    "0x", // init calldata
    {gasLimit: 6000000}
  );
  console.log("New DIDAccount Created. Transaction ID:", newDIDAccount.hash);

  // New DIDAccount Address 
  const newDIDAccountAddress = await DIDRegistry.account(
    deployedDIDAccount.address, // implementation contract
    chainId,
    deployedDIDNFTs.address, // parent NFT
    _id, // token ID
    0, // salt
  );
  console.log(`DIDAccount Address for ${_to} is:`, newDIDAccountAddress);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});