(async () => {
    try {
        console.log("🛒 Starting Purchase Test...");

        // ==========================================
        // 1. CONFIGURATION
        // ==========================================
        const CONTRACT_ADDRESS = "0xdbb716eb769df16c224ab094e509b8f980a317ab"; // <--- PASTE ADDRESS
        const ITEM_ID = 1;  // The ID of the item you want to test buying
        const QUANTITY = 1; // How many to buy

        // ==========================================
        // 2. SETUP
        // ==========================================
        const provider = new ethers.providers.Web3Provider(web3.currentProvider);
        const signer = provider.getSigner();
        
        // Minimal ABI needed for buying
        const ABI = [
            "function items(uint256) view returns (uint256 price, uint256 nftTokenId, address paymentToken, uint88 quantity, uint8 itemType, address nftContract, bool active, string name)",
            "function buy(uint256 itemId, uint88 quantity) external payable"
        ];

        const contract = new ethers.Contract(CONTRACT_ADDRESS, ABI, signer);

        // ==========================================
        // 3. FETCH PRICE & VALIDATE
        // ==========================================
        console.log(`🔍 Fetching details for Item ID: ${ITEM_ID}...`);
        
        const item = await contract.items(ITEM_ID);

        // Check if item exists/active
        if (!item.active) {
            console.error("❌ Error: This item is NOT active or does not exist.");
            return;
        }

        // Calculate Total Cost (Price * Quantity)
        // We use BigNumber math because prices are in Wei (huge numbers)
        const pricePerItem = item.price;
        const totalCost = pricePerItem.mul(QUANTITY);

        console.log(`   Name:      ${item.name}`);
        console.log(`   Price:     ${ethers.utils.formatEther(pricePerItem)} ETH (Native Token)`);
        console.log(`   Quantity:  ${QUANTITY}`);
        console.log(`   --------------------------------`);
        console.log(`   Total Pay: ${ethers.utils.formatEther(totalCost)} ETH`);

        // ==========================================
        // 4. SEND TRANSACTION
        // ==========================================
        console.log("\n💸 Sending Transaction... Please confirm in MetaMask.");

        // We pass the totalCost as the 'value' (this is msg.value in Solidity)
        const tx = await contract.buy(ITEM_ID, QUANTITY, { 
            value: totalCost,
            gasLimit: 300000 // Manual gas limit just in case
        });

        console.log(`Transaction Sent! Hash: ${tx.hash}`);
        console.log("Waiting for confirmation...");
        
        await tx.wait();
        
        console.log("✅ Purchase Successful! The transaction didn't revert.");

    } catch (e) {
        console.error("\n❌ PURCHASE FAILED:");
        if (e.message.includes("Insufficient funds")) {
            console.error("Reason: You do not have enough testnet tokens.");
        } else if (e.data && e.data.message) {
            console.error("Reason:", e.data.message);
        } else {
            console.error("Reason:", e.message);
        }
    }
})();