// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../constants/CService.sol";
import "../access/RegisteredTBA.sol";
import "../interfaces/IContactList.sol";

abstract contract TrustedContact is CService, RegisteredTBA {

    /**
     * @dev Returns the address of the ContactList contract.
     */
    function contactListAddress() public view virtual returns (address) {
        return PILTONET_CONTACTLIST_ADDRESS;
    }

    /*///////////////////////////////////////////////////////////////
                            Modifiers
    //////////////////////////////////////////////////////////////*/
    
    modifier onlyMyContact(address account) {
        require(
            isContact(msg.sender, account),
            "Error: The account is not a trusted contact."
        );
        _;
    }
    
    modifier onlyContacts(address account, address[] memory accounts) {
        require(
            areContacts(account, accounts),
            "Error: Not all accounts are trusted contact."
        );
        _;
    }
    
    
    /*///////////////////////////////////////////////////////////////
                            Getters
    //////////////////////////////////////////////////////////////*/

    function isContact(address account1, address account2) internal view returns (bool) {
        return IContactList(payable(PILTONET_CONTACTLIST_ADDRESS)).isContact(account1, account2);
    }

    function areContacts(address account, address[] memory accounts) internal view returns (bool) {
        IContactList _ContactList = IContactList(payable(PILTONET_CONTACTLIST_ADDRESS));
        for (uint256 i = 0; i < accounts.length; i++) {
            if (!_ContactList.isContact(account, accounts[i])) return false;
        }
        return true;
    }

}
