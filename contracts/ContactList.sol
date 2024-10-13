// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "./access/ServiceAdmin.sol";
import "./access/RegisteredTBA.sol";
import "./utils/Utils.sol";

/// @title Piltonet Contacts - ERC1155 contract
/// @author @FAR0KH
/// @notice This contract is used to store trust relationships between accounts registered in Profile contract
/// @custom:security-contact security@piltonet.com
contract ContactList is ERC1155, ERC1155Supply, ServiceAdmin, RegisteredTBA {
    
    /// @dev store tba as main owner of its tokenId 
    mapping(uint256 => address) private _idOwner;
    
    /// @dev store confirmed contacts
    mapping(address => address[]) private _contactList;
    
    /*///////////////////////////////////////////////////////////////
                            Events
    //////////////////////////////////////////////////////////////*/
    
    event ContactAdded(uint256 indexed tokenId, address indexed account, address indexed contact);

    /*///////////////////////////////////////////////////////////////
                            Constructor
    //////////////////////////////////////////////////////////////*/
    
    constructor(
      string memory baseURI
    )
        ERC1155(baseURI)
    {}

    /*///////////////////////////////////////////////////////////////
                            Functions
    //////////////////////////////////////////////////////////////*/

    function addContact(address contactTBA) public
        onlyTBASender()
        onlyRegisteredTBA(contactTBA)
    {
        mintContactToken(msg.sender, contactTBA);
    }

    /// @dev temporarily due to json-rpc error
    function addContactByService(address profileTBA, address contactTBA) public
        onlyServiceAdmin()
        onlyRegisteredTBA(profileTBA)
        onlyRegisteredTBA(contactTBA)
    {
        mintContactToken(profileTBA, contactTBA);
    }

    function mintContactToken(address profileTBA, address contactTBA) internal {
        require(profileTBA != contactTBA, "Error: The account cannot be its own contact!");

        /// @dev get the tokenId of the profile tokenbound-account from ERC6551Account
        uint256 tokenId = getTBATokenId(profileTBA);

        /// @dev store the profile tokenbound-account as the main owner of its tokenId 
        _idOwner[tokenId] = profileTBA;

        /// @dev mint token if contact has not been added yet
        if(balanceOf(contactTBA, tokenId) == 0) {
            _mint(contactTBA, tokenId, 1, "");
        
            /// @dev store in contact list if both have the other token 
            if(balanceOf(profileTBA, getTBATokenId(contactTBA)) > 0) {
                _contactList[profileTBA].push(contactTBA);
                _contactList[contactTBA].push(profileTBA);
            }

            emit ContactAdded(tokenId, profileTBA, contactTBA);
        }
    }

    function isContact(address account1, address account2) public view
        onlyRegisteredTBA(account1)
        onlyRegisteredTBA(account2)
        returns (bool)
    {
        return (balanceOf(account1, getTBATokenId(account2)) > 0
            && balanceOf(account2, getTBATokenId(account1)) > 0);
    }

    function setURI(string memory newuri) public onlyServiceAdmin {
        _setURI(newuri);
    }
    
    /// @notice return the URI same as ERC721Profile tokenURI
    function uri(uint256 tokenId) public view override(ERC1155) returns (string memory) {
        return string(abi.encodePacked(
            ERC1155.uri(tokenId),
            Utils.addressToString(_idOwner[tokenId])
        ));
    }

    /// @dev override ERC1155 safeTransferFrom to avoid transfer tokens
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 value,
        bytes memory data
    ) public virtual override(ERC1155) onlyServiceAdmin {
        return super.safeTransferFrom(from, to, id, value, data);
    }
    
    /// @dev override ERC1155 safeTransferFrom to avoid transfer tokens
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values,
        bytes memory data
    ) public virtual override(ERC1155) onlyServiceAdmin {
        return super.safeBatchTransferFrom(from, to, ids, values, data);
    }

    // The following functions are overrides required by Solidity.

    function _update(address from, address to, uint256[] memory ids, uint256[] memory values)
        internal
        override(ERC1155, ERC1155Supply)
    {
        super._update(from, to, ids, values);
    }

}