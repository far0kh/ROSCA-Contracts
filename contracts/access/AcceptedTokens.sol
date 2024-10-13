// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

abstract contract AcceptedTokens {
    address[] internal PAYMENT_TOKENS = [address(0), 0xFB52f08F093BF0c8841826050CbfF11a9dAFC7d5]; // [VIC, CUSD]
    string[] internal TOKEN_SYMBOLS = ["VIC", "CUSD"];
    uint8[] internal TOKEN_DECIMALS = [18, 6];
    
    // Minimum Round Payment x 10**TOKEN_DECIMALS
    uint256[] internal MIN_ROUND_PAY = [
        10 * 10**TOKEN_DECIMALS[0], // VIC
        10 * 10**TOKEN_DECIMALS[1] // CUSD
    ];

    // Maximum Round Payment x 10**TOKEN_DECIMALS
    uint256[] internal MAX_ROUND_PAY = [
        500 * 10**TOKEN_DECIMALS[0], // VIC
        500 * 10**TOKEN_DECIMALS[1] // CUSD
    ]; 

    /**
     * @dev Returns the address of accepted tokens.
     */
    function acceptedTokens() public view virtual returns (address[] memory) {
        return PAYMENT_TOKENS;
    }

    /*///////////////////////////////////////////////////////////////
                            Modifiers
    //////////////////////////////////////////////////////////////*/
    
    modifier onlyAcceptedTokens(address token) {
        require(
            isAcceptedTokens(token),
            "Error: The token is not accepted."
        );
        _;
    }
    
    /*///////////////////////////////////////////////////////////////
                            Getters
    //////////////////////////////////////////////////////////////*/

    function isAcceptedTokens(address token) internal view returns (bool) {
        for (uint256 i = 0; i < PAYMENT_TOKENS.length; i++) {
            if (token == PAYMENT_TOKENS[i]) return true;
        }
        return false;
    }
    
    function getRoundPayments(address token) internal view
        onlyAcceptedTokens(token) 
        returns (
            uint256 minRoundPay,
            uint256 maxRoundPay,
            uint8 tokenDecimals
        ) {
        for (uint256 i = 0; i < PAYMENT_TOKENS.length; i++) {
            if (token == PAYMENT_TOKENS[i]) return (MIN_ROUND_PAY[i], MAX_ROUND_PAY[i], TOKEN_DECIMALS[i]);
        }
    }
}
