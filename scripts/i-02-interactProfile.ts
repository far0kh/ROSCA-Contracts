import { ethers } from "hardhat";
import getRevertReason from './getRevertReason';

async function main() {
  const NETWORK = process.env.DEFAULT_NETWORK;
  const deploymentsDir = `.${process.env.OUTCOME_CONTRACTS_PATH}/deployments/${NETWORK}`;
  const deployedERC721Profile = require(`${deploymentsDir}/ERC721Profile.json`);

  const Contract = await ethers.getContractAt("contracts/tba/ERC721Profile.sol:ERC721Profile", deployedERC721Profile.address);

  let createProfile = await Contract.createProfile("0x543eEF693E6911D806168BafCD5A14f8DeA19A5A", {
    gasLimit: 4000000
  });
  // console.log('createProfile: ', createProfile);

  try {
    const tx = await createProfile.wait();
    const dd = decodeMessage(tx.hash);
    console.log(tx.hash, dd);
  } catch(error: any) {
    const result = await getRevertReason(error.receipt.hash);
    console.error(result);
  }

  // const result = await getRevertReason(tbaAddress.hash);
  // console.log(result);
  

  let totalSupply = await Contract.totalSupply();
  console.log('totalSupply: ', totalSupply);
  
  for(let i=1; i<=totalSupply; i++) {
    let tokenURI = await Contract.tokenURI(i);
    console.log('tokenID: ', i, 'tokenURI: ', tokenURI);
  }
  
}

function decodeMessage(code: string) {
  // NOTE: `code` may end with 0's which will return a text string with empty whitespace characters
  // This will truncate all 0s and set up the hex string as expected
  let codeString = `0x${code.substring(138)}`.replace(/0+$/, '');

  // If the codeString is an odd number of characters, add a trailing 0
  if (codeString.length % 2 === 1) {
    codeString += '0'
  }

  return ethers.toUtf8String(codeString)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});