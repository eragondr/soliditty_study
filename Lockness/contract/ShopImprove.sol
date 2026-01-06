// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol"; // Security: Handling non-standard ERC20s (USDT)
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface INFTMinter {
    function mintTo(address to, uint256 tokenId) external;
}

contract ShopOptimized is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    // ===============================
    // Custom Errors (Gas Optimization)
    // ===============================
    // Replaces expensive require strings
    error PriceZero();
    error ItemDoesNotExist();
    error ItemNotActive();
    error InvalidQuantity();
    error InsufficientStock();
    error WrongNativeAmount();
    error WithdrawFailed();
    error QtyOneRequiredForNFT();

    // ===============================
    // Item Definition
    // ===============================
    enum ItemType { OffChain, ERC20Redeemable, NFT_Transfer, NFT_Mintable }

    struct Item {
        // Slot 0: Price (256 bits)
        uint256 price;
        
        // Slot 1: NFT Token ID (256 bits)
        uint256 nftTokenId;

        // Slot 2: Packed to exactly 256 bits
        address paymentToken; // 160 bits
        uint88 quantity;      // 88 bits (Max ~300 septillion, plenty for stock)
        ItemType itemType;    // 8 bits
        
        // Slot 3: Packed
        address nftContract;  // 160 bits
        bool active;          // 8 bits
        // 88 bits remaining in this slot
        
        // Slot 4: String data
        string name;
    }

    mapping(uint256 => Item) public items;
    uint256 public nextItemId = 1;

    // ===============================
    // Events
    // ===============================
    event ItemAdded(uint256 indexed itemId, string name, ItemType itemType);
    event ItemUpdated(uint256 indexed itemId);
    event ItemDeactivated(uint256 indexed itemId);
    event Purchased(
        address indexed buyer,
        uint256 indexed itemId,
        uint256 quantity,
        uint256 totalPaid,
        address paymentToken
    );

    constructor(address initialOwner) Ownable(initialOwner) {}

    // =====================================================
    // Owner: Add Item
    // =====================================================
    function addItem(
        string calldata name,
        ItemType itemType,
        address paymentToken,
        uint256 price,
        uint88 quantity,
        address nftContract,
        uint256 nftTokenId
    ) external onlyOwner returns (uint256) {
        if (price == 0) revert PriceZero();

        uint256 itemId = nextItemId;
        
        // Gas: Unchecked increment is safe here
        unchecked {
            nextItemId++;
        }

        // Gas: ID is implicit in the mapping key, no need to store it inside struct
        items[itemId] = Item({
            price: price,
            nftTokenId: nftTokenId,
            paymentToken: paymentToken,
            quantity: quantity,
            itemType: itemType,
            nftContract: nftContract,
            active: true,
            name: name
        });

        emit ItemAdded(itemId, name, itemType);
        return itemId;
    }

    function addBatchItems(
        string[] calldata names,
        uint256[] calldata prices,
        uint88[] calldata quantities
    ) external onlyOwner {
        require(names.length == prices.length, "Array length mismatch");
        require(prices.length == quantities.length, "Array length mismatch");

        for (uint256 i = 0; i < names.length; i++) {
            // Logic identical to addItemNative, but inside a loop
            if (prices[i] == 0) revert PriceZero();

            uint256 itemId = nextItemId;
            unchecked { nextItemId++; }

            items[itemId] = Item({
                price: prices[i],
                nftTokenId: 0,
                paymentToken: address(0), // Native Token
                quantity: quantities[i],
                itemType: ItemType.OffChain, // 0
                nftContract: address(0),
                active: true,
                name: names[i]
            });

            emit ItemAdded(itemId, names[i], ItemType.OffChain);
        }
    }

    // =====================================================
    // Owner: Update Item
    // =====================================================
    function updateItem(
        uint256 itemId,
        string calldata name,
        address paymentToken,
        uint256 price,
        uint88 quantity,
        address nftContract,
        uint256 nftTokenId,
        bool active
    ) external onlyOwner {
        if (items[itemId].price == 0) revert ItemDoesNotExist();

        Item storage it = items[itemId];
        it.name = name;
        it.paymentToken = paymentToken;
        it.price = price;
        it.quantity = quantity;
        it.nftContract = nftContract;
        it.nftTokenId = nftTokenId;
        it.active = active;

        emit ItemUpdated(itemId);
    }

    // =====================================================
    // Owner: Deactivate Item
    // =====================================================
    function deactivateItem(uint256 itemId) external onlyOwner {
        if (items[itemId].price == 0) revert ItemDoesNotExist();
        items[itemId].active = false;
        emit ItemDeactivated(itemId);
    }

    // =====================================================
    // BUY FUNCTION
    // =====================================================
    function buy(uint256 itemId, uint88 quantity)
        external
        payable
        nonReentrant
    {
        if (quantity < 1) revert InvalidQuantity();

        // Gas: Load storage struct reference once
        Item storage it = items[itemId];
        
        // Gas: Load frequently accessed fields to stack (Memory)
        bool isActive = it.active;
        uint256 price = it.price;
        address paymentToken = it.paymentToken;
        ItemType itemType = it.itemType;

        if (price == 0) revert ItemDoesNotExist(); // Check existence
        if (!isActive) revert ItemNotActive();

        // ===============================
        // 1. Validation & Stock Checks
        // ===============================
        if (itemType == ItemType.OffChain || itemType == ItemType.ERC20Redeemable) {
             if (it.quantity < 1) revert InsufficientStock();
             // Effects: Deduct stock BEFORE external calls (CEI Pattern)
           
        } else {
            // For NFTs, strictly require 1
            if (quantity != 1) revert QtyOneRequiredForNFT();
        }

        uint256 totalPrice = price * quantity;

        // ===============================
        // 2. Payment Interaction
        // ===============================
        if (paymentToken == address(0)) {
            if (msg.value != totalPrice) revert WrongNativeAmount();
        } else {
            // Security: Use SafeERC20 for tokens like USDT that don't return bool
            IERC20(paymentToken).safeTransferFrom(msg.sender, address(this), totalPrice);
        }

        // ===============================
        // 3. Asset Delivery Interaction
        // ===============================
        // Note: Stock for physical items was already deducted above
        
        if (itemType == ItemType.NFT_Transfer) {
            IERC721(it.nftContract).safeTransferFrom(address(this), msg.sender, it.nftTokenId);
        } else if (itemType == ItemType.NFT_Mintable) {
            INFTMinter(it.nftContract).mintTo(msg.sender, it.nftTokenId);
        }

        emit Purchased(msg.sender, itemId, quantity, totalPrice, paymentToken);
    }

    // =====================================================
    // Owner Withdraw Funds
    // =====================================================
    function withdrawNative(address payable to, uint256 amount) external onlyOwner {
        // Security: Use call instead of transfer to support Multisig/Smart Contract Wallets
        (bool success, ) = to.call{value: amount}("");
        if (!success) revert WithdrawFailed();
    }

    function withdrawERC20(address token, address to, uint256 amount) external onlyOwner {
        IERC20(token).safeTransfer(to, amount);
    }

    receive() external payable {}
}