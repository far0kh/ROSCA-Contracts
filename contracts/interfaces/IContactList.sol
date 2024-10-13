// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

interface IContactList {
    /// @dev return true if account1 is contact of account2
    function isContact(address account1, address account2) external view returns (bool);
}