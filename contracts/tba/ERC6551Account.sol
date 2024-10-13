// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/interfaces/IERC1271.sol";
import "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "./interfaces/IERC6551Account.sol";
import "./interfaces/IERC6551Executable.sol";

contract ERC6551Account is
    IERC165,
    IERC1271,
    IERC6551Account,
    IERC6551Executable,
    ERC1155Holder
{
    uint256 public state;
    bytes32 public accountName;

    receive() external payable {}

    function setAccountName(bytes32 newName_) public {
        require(_isValidSigner(msg.sender), "Invalid signer");
        accountName = newName_;
    }

    function getAccountName() public view returns (bytes32) {
        return accountName;
    }

    function execute(
        address to,
        uint256 value,
        bytes calldata data,
        uint256 operation
    ) external payable returns (bytes memory result) {
        require(_isValidSigner(msg.sender), "Invalid signer");
        require(operation == 0, "Only call operations are supported");

        ++state;

        bool success;
        (success, result) = to.call{value: value}(data);

        if (!success) {
            assembly {
                revert(add(result, 32), mload(result))
            }
        }
    }

    function isValidSigner(
        address signer,
        bytes calldata
    ) external view returns (bytes4) {
        if (_isValidSigner(signer)) {
            return IERC6551Account.isValidSigner.selector;
        }

        return bytes4(0);
    }

    function isValidSignature(
        bytes32 hash,
        bytes memory signature
    ) external view returns (bytes4 magicValue) {
        bool isValid = SignatureChecker.isValidSignatureNow(
            owner(),
            hash,
            signature
        );

        if (isValid) {
            return IERC1271.isValidSignature.selector;
        }

        return "";
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC1155Holder, IERC165) returns (bool) {
        return
            (interfaceId == type(IERC165).interfaceId ||
                interfaceId == type(IERC6551Account).interfaceId ||
                interfaceId == type(IERC6551Executable).interfaceId) ||
            interfaceId == type(IERC1155Receiver).interfaceId;
    }

    function token() public view returns (uint256, address, uint256) {
        bytes memory footer = new bytes(0x60);

        assembly {
            extcodecopy(address(), add(footer, 0x20), 0x4d, 0x60)
        }

        return abi.decode(footer, (uint256, address, uint256));
    }

    function owner() public view returns (address) {
        (uint256 chainId, address tokenContract, uint256 tokenId) = token();
        if (chainId != block.chainid) return address(0);

        return IERC721(tokenContract).ownerOf(tokenId);
    }

    function _isValidSigner(address signer) internal view returns (bool) {
        return signer == owner();
    }
}
