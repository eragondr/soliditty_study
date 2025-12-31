// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

// Optional NFT minter interface
interface INFTMinter {
    function mintTo(address to, uint256 tokenId) external;
    // optional version:
    // function mintTo(address to) external returns (uint256);
}

contract Shop is Ownable, ReentrancyGuard {

    // ===============================
    // Constructor (OZ v5 required)
    // ===============================
    constructor(address initialOwner) Ownable(initialOwner) {}

    // ===============================
    // Item Definition
    // ===============================
    enum ItemType { OffChain, ERC20Redeemable, NFT_Transfer, NFT_Mintable }

    struct Item {
        uint256 id;
        string name;
        ItemType itemType;
        address paymentToken;    // address(0) = native coin
        uint256 price;           // price per item
        uint256 quantity;        // for off-chain type
        address nftContract;     // for NFT items
        uint256 nftTokenId;      // for transfer or minting
        bool active;
    }

    mapping(uint256 => Item) public items;
    uint256 public nextItemId = 1;

    // ===============================
    // Events
    // ===============================
    event ItemAdded(uint256 indexed itemId, string name, ItemType itemType);
    event ItemUpdated(uint256 indexed itemId);
    event ItemDeactivated(uint256 indexed itemId);
    event ItemActivated(uint256 indexed itemId);
   
    event Purchased(
        address indexed buyer,
        uint256 indexed itemId,
        uint256 quantity,
        uint256 totalPaid,
        address paymentToken
    );

    // =====================================================
    // Owner: Add Item
    // =====================================================
    function addItem(
        string calldata name,
        ItemType itemType,
        address paymentToken,
        uint256 price,
        uint256 quantity,
        address nftContract,
        uint256 nftTokenId
    ) external onlyOwner returns (uint256) {
        require(price > 0, "price=0");

        uint256 itemId = nextItemId++;

        items[itemId] = Item({
            id: itemId,
            name: name,
            itemType: itemType,
            paymentToken: paymentToken,
            price: price,
            quantity: quantity,
            nftContract: nftContract,
            nftTokenId: nftTokenId,
            active: true
        });

        emit ItemAdded(itemId, name, itemType);
        return itemId;
    }

    // =====================================================
    // Owner: Update Item
    // =====================================================
    function updateItem(
        uint256 itemId,
        string calldata name,
        address paymentToken,
        uint256 price,
        uint256 quantity,
        address nftContract,
        uint256 nftTokenId,
        bool active
    ) external onlyOwner {
        Item storage it = items[itemId];
        require(it.id != 0, "no-item");

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
    // Owner: Deactivate/Activate Item
    // =====================================================
    function deactivateItem(uint256 itemId) external onlyOwner {
        Item storage it = items[itemId];
        require(it.id != 0, "no-item");

        it.active = false;
        emit ItemDeactivated(itemId);
    }
    function activateItem(uint256 itemId) external onlyOwner {
        Item storage it = items[itemId];
        require(it.id != 0, "no-item");
        it.active = true;
        emit ItemActivated(itemId);
    }
    // =====================================================
    // BUY FUNCTION
    // =====================================================
    function buy(uint256 itemId, uint256 quantity)
        external
        payable
        nonReentrant
    {
        require(quantity > 0, "qty=0");

        Item storage it = items[itemId];
        require(it.id != 0 && it.active, "invalid item");

        uint256 totalPrice = it.price * quantity;

        // ===============================
        // Payment Handling
        // ===============================
        if (it.paymentToken == address(0)) {
            // Native coin
            require(msg.value == totalPrice, "wrong amount");
        } else {
            // ERC20
            require(
                IERC20(it.paymentToken).transferFrom(msg.sender, address(this), totalPrice),
                "erc20 transfer failed"
            );
        }

        // =====================================================
        // Effects (CEI pattern)
        // =====================================================
        if (it.itemType == ItemType.OffChain || it.itemType == ItemType.ERC20Redeemable) {
            require(it.quantity >= quantity, "not enough stock");
            it.quantity -= quantity;

        } else if (it.itemType == ItemType.NFT_Transfer) {
            require(quantity == 1, "qty=1 required");
            IERC721(it.nftContract).safeTransferFrom(
                address(this),
                msg.sender,
                it.nftTokenId
            );

        } else if (it.itemType == ItemType.NFT_Mintable) {
            require(quantity == 1, "qty=1 required");
            INFTMinter(it.nftContract).mintTo(msg.sender, it.nftTokenId);
        }

        emit Purchased(
            msg.sender,
            itemId,
            quantity,
            totalPrice,
            it.paymentToken
        );
    }

    // =====================================================
    // Owner Withdraw Funds
    // =====================================================
    function withdrawNative(address payable to, uint256 amount)
        external
        onlyOwner
    {
        require(address(this).balance >= amount, "insufficient");
        to.transfer(amount);
    }

    function withdrawERC20(address token, address to, uint256 amount)
        external
        onlyOwner
    {
        IERC20(token).transfer(to, amount);
    }

    // Accept native coin
    receive() external payable {}
}
