// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Context} from "@openzeppelin/contracts/utils/Context.sol";
import "../constants/CService.sol";

abstract contract ServiceAdmin is Context, CService {
    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev Throws if called by any account other than the service admin.
     */
    modifier onlyServiceAdmin() {
        _checkAdmin();
        _;
    }

    /**
     * @dev Returns the address of the service admin.
     */
    function serviceAdmin() public view virtual returns (address) {
        return PILTONET_SERVICE_ADMIN;
    }

    /**
     * @dev Throws if the sender is not the service admin.
     */
    function _checkAdmin() internal view virtual {
        if (serviceAdmin() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }
    
}
