// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

interface IERC721Profile {
    /// @notice return the tokenId and tokenbound-accounnt of account
    function tokenOf(address account) external view returns (uint256, address);
}