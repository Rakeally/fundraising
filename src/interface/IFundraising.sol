// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface IFundraising {

    /**
     * @dev Emitted when a new compaign is created.
     * @param id The unique identifier of the compaign.
     * @param name The name of the compaign.
     * @param organizer The address of the compaign organizer.
     * @param deadline The deadline of the compaign in UNIX timestomp format.
     */
    event compaignCreated(uint id, string name, address indexed organizer, uint deadline);

    /**
     * @dev Emitted when a compaign's deadline is updated.
     * @param id The unique identifier of the compaign.
     * @param newDeadline The new deadline for the compaign in UNIX timestomp format.
     */
    event compaignDeadlineUpdated(uint id, uint newDeadline);

    /**
     * @dev Emitted when the admin list is updated (addition or removal of an admin).
     * @param adminAddress The address of the admin being updated.
     * @param message A descriptive message regarding the admin update.
     */
    event adminUpdate(address adminAddress, string message);

    /**
     * @dev Emitted when the state of a compaign is updated (activated or deactivated).
     * @param id The unique identifier of the compaign.
     * @param state The new state of the compaign (true for active, false for inactive).
     */
    event compaignStateUpdated(uint id, bool state);

    /**
     * @dev Emitted when a donor contributes to a compaign.
     * @param id The unique identifier of the compaign.
     * @param donor The address of the donor.
     * @param amount The amount of funds donated in wei.
     */
    event DonationFunded(uint id, address indexed donor, uint amount);

    /**
     * @dev Emitted when donors are refunded due to compaign cancellation or unmet goals.
     * @param id The unique identifier of the compaign.
     */
    event DonorsReFunded(uint id);

    /**
     * @dev Emitted when a compaign organizer withdraws funds from the compaign.
     * @param id The unique identifier of the compaign.
     * @param organizer The address of the compaign organizer withdrawing the funds.
     * @param amount The amount of funds withdrawn in wei.
     */
    event Withdrawal(uint id, address indexed organizer, uint amount);

    /**
     * @dev Adds a new admin to the contract.
     * @param _address The address of the new admin.
     */
    function addAdmin(address _address) external;

    /**
     * @dev Removes an admin from the contract.
     * @param _address The address of the admin to be removed.
     */
    function removeAdmin(address _address) external;

    /**
     * @dev Creates a new donation compaign.
     * @param id The unique identifier of the compaign.
     * @param name The name of the compaign.
     * @param description A description of the compaign's purpose and details.
     * @param goalAmount The funding goal of the compaign in wei.
     * @param deadline The deadline for the compaign in UNIX timestomp format.
     */
    function createCompaign(uint id, string calldata name, string calldata description, uint goalAmount, uint deadline) external;

    /**
     * @dev Updates the deadline of an existing compaign.
     * @param id The unique identifier of the compaign.
     * @param newDeadline The new deadline for the compaign in UNIX timestomp format.
     */
    function updateCompaignDeadline(uint id, uint newDeadline) external;

    /**
     * @dev Deactivates a compaign, preventing further donations.
     * @param id The unique identifier of the compaign.
     */
    function desactivateCompaign(uint id) external;

    /**
     * @dev Reactivates a compaign, allowing donations to resume.
     * @param id The unique identifier of the compaign.
     */
    function activateCompaign(uint id) external;

    /**
     * @dev Allows a donor to contribute funds to a compaign.
     * @param id The unique identifier of the compaign.
     * @notice The donor must send Ether along with the transaction.
     */
    function donate(uint id) external payable;

    /**
     * @dev Refunds all donors of a compaign. Typically used if the compaign fails to meet its goal or is canceled.
     * @param id The unique identifier of the compaign.
     * @notice Only the organizer of the compaign can initiate refund
     */
    function refund(uint id) external;

    /**
     * @dev Allows the compaign organizer to withdraw funds raised for a compaign.
     * @param id The unique identifier of the compaign.
     * @notice Only the organizer of the compaign can withdraw funds.
     */
    function withdraw(uint id) external;
}



    
