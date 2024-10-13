// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "../access/ServiceAdmin.sol";
import "../utils/Utils.sol";
import "./interfaces/IERC721Profile.sol";
import "./ERC6551Registry.sol";

/// @title Piltonet Profile - ERC725 contract
/// @author @FAR0KH
/// @notice This contract is used to store accounts registered in Piltonet as NFTs and release TokenBound-Accounts
contract ERC721Profile is ERC721, ERC721URIStorage, ServiceAdmin, IERC721Profile {
    uint256 private _tokenId;
    string private _baseTokenURI;

    // ERC6551Account address
    address internal _AccountImplementation;

    // ERC6551Registry contract
    ERC6551Registry internal _ERC6551Registry;

    mapping(address => uint256) private _tokenIdOf;
    mapping(address => address) private _tbaOf;
    uint256 private _totalTBAs;

    /*///////////////////////////////////////////////////////////////
                            Events
    //////////////////////////////////////////////////////////////*/
    
    event ProfileCreated(uint256 indexed tokenId, address indexed account);
    event RemoveProfile(uint256 indexed tokenId);

    /*///////////////////////////////////////////////////////////////
                            Constructor
    //////////////////////////////////////////////////////////////*/
    
    constructor(
        string memory baseURI,
        address ERC6551AccountAdr,
        address ERC6551RegistryAdr
    ) ERC721("Piltonet Profiles", "PPS") {
        _baseTokenURI = baseURI;
        
        // set ERC6551 contracts
        _AccountImplementation = ERC6551AccountAdr;
        _ERC6551Registry = ERC6551Registry(ERC6551RegistryAdr);
    }

    /*///////////////////////////////////////////////////////////////
                            Functions
    //////////////////////////////////////////////////////////////*/

    /// @notice mint profile NFT
    function createProfile(address mainAccount) public onlyServiceAdmin returns (address /* created tokenbound-account */) {
        /// @dev each account can create a unique profile
        require(balanceOf(mainAccount) == 0, "Error: Profile has already been created!");

        /// @dev tokenId values start at 1
        _tokenId++;

        /// @dev mint profilr NFT
        _safeMint(mainAccount, _tokenId);
        _tokenIdOf[mainAccount] = _tokenId;

        /// @dev create tokenbound-account
        address _tbaAddress = _ERC6551Registry.createAccount(
            _AccountImplementation,
            block.chainid,
            address(this),
            _tokenId,
            0,
            ""
        );
        _tbaOf[mainAccount] = _tbaAddress;
        _totalTBAs++;

        /// @dev tokenURI = baseURI + tbaAddress
        _setTokenURI(_tokenId, Utils.addressToString(_tbaAddress));

        emit ProfileCreated(_tokenId, _tbaAddress);

        return _tbaAddress;
    }

    /// @notice burn profile NFT
    function removeProfile(uint256 tokenId) public virtual {
        require(msg.sender == ownerOf(tokenId) || msg.sender == serviceAdmin(), "Error, Only service admin or token owner can remove!");

        /// @dev reset token ownership
        _update(address(0), tokenId, msg.sender);
        
        emit RemoveProfile(tokenId);
    }

    /// @notice return the tokenId and tokenbound-accounnt of account
    function tokenOf(address account) external view returns (uint256, address) {
        return (_tokenIdOf[account], _tbaOf[account]);
    }
    
    /// @notice return the number of exist tokenbound-accounnts
    function totalTBAs() external view returns (uint256) {
        return _totalTBAs;
    }
    
    function totalSupply() external view returns (uint256) {
        return _tokenId;
    }

    function setBaseURI(string memory baseURI) public onlyServiceAdmin {
        _baseTokenURI = baseURI;
    }

    /// @dev override IERC721 transferFrom to avoid transfer tokens
    function transferFrom(address from, address to, uint256 tokenId) public virtual override(ERC721, IERC721) {
        require(tokenId == 0, "Error: Cannot transfer profile token.");
        return super.transferFrom(from, to, tokenId);
    }

    // The following functions are overrides required by Solidity.
    
    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }
    
    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}