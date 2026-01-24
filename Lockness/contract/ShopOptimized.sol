// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";

contract Shop is Ownable, ReentrancyGuard, EIP712 {
    using SafeERC20 for IERC20;

    // ===============================
    // Errors
    // ===============================
    error InvalidSignature();
    error OrderExpired();
    error InvalidBuyer();
    error InvalidChainId();
    error InvalidContract();
    error OrderAlreadyProcessed();
    error SignerNotSet();
    error InsufficientQuantity();
    error InsufficientFund();

    // ===============================
    // Order
    // ===============================
    struct Order {
        bytes32 orderId;
        address buyer;
        uint256 itemId;
        uint256 quantity;
        uint256 totalAmount;
        address paymentToken;
        uint256 expiresAt;
        uint256 chainId;
        address contractAddress;
    }

    bytes32 private constant ORDER_TYPEHASH =
        keccak256(
            "Order(bytes32 orderId,address buyer,uint256 itemId,uint256 quantity,uint256 totalAmount,address paymentToken,uint256 expiresAt,uint256 chainId,address contractAddress)"
        );

    // ===============================
    // Storage
    // ===============================
    address public serverSigner;
    mapping(bytes32 => bool) public processedOrders;

    // ===============================
    // Events
    // ===============================
    event Purchased(
        bytes32 indexed orderId,
        address indexed buyer,
        uint256 indexed itemId,
        uint256 quantity,
        uint256 totalAmount,
        address paymentToken
    );

    event SignerUpdated(address signer);

    // ===============================
    // Constructor
    // ===============================
    constructor(address owner_) Ownable(owner_) EIP712("Shop", "1") {}

    // ===============================
    // Admin
    // ===============================
    function setServerSigner(address signer) external onlyOwner {
        serverSigner = signer;
        emit SignerUpdated(signer);
    }

    // ===============================
    // Buy
    // ===============================
    function buy(
        Order calldata order,
        bytes calldata signature
    ) external nonReentrant payable {
        if (serverSigner == address(0)) revert SignerNotSet();
        if (order.buyer != msg.sender) revert InvalidBuyer();
        if (order.expiresAt < block.timestamp) revert OrderExpired();
        if (order.chainId != block.chainid) revert InvalidChainId();
        if (order.contractAddress != address(this)) revert InvalidContract();
        if (processedOrders[order.orderId]) revert OrderAlreadyProcessed();

        // Verify BE signature
        bytes32 digest = _hashTypedDataV4(
            keccak256(
                abi.encode(
                    ORDER_TYPEHASH,
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
            )
        );

        address recovered = ECDSA.recover(digest, signature);
        if (recovered != serverSigner) revert InvalidSignature();

        // Mark processed
        processedOrders[order.orderId] = true;

        // Transfer token
           if (order.paymentToken == address(0)) {
            // == THANH TOÁN BẰNG 0G (NATIVE) ==
            
            // Kiểm tra khách có gửi đủ tiền không?
            if (msg.value < order.totalAmount) revert InsufficientFund();
            // Nếu muốn hoàn lại tiền thừa (optional)
          
            // if (msg.value > order.totalAmount) {
            //     payable(msg.sender).transfer(msg.value - order.totalAmount);
            // }
            
            // Tiền đã nằm trong Contract này rồi, Owner sẽ rút sau bằng hàm withdraw
        } else {
            // == THANH TOÁN BẰNG ERC20 (Như cũ) ==
            
            // Native value phải = 0 để tránh mất tiền oan
            if (msg.value > 0) revert("Do not send ETH/0G for ERC20 payment");
            IERC20(order.paymentToken).safeTransferFrom(
                msg.sender,
                address(this),
                order.totalAmount
            );
        }
       

        emit Purchased(
            order.orderId,
            msg.sender,
            order.itemId,
            order.quantity,
            order.totalAmount,
            order.paymentToken
        );
    }

    // ===============================
    // Withdraw
    // ===============================

      function withdraw(
        address token,
        address to,
        uint256 amount
    ) external onlyOwner {
        if (token == address(0)) {
            // Rút Native Token (0G)
            (bool success, ) = to.call{value: amount}("");
            require(success, "Withdraw failed");
        } else {
            // Rút ERC20 Token
            IERC20(token).safeTransfer(to, amount);
        }
    }
}
