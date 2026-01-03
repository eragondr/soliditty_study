(async () => {
    try {
        console.log("Starting BATCH Import (1 Transaction)...");

        // ==========================================
        // 1. CONFIGURATION
        // ==========================================
        const CONTRACT_ADDRESS = "0xa988f750e459f6c62efaecc5339ece4b6062bf73"; // <--- PASTE NEW ADDRESS

        // const items = [
        //             { name: "gc_ticket_spin_1", price: "0.99", quantity: 1 },
        //             { name: "gc_ticket_spin_3", price: "1.99", quantity: 1 },
        //             { name: "gc_ticket_spin_5", price: "3.99", quantity: 1 },
        //             { name: "gc_ticket_spin_10", price: "5.99", quantity: 1 },
        //             { name: "gc_sub_spin_1", price: "4.99", quantity: 1 },
        //             { name: "gc_sub_spin_3", price: "12.99", quantity: 1 },
        //             { name: "gc_sub_spin_6", price: "35.99", quantity: 1 },
        //             { name: "gc_sub_spin_12", price: "39.99", quantity: 1 },
        //             { name: "gc_ticket_cone_1", price: "0.99", quantity: 1 },
        //             { name: "gc_ticket_cone_3", price: "1.99", quantity: 1 },
        //             { name: "gc_ticket_cone_5", price: "3.99", quantity: 1 },
        //             { name: "gc_ticket_cone_10", price: "5.99", quantity: 1 },
        //             { name: "gc_sub_cone_1", price: "4.99", quantity: 1 },
        //             { name: "gc_sub_cone_3", price: "12.99", quantity: 1 },
        //             { name: "gc_sub_cone_6", price: "35.99", quantity: 1 },
        //             { name: "gc_sub_cone_12", price: "39.99", quantity: 1 },
        //             { name: "gc_ticket_lottery_1", price: "0.99", quantity: 1 },
        //             { name: "gc_ticket_lottery_3", price: "1.99", quantity: 1 },
        //             { name: "gc_ticket_lottery_5", price: "3.99", quantity: 1 },
        //             { name: "gc_ticket_lottery_10", price: "5.99", quantity: 1 },
        //             { name: "gc_sub_lottery_1", price: "4.99", quantity: 1 },
        //             { name: "gc_sub_lottery_3", price: "12.99", quantity: 1 },
        //             { name: "gc_sub_lottery_6", price: "35.99", quantity: 1 },
        //             { name: "gc_sub_lottery_12", price: "39.99", quantity: 1 },
        //             { name: "gc_ticket_slot_three_1", price: "0.99", quantity: 1 },
        //             { name: "gc_ticket_slot_three_3", price: "1.99", quantity: 1 },
        //             { name: "gc_ticket_slot_three_5", price: "3.99", quantity: 1 },
        //             { name: "gc_ticket_slot_three_10", price: "5.99", quantity: 1 },
        //             { name: "gc_sub_slot_three_1", price: "4.99", quantity: 1 },
        //             { name: "gc_sub_slot_three_3", price: "12.99", quantity: 1 },
        //             { name: "gc_sub_slot_three_6", price: "35.99", quantity: 1 },
        //             { name: "gc_sub_slot_three_12", price: "39.99", quantity: 1 },
        //             { name: "gc_ticket_slot_seven_1", price: "0.99", quantity: 1 },
        //             { name: "gc_ticket_slot_seven_3", price: "1.99", quantity: 1 },
        //             { name: "gc_ticket_slot_seven_5", price: "3.99", quantity: 1 },
        //             { name: "gc_ticket_slot_seven_10", price: "5.99", quantity: 1 },
        //             { name: "gc_sub_slot_seven_1", price: "4.99", quantity: 1 },
        //             { name: "gc_sub_slot_seven_3", price: "12.99", quantity: 1 },
        //             { name: "gc_sub_slot_seven_6", price: "35.99", quantity: 1 },
        //             { name: "gc_sub_slot_seven_12", price: "39.99", quantity: 1 },
        //             { name: "avatar_1", price: "0.1", quantity: 1 },
        //             { name: "avatar_2", price: "0.5", quantity: 1 },
        //             { name: "avatar_3", price: "1", quantity: 1 },
        //             { name: "game_dolly_life_1", price: "0.99", quantity: 1 },
        //             { name: "game_dolly_life_3", price: "1.99", quantity: 1 },
        //             { name: "game_dolly_life_5", price: "3.99", quantity: 1 },
        //             { name: "game_dolly_life_10", price: "5.99", quantity: 1 },
        //             { name: "game_gimo_life_1", price: "0.99", quantity: 1 },
        //             { name: "game_gimo_life_3", price: "1.99", quantity: 1 },
        //             { name: "game_gimo_life_5", price: "3.99", quantity: 1 },
        //             { name: "game_gimo_life_10", price: "5.99", quantity: 1 },
        //             { name: "game_jaine_life_1", price: "0.99", quantity: 1 },
        //             { name: "game_jaine_life_3", price: "1.99", quantity: 1 },
        //             { name: "game_jaine_life_5", price: "3.99", quantity: 1 },
        //             { name: "game_jaine_life_10", price: "5.99", quantity: 1 },
        //             { name: "game_kult_life_1", price: "0.99", quantity: 1 },
        //             { name: "game_kult_life_3", price: "1.99", quantity: 1 },
        //             { name: "game_kult_life_5", price: "3.99", quantity: 1 },
        //             { name: "game_kult_life_10", price: "5.99", quantity: 1 },
        //             { name: "game_euclid_life_1", price: "0.99", quantity: 1 },
        //             { name: "game_euclid_life_3", price: "1.99", quantity: 1 },
        //             { name: "game_euclid_life_5", price: "3.99", quantity: 1 },
        //             { name: "game_euclid_life_10", price: "5.99", quantity: 1 },
        //             { name: "game_zia_life_1", price: "0.99", quantity: 1 },
        //             { name: "game_zia_life_3", price: "1.99", quantity: 1 },
        //             { name: "game_zia_life_5", price: "3.99", quantity: 1 },
        //             { name: "game_zia_life_10", price: "5.99", quantity: 1 }
        //         ];
        // DATA (Prices / 100)
        const allItems = [
            { name: "gc_ticket_spin_1", price: "0.0099", quantity: 1 },
            { name: "gc_ticket_spin_3", price: "0.0199", quantity: 1 },
            { name: "gc_ticket_spin_5", price: "0.0399", quantity: 1 },
            { name: "gc_ticket_spin_10", price: "0.0599", quantity: 1 },
            { name: "gc_sub_spin_1", price: "0.0499", quantity: 1 },
            { name: "gc_sub_spin_3", price: "0.1299", quantity: 1 },
            { name: "gc_sub_spin_6", price: "0.3599", quantity: 1 },
            { name: "gc_sub_spin_12", price: "0.3999", quantity: 1 },
            { name: "gc_ticket_cone_1", price: "0.0099", quantity: 1 },
            { name: "gc_ticket_cone_3", price: "0.0199", quantity: 1 },
            { name: "gc_ticket_cone_5", price: "0.0399", quantity: 1 },
            { name: "gc_ticket_cone_10", price: "0.0599", quantity: 1 },
            { name: "gc_sub_cone_1", price: "0.0499", quantity: 1 },
            { name: "gc_sub_cone_3", price: "0.1299", quantity: 1 },
            { name: "gc_sub_cone_6", price: "0.3599", quantity: 1 },
            { name: "gc_sub_cone_12", price: "0.3999", quantity: 1 },
            { name: "gc_ticket_lottery_1", price: "0.0099", quantity: 1 },
            { name: "gc_ticket_lottery_3", price: "0.0199", quantity: 1 },
            { name: "gc_ticket_lottery_5", price: "0.0399", quantity: 1 },
            { name: "gc_ticket_lottery_10", price: "0.0599", quantity: 1 },
            { name: "gc_sub_lottery_1", price: "0.0499", quantity: 1 },
            { name: "gc_sub_lottery_3", price: "0.1299", quantity: 1 },
            { name: "gc_sub_lottery_6", price: "0.3599", quantity: 1 },
            { name: "gc_sub_lottery_12", price: "0.3999", quantity: 1 },
            { name: "gc_ticket_slot_three_1", price: "0.0099", quantity: 1 },
            { name: "gc_ticket_slot_three_3", price: "0.0199", quantity: 1 },
            { name: "gc_ticket_slot_three_5", price: "0.0399", quantity: 1 },
            { name: "gc_ticket_slot_three_10", price: "0.0599", quantity: 1 },
            { name: "gc_sub_slot_three_1", price: "0.0499", quantity: 1 },
            { name: "gc_sub_slot_three_3", price: "0.1299", quantity: 1 },
            { name: "gc_sub_slot_three_6", price: "0.3599", quantity: 1 },
            { name: "gc_sub_slot_three_12", price: "0.3999", quantity: 1 },
            { name: "gc_ticket_slot_seven_1", price: "0.0099", quantity: 1 },
            { name: "gc_ticket_slot_seven_3", price: "0.0199", quantity: 1 },
            { name: "gc_ticket_slot_seven_5", price: "0.0399", quantity: 1 },
            { name: "gc_ticket_slot_seven_10", price: "0.0599", quantity: 1 },
            { name: "gc_sub_slot_seven_1", price: "0.0499", quantity: 1 },
            { name: "gc_sub_slot_seven_3", price: "0.1299", quantity: 1 },
            { name: "gc_sub_slot_seven_6", price: "0.3599", quantity: 1 },
            { name: "gc_sub_slot_seven_12", price: "0.3999", quantity: 1 },
            { name: "avatar_1", price: "0.001", quantity: 1 },
            { name: "avatar_2", price: "0.005", quantity: 1 },
            { name: "avatar_3", price: "0.01", quantity: 1 },
            { name: "game_dolly_life_1", price: "0.0099", quantity: 1 },
            { name: "game_dolly_life_3", price: "0.0199", quantity: 1 },
            { name: "game_dolly_life_5", price: "0.0399", quantity: 1 },
            { name: "game_dolly_life_10", price: "0.0599", quantity: 1 },
            { name: "game_gimo_life_1", price: "0.0099", quantity: 1 },
            { name: "game_gimo_life_3", price: "0.0199", quantity: 1 },
            { name: "game_gimo_life_5", price: "0.0399", quantity: 1 },
            { name: "game_gimo_life_10", price: "0.0599", quantity: 1 },
            { name: "game_jaine_life_1", price: "0.0099", quantity: 1 },
            { name: "game_jaine_life_3", price: "0.0199", quantity: 1 },
            { name: "game_jaine_life_5", price: "0.0399", quantity: 1 },
            { name: "game_jaine_life_10", price: "0.0599", quantity: 1 },
            { name: "game_kult_life_1", price: "0.0099", quantity: 1 },
            { name: "game_kult_life_3", price: "0.0199", quantity: 1 },
            { name: "game_kult_life_5", price: "0.0399", quantity: 1 },
            { name: "game_kult_life_10", price: "0.0599", quantity: 1 },
            { name: "game_euclid_life_1", price: "0.0099", quantity: 1 },
            { name: "game_euclid_life_3", price: "0.0199", quantity: 1 },
            { name: "game_euclid_life_5", price: "0.0399", quantity: 1 },
            { name: "game_euclid_life_10", price: "0.0599", quantity: 1 },
            { name: "game_zia_life_1", price: "0.0099", quantity: 1 },
            { name: "game_zia_life_3", price: "0.0199", quantity: 1 },
            { name: "game_zia_life_5", price: "0.0399", quantity: 1 },
            { name: "game_zia_life_10", price: "0.0599", quantity: 1 }
        ];
        const signer = (new ethers.providers.Web3Provider(web3.currentProvider)).getSigner();
        const ABI = ["function addBatchItems(string[] names, uint256[] prices, uint88[] quantities) external"];
        const contract = new ethers.Contract(CONTRACT_ADDRESS, ABI, signer);

        // Helper to chunk array
        function chunkArray(myArray, chunk_size){
            var results = [];
            while (myArray.length) {
                results.push(myArray.splice(0, chunk_size));
            }
            return results;
        }

        // ==========================================
        // 4. EXECUTION (Split into chunks of 35)
        // ==========================================
        // We make a copy so we don't destroy original list structure if we need to debug
        const itemsCopy = [...allItems]; 
        const batches = chunkArray(itemsCopy, 35); 

        console.log(`Split ${allItems.length} items into ${batches.length} batches.`);

        for (let i = 0; i < batches.length; i++) {
            const currentBatch = batches[i];
            console.log(`\nProcessing Batch ${i + 1}/${batches.length} (${currentBatch.length} items)...`);

            const nameArray = [];
            const priceArray = [];
            const quantityArray = [];

            for(const item of currentBatch) {
                nameArray.push(item.name);
                priceArray.push(ethers.utils.parseEther(item.price.toString()));
                quantityArray.push(item.quantity);
            }

            // Using 8M gas limit per smaller batch is very safe
            const overrides = { gasLimit: 8000000 }; 

            try {
                const tx = await contract.addBatchItems(
                    nameArray, 
                    priceArray, 
                    quantityArray,
                    overrides
                );
                console.log(`   --> Tx Sent: ${tx.hash}`);
                console.log("   Waiting for confirmation...");
                await tx.wait();
                console.log(`   ✅ Batch ${i + 1} Complete!`);
            } catch (err) {
                console.error(`   ❌ Failed Batch ${i + 1}:`, err.message);
                break; // Stop if a batch fails
            }
        }

        console.log("\nAll operations finished.");

    } catch (e) {
        console.error("Script Error:", e.message);
    }
})();