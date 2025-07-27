// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract LNT is ERC20, AccessControl, Pausable, ReentrancyGuard, Ownable {
    // Define roles
    bytes32 public constant TASK_MANAGER_ROLE = keccak256("TASK_MANAGER_ROLE");

    // Addresses for reward pool and treasury
    address public rewardPool = 0x66130818dB6c33CC9d8ef14845548Ef08E6118AD;
    address public treasury= 0x149f9c20480A4DC264DAEdC1396a0E06a3848724;

    // Define events for transparency
    event TokensRewarded(address indexed user, uint256 amount, string taskId);
    event TokensSpent(address indexed user, uint256 amount, string itemOrServiceId);
    event TokensRecovered(address indexed token, address indexed to, uint256 amount);
    event RewardPoolSet(address indexed rewardPool);
    event TreasurySet(address indexed treasury);

    // Constructor: Initialize token with 1 billion supply
    constructor(address initialOwner) 
        ERC20("LocknessToken", "LNT")
        Ownable(initialOwner)
    {
        _mint(initialOwner, 1_000_000_000 * 10**decimals());
        _grantRole(DEFAULT_ADMIN_ROLE, initialOwner);
        _grantRole(TASK_MANAGER_ROLE, initialOwner);
    }

    // Modifier to check non-zero address
    modifier nonZeroAddress(address account) {
        require(account != address(0), "Invalid address");
        _;
    }

    // Set reward pool address (only owner)
    function setRewardPool(address _rewardPool) external onlyOwner nonZeroAddress(_rewardPool) {
        rewardPool = _rewardPool;
        emit RewardPoolSet(_rewardPool);
    }

    // Set treasury address (only owner)
    function setTreasury(address _treasury) external onlyOwner nonZeroAddress(_treasury) {
        treasury = _treasury;
        emit TreasurySet(_treasury);
    }

    // Reward tokens to a user for completing a task
    function rewardTokens(
        address user,
        uint256 amount,
        string calldata taskId
    ) external onlyRole(TASK_MANAGER_ROLE) whenNotPaused nonReentrant nonZeroAddress(user) {
        require(rewardPool != address(0), "Reward pool not set");
        require(amount > 0, "Amount must be greater than zero");
        require(balanceOf(rewardPool) >= amount, "Insufficient reward pool balance");

        _transfer(rewardPool, user, amount);
        emit TokensRewarded(user, amount, taskId);
    }

    // Spend tokens on items or services
    function spendTokens(
        uint256 amount,
        string calldata itemOrServiceId
    ) external whenNotPaused nonReentrant {
        require(treasury != address(0), "Treasury not set");
        require(amount > 0, "Amount must be greater than zero");
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");

        _transfer(msg.sender, treasury, amount);
        emit TokensSpent(msg.sender, amount, itemOrServiceId);
    }

    // Pause contract (only owner)
    function pause() external onlyOwner {
        _pause();
    }

    // Unpause contract (only owner)
    function unpause() external onlyOwner {
        _unpause();
    }

    // Recover tokens accidentally sent to the contract
    function recoverTokens(
        address token,
        address to,
        uint256 amount
    ) external onlyOwner nonZeroAddress(to) {
        require(token != address(this), "Cannot recover LNT tokens");
        require(amount > 0, "Amount must be greater than zero");
        IERC20(token).transfer(to, amount);
        emit TokensRecovered(token, to, amount);
    }

    // Override decimals to ensure compatibility
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }
}


// pragma solidity ^0.8.20;

// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// import "@openzeppelin/contracts/access/AccessControl.sol";
// import "@openzeppelin/contracts/security/Pausable.sol";
// import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";



// contract LNT is ERC20, AccessControl, Pausable, ReentrancyGuard, Ownable {
//     // Define roles
//     bytes32 public constant TASK_MANAGER_ROLE = keccak256("TASK_MANAGER_ROLE");

//     // Define events for transparency
//     event TokensRewarded(address indexed user, uint256 amount, string taskId);
//     event TokensSpent(address indexed user, uint256 amount, string itemOrServiceId);
//     event TokensRecovered(address indexed token, address indexed to, uint256 amount);

//     // Constructor: Initialize token with 1 billion supply
//     constructor(address initialOwner) 
//         ERC20("LocknessToken", "LNT")
//         Ownable(initialOwner)
//     {
//         _mint(initialOwner, 1_000_000_000 * 10**decimals());
//         _grantRole(DEFAULT_ADMIN_ROLE, initialOwner);
//         _grantRole(TASK_MANAGER_ROLE, initialOwner);
//     }

//     // Modifier to check non-zero address
//     modifier nonZeroAddress(address account) {
//         require(account != address(0), "Invalid address");
//         _;
//     }

//     // Reward tokens to a user for completing a task
//     function rewardTokens(
//         address user,
//         uint256 amount,
//         string calldata taskId
//     ) external onlyRole(TASK_MANAGER_ROLE) whenNotPaused nonReentrant nonZeroAddress(user) {
//         require(amount > 0, "Amount must be greater than zero");
//         require(balanceOf(owner()) >= amount, "Insufficient owner balance");

//         _transfer(owner(), user, amount);
//         emit TokensRewarded(user, amount, taskId);
//     }

//     // Spend tokens on items or services
//     function spendTokens(
//         uint256 amount,
//         string calldata itemOrServiceId
//     ) external whenNotPaused nonReentrant {
//         // Ascertain that the amount is valid and the user has enough tokens
//         require(amount > 0, "Amount must be greater than zero");
//         require(balanceOf(msg.sender) >= amount, "Insufficient balance");

//         _burn(msg.sender, amount);
//         emit TokensSpent(msg.sender, amount, itemOrServiceId);
//     }

//     // Pause contract (only owner)
//     function pause() external onlyOwner {
//         _pause();
//     }

//     // Unpause contract (only owner)
//     function unpause() external onlyOwner {
//         _unpause();
//     }

//     // Recover tokens accidentally sent to the contract
//     function recoverTokens(
//         address token,
//         address to,
//         uint256 amount
//     ) external onlyOwner nonZeroAddress(to) {
//         require(amount > 0, "Amount must be greater than zero");
//         IERC20(token).transfer(to, amount);
//         emit TokensRecovered(token, to, amount);
//     }

//     // Override decimals to ensure compatibility
//     function decimals() public view virtual override returns (uint8) {
//         return 18;
//     }

  
// }