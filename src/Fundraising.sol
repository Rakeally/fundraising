// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interface/IFundraising.sol";
import "./interface/IFundraisingErrors.sol";
import {console} from "forge-std/console.sol";
/**
 * @title Fundraising Contract
 * @dev A smart contract for creating and managing fundraising compaigns.
 * Implements ERC1155 tokens to reward donors and uses structured mappings for compaign and donation management.
 */
contract Fundraising is ERC1155, Ownable(msg.sender), IFundraising, IFundraisingErrors {

    constructor(string memory uri) ERC1155(uri) {}

    // Structure to hold compaign details
    struct Compaign {
        string name;           // Compaign name
        string description;    // Compaign description
        uint goalAmount;       // Target amount to be raised
        uint deadline;         // Deadline for the compaign
        address organizer;     // Address of the compaign organizer
        uint currentDonation;  // Total funds donated so far
        bool isCompleted;      // Flag indicating whether the compaign is completed
    }

    // Structure to hold donation details
    struct Donation {
        address donor; // Address of the donor
        uint amount;   // Amount donated
    }

    // Mappings for compaign and donation management
    mapping(uint => Compaign) public compaigns;             // Compaign details by ID
    mapping(uint => Donation[]) public compaignDonations;   // List of donations by compaign ID
    mapping(address => uint[]) public donorToCompaigns;     // Compaigns associated with each donor
    mapping(address => bool) public isAdmin;                // Admin status by address
    mapping(uint => uint) public totalTokenMinted;          // Total tokens minted for each compaign ID
    mapping(uint => bool) public isCompaignActive;          // Active state of compaigns

    // Modifiers for access control and validations
    modifier onlyAdmin(address _address) {
        if (!isAdmin[_address]) revert UnauthorizedCaller(msg.sender);
        _;
    }

    modifier onlyCompaignOwner(uint compaignId) {
        if (compaigns[compaignId].organizer != msg.sender) revert UnauthorizedCaller(msg.sender);
        _;
    }

    modifier compaignIsActive(uint id) {
        if (!isCompaignActive[id]) revert InActive(id);
        _;
    }

    modifier compaignExist(uint id) {
        if (compaigns[id].goalAmount == 0) revert NonExistant(id);
        _;
    }

    /**
     * @dev Add a new admin.
     * @param _address Address of the new admin.
     */
    function addAdmin(address _address) external onlyOwner {
        isAdmin[_address] = true;
        emit adminUpdate(_address, "Added");
    }

    /**
     * @dev Remove an existing admin.
     * @param _address Address of the admin to be removed.
     */
    function removeAdmin(address _address) external onlyOwner {
        isAdmin[_address] = false;
        emit adminUpdate(_address, "Removed");
    }

    /**
     * @dev Create a new fundraising compaign.
     * @param id Unique identifier for the compaign.
     * @param name Compaign name.
     * @param description Compaign description.
     * @param goalAmount Target fundraising amount.
     * @param deadline Compaign deadline (timestamp).
     */
    function createCompaign(uint id, string memory name, string memory description, uint goalAmount, uint deadline) external {
        if (compaigns[id].goalAmount != 0) revert AlreadyExist("This ID has already been used");
        if (deadline < block.timestamp) revert InvalidDeadline("Deadline must be after the current time");
        if (goalAmount <= 0) revert InvalidValue(goalAmount);

        compaigns[id] = Compaign(name, description, goalAmount, deadline, msg.sender, 0, false);
        isCompaignActive[id] = true;

        emit compaignCreated(id, name, msg.sender, deadline);
    }

    /**
     * @dev Update the deadline of a compaign.
     * @param id Compaign ID.
     * @param newDeadline New deadline (timestamp).
     */
    function updateCompaignDeadline(uint id, uint newDeadline) external compaignExist(id) onlyCompaignOwner(id) {
        require(newDeadline > block.timestamp, "New deadline must be in the future");
        compaigns[id].deadline = newDeadline;

        emit compaignDeadlineUpdated(id, newDeadline);
    }

    /**
     * @dev Deactivate a compaign.
     * @param id Compaign ID.
     */
    function desactivateCompaign(uint id) external compaignExist(id) {
        if (msg.sender != compaigns[id].organizer && !isAdmin[msg.sender]) revert UnauthorizedCaller(msg.sender);
        if (!isCompaignActive[id]) revert RedundantStateChange(id, false);

        isCompaignActive[id] = false;
        emit compaignStateUpdated(id, false);
    }

    /**
     * @dev Reactivate a compaign.
     * @param id Compaign ID.
     */
    function activateCompaign(uint id) external onlyAdmin(msg.sender) compaignExist(id) {
        if (isCompaignActive[id]) revert RedundantStateChange(id, true);

        isCompaignActive[id] = true;
        emit compaignStateUpdated(id, true);
    }

    /**
     * @dev Donate to a compaign.
     * @param id Compaign ID.
     */
    function donate(uint id) external payable compaignExist(id) compaignIsActive(id) {
        Compaign storage compaign = compaigns[id];
        if (block.timestamp > compaign.deadline) revert FundraisingClosed(id);
        if (compaign.isCompleted) revert FundraisingCompleted(id);
        if(msg.value < 0) revert InvalidValue(msg.value);

        compaign.currentDonation += msg.value;
        compaignDonations[id].push(Donation(msg.sender, msg.value));
        _mint(msg.sender, id, msg.value, "");
        totalTokenMinted[id] += msg.value;

        if (compaign.currentDonation >= compaign.goalAmount) {
            compaign.isCompleted = true;
        }

        donorToCompaigns[msg.sender].push(id);
        emit DonationFunded(id, msg.sender, msg.value);
    }

    /**
     * @dev Refund all donors of a compaign if goals not met.
     * @param id Compaign ID.
     */
    function refund(uint id) external compaignExist(id) compaignIsActive(id) onlyCompaignOwner(id) {
        Compaign memory compaign = compaigns[id];
        if(compaign.currentDonation >= compaign.goalAmount) revert GoalAttain(id);
        if(compaign.currentDonation == 0) revert GoalNotAttain(id);
        if(compaign.currentDonation < address(this).balance) revert InsufficientBalance(id);
        if(block.timestamp < compaign.deadline) revert FundraisingOngoing(id);
        if(compaign.isCompleted == true) revert FundraisingCompleted(id);
        _refundAllDonors(id);
        
    }

    /**
     * @dev Internal function to process refunds to all donors of a compaign.
     * @param id Compaign ID.
     */
    function _refundAllDonors(uint id) internal {
        Donation[] memory donations = compaignDonations[id];
        uint donationsLength = donations.length;

        assembly {
            let ptr := add(donations, 0x20)
            for {
                let endPtr := add(ptr, mul(donationsLength, 0x40))
            } lt(ptr, endPtr) {
                ptr := add(ptr, 0x40)
            } {
                let donor := mload(ptr)
                let amount := mload(add(ptr, 0x20))

                if gt(amount, 0) {
                    // Refund Ether to donor
                    if iszero(call(gas(), donor, amount, 0, 0, 0, 0)) {
                        revert(0, 0)
                    }

                    // Burn tokens - calling burn() on this contract
                    let burnSelector := 0x9dc29fac00000000000000000000000000000000000000000000000000000000
                    mstore(0x00, burnSelector)
                    mstore(0x04, and(donor, 0xffffffffffffffffffffffffffffffffffffffff))
                    mstore(0x24, id)
                    mstore(0x44, amount)
                    
                    // Call burn() on this contract (address(this))
                    let success := call(
                        gas(),          // gas
                        address(),      // target address (this contract)
                        0,              // no ether sent
                        0x00,           // input offset in memory
                        0x64,           // input size (4 + 32 + 32 + 32 = 100 bytes)
                        0x00,           // output offset
                        0x00            // output size (no return data expected)
                    )
                    if iszero(success) {
                        revert(0, 0)
                    }
                }
            }
        }

        // Update state
        delete compaignDonations[id];
        isCompaignActive[id] = false;
        compaigns[id].currentDonation = 0;
        emit DonorsReFunded(id);
    }


   /**
     * @dev Withdraw funds raised for a compaign.
     * @param id Compaign ID.
     */
  function withdraw(uint id) external compaignExist(id) onlyCompaignOwner(id) compaignIsActive(id) {
    Compaign storage compaign = compaigns[id];
    
    if(address(this).balance < compaign.currentDonation) revert InsufficientBalance(id);
    if(compaign.currentDonation < compaign.goalAmount) revert GoalNotAttain(id);
    
    uint amount = compaign.currentDonation;
    
    isCompaignActive[id] = false;
    compaign.currentDonation = 0;
    
    (bool success, ) = payable(msg.sender).call{value: amount}("");
    require(success);
    
    emit Withdrawal(id, msg.sender, amount);
}
    


}


