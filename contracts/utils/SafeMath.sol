// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title SafeMath
/// @notice Math operations with safety checks that throw on error
library SafeMath {
	function mul(uint256 a, uint256 b) internal pure returns (uint256) {
		uint256 c = a * b;
		assert(a == 0 || c / a == b);
		return c;
	}

	function sub(uint256 a, uint256 b) internal pure returns (uint256) {
		assert(b <= a);
		return a - b;
	}

	function add(uint256 a, uint256 b) internal pure returns (uint256) {
		uint256 c = a + b;
		assert(c >= a);
		return c;
	}
	
	function div(uint256 a, uint256 b) internal pure returns (uint256) {
		assert(b != 0);
		return a / b;
	}

	function max(uint256 a, uint256 b) external pure returns (uint256) {
    return a >= b ? a : b;
	}
}