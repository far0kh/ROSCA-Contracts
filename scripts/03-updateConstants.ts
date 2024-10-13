import * as fs from 'fs';

async function main() {
  const NETWORK = process.env.DEFAULT_NETWORK;
  const deploymentsDir = `.${process.env.OUTCOME_CONTRACTS_PATH}/deployments/${NETWORK}`;
  const deployedERC721Profile = require(`${deploymentsDir}/ERC721Profile.json`);

  let newConstants = `// SPDX-License-Identifier: MIT
  pragma solidity ^0.8.20;
  
  abstract contract CService {
      // Piltonet Services Admin
      address internal constant PILTONET_SERVICE_ADMIN = ${process.env.SERVICE_ADMIN_PUBLIC_KEY};
      
      // ERC721Profile Implementation
      address internal constant PILTONET_PROFILE_ADDRESS = ${deployedERC721Profile.address};
      
      // ContactList Implementation
      address internal constant PILTONET_CONTACTLIST_ADDRESS = address(0);
  }`;

  fs.writeFileSync("./contracts/constants/CService.sol", newConstants);
  console.log("Service constants updated to:", newConstants);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});