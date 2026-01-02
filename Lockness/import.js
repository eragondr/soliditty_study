(async () => {
    try {
        console.log("Starting Smart Import (Check & Update)...");

        // ==========================================
        // 1. CONFIGURATION
        // ==========================================
        const CONTRACT_ADDRESS = "YOUR_CONTRACT_ADDRESS_HERE"; // <--- PASTE ADDRESS

        // COPY CSV CONTENT HERE
        const CSV_CONTENT = `ID,ItemType,Price,quantity
gc_ticket_spin_1,OffChain,0.99 0G,1
gc_ticket_spin_3,OffChain,1.99 0G,1
gc_ticket_spin_5,OffChain,3.99 0G,1
gc_ticket_spin_10,OffChain,5.99 0G,1
gc_sub_spin_1,OffChain,4.99 0G,1
gc_sub_spin_3,OffChain,12.99 0G,1
gc_sub_spin_6,OffChain,35.99 0G,1
gc_sub_spin_12,OffChain,39.99 0G,1
gc_ticket_cone_1,OffChain,0.99 0G,1
gc_ticket_cone_3,OffChain,1.99 0G,1
gc_ticket_cone_5,OffChain,3.99 0G,1
gc_ticket_cone_10,OffChain,5.99 0G,1
gc_sub_cone_1,OffChain,4.99 0G,1
gc_sub_cone_3,OffChain,12.99 0G,1
gc_sub_cone_6,OffChain,35.99 0G,1
gc_sub_cone_12,OffChain,39.99 0G,1
gc_ticket_lottery_1,OffChain,0.99 0G,1
gc_ticket_lottery_3,OffChain,1.99 0G,1
gc_ticket_lottery_5,OffChain,3.99 0G,1
gc_ticket_lottery_10,OffChain,5.99 0G,1
gc_sub_lottery_1,OffChain,4.99 0G,1
gc_sub_lottery_3,OffChain,12.99 0G,1
gc_sub_lottery_6,OffChain,35.99 0G,1
gc_sub_lottery_12,OffChain,39.99 0G,1
gc_ticket_slot_three_1,OffChain,0.99 0G,1
gc_ticket_slot_three_3,OffChain,1.99 0G,1
gc_ticket_slot_three_5,OffChain,3.99 0G,1
gc_ticket_slot_three_10,OffChain,5.99 0G,1
gc_sub_slot_three_1,OffChain,4.99 0G,1
gc_sub_slot_three_3,OffChain,12.99 0G,1
gc_sub_slot_three_6,OffChain,35.99 0G,1
gc_sub_slot_three_12,OffChain,39.99 0G,1
gc_ticket_slot_seven_1,OffChain,0.99 0G,1
gc_ticket_slot_seven_3,OffChain,1.99 0G,1
gc_ticket_slot_seven_5,OffChain,3.99 0G,1
gc_ticket_slot_seven_10,OffChain,5.99 0G,1
gc_sub_slot_seven_1,OffChain,4.99 0G,1
gc_sub_slot_seven_3,OffChain,12.99 0G,1
gc_sub_slot_seven_6,OffChain,35.99 0G,1
gc_sub_slot_seven_12,OffChain,39.99 0G,1
avatar_1,OffChain,0.1 0G,1
avatar_2,OffChain,0.5 0G,1
avatar_3,OffChain,1 0G,1
game_dolly_life_1,OffChain,0.99 0G,1
game_dolly_life_3,OffChain,1.99 0G,1
game_dolly_life_5,OffChain,3.99 0G,1
game_dolly_life_10,OffChain,5.99 0G,1
game_gimo_life_1,OffChain,0.99 0G,1
game_gimo_life_3,OffChain,1.99 0G,1
game_gimo_life_5,OffChain,3.99 0G,1
game_gimo_life_10,OffChain,5.99 0G,1
game_jaine_life_1,OffChain,0.99 0G,1
game_jaine_life_3,OffChain,1.99 0G,1
game_jaine_life_5,OffChain,3.99 0G,1
game_jaine_life_10,OffChain,5.99 0G,1
game_kult_life_1,OffChain,0.99 0G,1
game_kult_life_3,OffChain,1.99 0G,1
game_kult_life_5,OffChain,3.99 0G,1
game_kult_life_10,OffChain,5.99 0G,1
game_euclid_life_1,OffChain,0.99 0G,1
game_euclid_life_3,OffChain,1.99 0G,1
game_euclid_life_5,OffChain,3.99 0G,1
game_euclid_life_10,OffChain,5.99 0G,1
game_zia_life_1,OffChain,0.99 0G,1
game_zia_life_3,OffChain,1.99 0G,1
game_zia_life_5,OffChain,3.99 0G,1
game_zia_life_10,OffChain,5.99 0G,1`;

        // ==========================================
        // 2. SETUP
        // ==========================================
        const signer = (new ethers.providers.Web3Provider(web3.currentProvider)).getSigner();
        
        // Extended ABI to include reading items and nextItemId
        const ABI = [
            "function addItem(string name, uint8 itemType, address paymentToken, uint256 price, uint256 quantity, address nftContract, uint256 nftTokenId) returns (uint256)",
            "function updateItem(uint256 itemId, string name, address paymentToken, uint256 price, uint256 quantity, address nftContract, uint256 nftTokenId, bool active)",
            "function items(uint256) view returns (uint256 price, uint256 nftTokenId, address paymentToken, uint88 quantity, uint8 itemType, address nftContract, bool active, string name)", 
            "function nextItemId() view returns (uint256)"
        ];
        
        // Note: The ABI above assumes ShopOptimized struct order. 
        // If using original shop, 'items' return values are different, 
        // but ethers.js handles named properties automatically so .name will work either way.

        const contract = new ethers.Contract(CONTRACT_ADDRESS, ABI, signer);

        // ==========================================
        // 3. SCAN EXISTING ITEMS
        // ==========================================
        console.log("Scanning existing items on blockchain...");
        const existingItems = {}; // Map: Name -> ID

        try {
            const nextIdBig = await contract.nextItemId();
            const nextId = nextIdBig.toNumber();
            
            console.log(`Found ${nextId - 1} existing items.`);
            
            // Loop through all items to build the map
            for(let i = 1; i < nextId; i++) {
                const item = await contract.items(i);
                // We use item.name if available, checking purely for name matches
                if (item.name) {
                    existingItems[item.name] = i;
                }
            }
        } catch(e) {
            console.log("Could not scan existing items (Is contract empty?). Proceeding to add all.");
        }

        // ==========================================
        // 4. PROCESS CSV
        // ==========================================
        const rows = CSV_CONTENT.trim().split('\n');
        
        for (let i = 1; i < rows.length; i++) {
            const row = rows[i].split(',');
            if(row.length < 3) continue;

            const name = row[0];
            const priceStr = row[2].replace(" 0G", "").trim();
            const quantity = row[3];
            const priceInWei = ethers.utils.parseEther(priceStr);
            
            // Check if exists
            if (existingItems[name]) {
                // UPDATE
                const id = existingItems[name];
                console.log(`🔄 Updating existing item [ID:${id}]: ${name} @ ${priceStr}`);
                
                try {
                    const tx = await contract.updateItem(
                        id,
                        name,
                        "0x0000000000000000000000000000000000000000", // paymentToken
                        priceInWei,
                        quantity,
                        "0x0000000000000000000000000000000000000000", // nftContract
                        0, // nftTokenId
                        true // active
                    );
                    await tx.wait();
                    console.log(`   ✅ Updated!`);
                } catch(e) {
                    console.error(`   ❌ Update failed: ${e.message}`);
                }

            } else {
                // ADD NEW
                console.log(`➕ Adding new item: ${name} @ ${priceStr}`);
                
                try {
                    const tx = await contract.addItem(
                        name,
                        0, // OffChain
                        "0x0000000000000000000000000000000000000000",
                        priceInWei,
                        quantity,
                        "0x0000000000000000000000000000000000000000",
                        0
                    );
                    await tx.wait();
                    console.log(`   ✅ Added!`);
                } catch(e) {
                    console.error(`   ❌ Add failed: ${e.message}`);
                }
            }
        }
        
        console.log("Done.");

    } catch (e) {
        console.error("Script Error:", e.message);
    }
})();