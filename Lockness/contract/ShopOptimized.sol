// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20; // Updated to latest stable version

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol"; // For proper EIP-712 support
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

// Permit2 Interface (Deploy this separately on 0G chain)
interface IPermit2 {
    struct PermitSingle {
        address token;
        uint256 amount;
        uint48 expiration;
        uint48 nonce;
    }

    struct SignatureTransferDetails {
        address to;
        uint256 requestedAmount;
    }

    function permit(address owner, PermitSingle calldata permitSingle, bytes calldata signature) external;
    function transferFrom(address from, address to, uint160 amount, address token) external;
}

// Custom Errors for gas optimization
error InvalidSignature();
error SignerNotSet();
error OrderExpired();
error InvalidBuyer();
error InvalidChainId();
error InvalidContract();
error OrderAlreadyProcessed();
error InvalidPaymentToken(); // If needed for native/ERC20 checks
error WithdrawFailed();

contract ShopOptimized is Ownable, ReentrancyGuard, EIP712 {
    using SafeERC20 for IERC20;
    using ECDSA for bytes32;

    // EIP-712 Domain (initialized in constructor)
    // We use EIP712 for typed data signing

    // Order Struct matching your flow
    struct Order {
        bytes32 orderId;       // keccak256(uuid + wallet + time) off-chain
        address buyer;
        uint256 itemId;
        uint256 quantity;
        uint256 totalAmount;
        address paymentToken;  // ERC20 token address (assume no native for simplicity; add if needed)
        uint256 expiresAt;     // Timestamp
        uint256 chainId;       // To prevent cross-chain replay
        address contractAddress; // This contract's address
    }

    // Permit2 address (set in constructor or setter)
    IPermit2 public immutable permit2;

    // Signature Verification
    address public serverSigner;

    // Replay protection: orderId => processed
    mapping(bytes32 => bool) public processedOrders;

    // Events
    event Purchased(
        bytes32 indexed orderId,
        address indexed buyer,
        uint256 itemId,
        uint256 quantity,
        uint256 totalAmount,
        address paymentToken
    );
    event SignerUpdated(address newSigner);

    constructor(address initialOwner) Ownable(initialOwner) EIP712("Shop", "1") {
        permit2 = IPermit2(0xE1f9845683E24Cfd8c7b651d209361B3691c0e0a); // Deploy Permit2 separately and pass address here
    }

    // =====================================================
    // Owner: Management
    // =====================================================
    function setSigner(address _signer) external onlyOwner {
        serverSigner = _signer;
        emit SignerUpdated(_signer);
    }

    // =====================================================
    // BUY FUNCTION (Matching your flow + Permit2)
    // =====================================================
    // User calls this with order (from BE), orderSig (EIP-712 from BE), permit (for token approve), permitSig
    function buy(
        Order calldata order,
        bytes calldata orderSig,
        IPermit2.PermitSingle calldata permit,
        bytes calldata permitSig
    ) external nonReentrant {
        if (serverSigner == address(0)) revert SignerNotSet();

        // Step 3.1: Validate order basics
        if (block.timestamp > order.expiresAt) revert OrderExpired();
        if (order.chainId != block.chainid) revert InvalidChainId();
        if (order.contractAddress != address(this)) revert InvalidContract();
        if (order.buyer != msg.sender) revert InvalidBuyer();

        // Step 3.2: Verify EIP-712 signature from backend
        bytes32 structHash = keccak256(abi.encode(
            keccak256("Order(bytes32 orderId,address buyer,uint256 itemId,uint256 quantity,uint256 totalAmount,address paymentToken,uint256 expiresAt,uint256 chainId,address contractAddress)"),
            order.orderId,
            order.buyer,
            order.itemId,
            order.quantity,
            order.totalAmount,
            order.paymentToken,
            order.expiresAt,
            order.chainId,
            order.contractAddress
        ));
        bytes32 hash = _hashTypedDataV4(structHash);
        address recoveredSigner = ECDSA.recover(hash, orderSig);
        if (recoveredSigner != serverSigner) revert InvalidSignature();

        // Step 3.3: Replay protection
        if (processedOrders[order.orderId]) revert OrderAlreadyProcessed();
        processedOrders[order.orderId] = true;

        // Step 3.4: Handle payment (using Permit2 for ERC20)
        // Assume paymentToken is always ERC20 (token 0G if wrapped; adjust if native)
        // Permit2: Permit first, then transfer
        permit2.permit(msg.sender, permit, permitSig);
        permit2.transferFrom(msg.sender, address(this), uint160(order.totalAmount), order.paymentToken);

        // Step 3.5: Emit event (source of truth for BE listener)
        emit Purchased(
            order.orderId,
            msg.sender,
            order.itemId,
            order.quantity,
            order.totalAmount,
            order.paymentToken
        );
    }

    // =====================================================
    // Owner Withdraw Funds (Keep for withdrawing collected tokens)
    // =====================================================
    function withdrawERC20(address token, address to, uint256 amount) external onlyOwner {
        IERC20(token).safeTransfer(to, amount);
    }

    // If supporting native (optional)
    function withdrawNative(address payable to, uint256 amount) external onlyOwner {
        (bool success, ) = to.call{value: amount}("");
        if (!success) revert WithdrawFailed();
    }

    receive() external payable {}
}