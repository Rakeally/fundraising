// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/**
 * @dev Interface defining custom errors for fundraising smart contract.
 */
interface IFundraisingErrors {
    /**
     * @dev Error for invalid values provided in a transaction or function call.
     * @param value The invalid value provided.
     */
    error InvalidValue(uint value);

    /**
     * @dev Error for invalid or zero-address inputs.
     * @param _address The invalid address provided.
     */
    error InvalidAddress(address _address);

    /**
     * @dev Error for operations attempting to create or use a resource that already exists.
     * @param message A descriptive message about the duplication.
     */
    error AlreadyExist(string message);

    /**
     * @dev Error for invalid or improperly set campaign deadlines.
     * @param message A descriptive message about the deadline issue.
     */
    error InvalidDeadline(string message);

    /**
     * @dev Error for operations involving non-existent campaigns.
     * @param id The unique identifier of the campaign that does not exist.
     */
    error NonExistant(uint id);

    /**
     * @dev Error for attempts to change a campaign's state to the same state it already has.
     * @param id The unique identifier of the campaign.
     * @param state The redundant state being attempted.
     */
    error RedundantStateChange(uint id, bool state);

    /**
     * @dev Error for unauthorized access or operations by a caller.
     * @param _address The address of the unauthorized caller.
     */
    error UnauthorizedCaller(address _address);

    /**
     * @dev Error for operations on campaigns that are inactive.
     * @param id The unique identifier of the inactive campaign.
     */
    error InActive(uint id);

    /**
     * @dev Error for donations or actions on campaigns that have closed.
     * @param id The unique identifier of the closed campaign.
     */
    error FundraisingClosed(uint id);

    /**
     * @dev Error for donations or actions on campaigns that is still ongoing.
     * @param id The unique identifier of the ongoing campaign.
     */
    error FundraisingOngoing(uint id);

    /**
     * @dev Error for operations on campaigns that have already reached their goal.
     * @param id The unique identifier of the completed campaign.
     */
    error FundraisingCompleted(uint id);

    /**
     * @dev Error for withdrawals or actions attempted before a campaign is eligible.
     * @param id The unique identifier of the campaign that is not yet mature.
     */
    error NotMature(uint id);

    /**
     * @dev Error for withdrawals and refunds exceeding the available balance of a campaign.
     * @param id The unique identifier of the campaign with insufficient balance.
     */
    error InsufficientBalance(uint id);

    /**
     * @dev Error for Refund when goals already met.
     * @param id The unique identifier of the campaign with a complete goal.
     */
    error GoalAttain(uint id);

    /**
     * @dev Error for Refund when goals not met.
     * @param id The unique identifier of the campaign with unattained goal.
     */
    error GoalNotAttain(uint id);
}
