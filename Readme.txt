1 : Primitive Types in Solidity
- Boolean (bool)
- Integer (int and uint)
- Address (address and address payable)
- Bytes (Fixed-size: bytes1 to bytes32)
- String (string)
- Enum (enum)
- Fixed-Point Numbers (fixed and ufixed)
2: "memory", "calldata","storage"
- Keyword like  "memory", "calldata","storage"specify where data is stored or managed in a smart contract.
- These keywords are required for complex data types (arrays, structs, mappings, and strings/bytes) because Solidity needs to know how to handle their storage and access to optimize gas usage and ensure correct behavior.
- Primitive types (e.g., int256, uint256, address) do not require data location keywords, as they are typically stored in the stack or directly in storage.
- String is consider as char[] so it is an array 