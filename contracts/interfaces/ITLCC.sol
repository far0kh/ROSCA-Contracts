// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

interface ITLCC {
    /*///////////////////////////////////////////////////////////////
                            Events
    //////////////////////////////////////////////////////////////*/

    event LogTLCCDeployed(address contractAddress);
    event LogContributionMade(
        address indexed user,
        uint256 amount,
        uint256 currentRound
    );
    event LogStartOfRound(uint256 currentRound);
    event LogBidSurpassed(
        uint256 prevBid,
        address indexed prevWinnerAddress,
        uint256 currentRound
    );
    event LogNewLowestBid(
        uint256 bid,
        address indexed winnerAddress,
        uint256 currentRound
    );
    event LogRoundFundsReleased(
        address indexed winnerAddress,
        uint256 amount,
        uint256 roundDiscount,
        uint256 currentRound
    );
    event LogFundsWithdrawal(
        address indexed user,
        uint256 amount,
        uint256 currentRound
    );
    // Fired when withdrawer is entitled for a larger amount than the contract
    // actually holds (excluding fees). A LogFundsWithdrawal will follow
    // this event with the actual amount released, if send() is successful.
    event LogCannotWithdrawFully(
        address indexed user,
        uint256 creditAmount,
        uint256 currentRound
    );
    event LogUnsuccessfulBid(
        address indexed bidder,
        uint256 bid,
        uint256 lowestBid,
        uint256 currentRound
    );
    event LogEndOfTLCC();
    event LogForepersonSurplusWithdrawal(uint256 amount);
    event LogFeesWithdrawal(uint256 amount);

    // Escape hatch related events.
    event LogEscapeHatchEnabled();
    event LogEscapeHatchActivated();
    event LogEmergencyWithdrawalPerformed(
        uint256 fundsDispersed,
        uint256 currentRound
    );
    

}