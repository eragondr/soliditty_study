// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";


contract LNT is ERC20, Ownable, ReentrancyGuard, Pausable, AccessControl {
    // Define roles for access control
    bytes32 public constant REWARDER_ROLE = keccak256("REWARDER_ROLE");
    // Total supply: 10,000,000,000 tokens with 18 decimals
    uint256 private constant TOTAL_SUPPLY = 10_000_000_000 * 10**18;
    // Maximum reward per transaction (e.g., 1,000 tokens)
    uint256 private constant MAX_REWARD = 1_000 * 10**18;
}