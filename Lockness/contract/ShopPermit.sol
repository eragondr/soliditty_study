// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// =========================
// Imports
// =========================
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

// =========================
// Permit2 Interface
// (Deploy separately on 0G chain)
// =========================
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

    function permit(
        address owner,
        PermitSingle calldata permitSingle,
        bytes calldata signature
    ) external;

    function transferFrom(
        address from,
        address to,
        uint160 amount,
        address token
    ) external;
}

// =========================
// Custom Errors (Gas Optimized)
// =========================
error InvalidSignature();
error SignerNotSet();
error OrderExpired();
error InvalidBuyer();
error InvalidChainId();
error InvalidContract();
error OrderAlreadyProcessed();
error InvalidPaymentToken();
error WithdrawFailed();

// =========================
// Contract
// =========================
contract ShopOptimized is Ownable, ReentrancyGuard, EIP712 {
    using SafeERC20 for IERC20;
    using ECDSA for bytes32;

    // =========================
    // Structs
    // =========================
    struct Order {
        bytes32 orderId;            // keccak256(uuid + wallet + time) off-chain
        address buyer;
        uint256 itemId;
        uint256 quantity;
        uint256 totalAmount;
        address paymentToken;        // ERC20 token
        uint256 expiresAt;           // Timestamp
        uint256 chainId;             // Prevent cross-chain replay
        address contractAddress;     // This contract address
    }

    // =========================
    // State Variables
    // =========================
    IPermit2 public immutable permit2;
    address public serverSigner;

    // Replay protection
    mapping(bytes32 => bool) public processedOrders;

    // =========================
    // Events
    // =========================
    event Purchased(
        bytes32 indexed orderId,
        address indexed buyer,
        uint256 itemId,
        uint256 quantity,
        uint256 totalAmount,
        address paymentToken
    );

    event SignerUpdated(address newSigner);

    // =========================
    // Constructor
    // =========================
    constructor(address initialOwner)
        Ownable(initialOwner)
        EIP712("Shop", "1")
    {
        permit2 = IPermit2(
            0xE1f9845683E24Cfd8c7b651d209361B3691c0e0a
        );
    }

    // =========================
    // Owner Functions
    // =========================
    function setSigner(address _signer) external onlyOwner {
        serverSigner = _signer;
        emit SignerUpdated(_signer);
    }

    // =========================
    // Buy Function (Permit2 + EIP-712)
    // =========================
    function buy(
        Order calldata order,
        bytes calldata orderSig,
        IPermit2.PermitSingle calldata permit,
        bytes calldata permitSig
    ) external nonReentrant {
        if (serverSigner == address(0)) revert SignerNotSet();

        // --- Order validation ---
        if (block.timestamp > order.expiresAt) revert OrderExpired();
        if (order.chainId != block.chainid) revert InvalidChainId();
        if (order.contractAddress != address(this)) revert InvalidContract();
        if (order.buyer != msg.sender) revert InvalidBuyer();

        // --- Signature verification ---
        bytes32 structHash = keccak256(
            abi.encode(
                keccak256(
                    "Order(bytes32 orderId,address buyer,uint256 itemId,uint256 quantity,uint256 totalAmount,address paymentToken,uint256 expiresAt,uint256 chainId,address contractAddress)"
                ),
                order.orderId,
                order.buyer,
                order.itemId,
                order.quantity,
                order.totalAmount,
                order.paymentToken,
                order.expiresAt,
                order.chainId,
                order.contractAddress
            )
        );

        bytes32 hash = _hashTypedDataV4(structHash);
        address recoveredSigner = ECDSA.recover(hash, orderSig);

        if (recoveredSigner != serverSigner) revert InvalidSignature();

        // --- Replay protection ---
        if (processedOrders[order.orderId]) revert OrderAlreadyProcessed();
        processedOrders[order.orderId] = true;

        // --- Payment via Permit2 ---
        permit2.permit(msg.sender, permit, permitSig);
        permit2.transferFrom(
            msg.sender,
            address(this),
            uint160(order.totalAmount),
            order.paymentToken
        );

        // --- Emit purchase event ---
        emit Purchased(
            order.orderId,
            msg.sender,
            order.itemId,
            order.quantity,
            order.totalAmount,
            order.paymentToken
        );
    }

    // =========================
    // Withdraw Functions
    // =========================
    function withdrawERC20(
        address token,
        address to,
        uint256 amount
    ) external onlyOwner {
        IERC20(token).safeTransfer(to, amount);
    }

    function withdrawNative(
        address payable to,
        uint256 amount
    ) external onlyOwner {
        (bool success, ) = to.call{value: amount}("");
        if (!success) revert WithdrawFailed();
    }

    receive() external payable {}
}
