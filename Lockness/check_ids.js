(async () => {
    try {
        console.log("🔍 Scanning Contract for Item IDs...");

        // ==========================================
        // 1. CONFIGURATION
        // ==========================================
        const CONTRACT_ADDRESS = "0xa988f750e459f6c62efaecc5339ece4b6062bf73"; // <--- PASTE ADDRESS

        // ==========================================
        // 2. SETUP
        // ==========================================
        const signer = (new ethers.providers.Web3Provider(web3.currentProvider)).getSigner();
        
        // We need to read 'nextItemId' and the 'items' mapping
        const ABI = [
            "function nextItemId() view returns (uint256)",
            "function items(uint256) view returns (uint256 price, uint256 nftTokenId, address paymentToken, uint88 quantity, uint8 itemType, address nftContract, bool active, string name)"
        ];

        const contract = new ethers.Contract(CONTRACT_ADDRESS, ABI, signer);

        // ==========================================
        // 3. FETCH & PRINT
        // ==========================================
        // Get the total number of items
        const nextIdBig = await contract.nextItemId();
        const count = nextIdBig.toNumber(); // valid IDs are 1 to count-1

        console.log(`\nFound ${count - 1} items. Here is your list:\n`);
        console.log("ID  |  NAME");
        console.log("----|------------------------");

        for (let i = 1; i < count; i++) {
            const item = await contract.items(i);
            
            // Log in a readable format
            // Pad the ID with spaces to align columns
            const idString = i.toString().padEnd(3, ' '); 
            console.log(`${idString} |  ${item.name}`);
        }

        console.log("\n✅ Done.");

    } catch (e) {
        console.error("Script Error:", e.message);
    }
})();