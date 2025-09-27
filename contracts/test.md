# uint8 FEE_PERCENTAGE()
cast call 0x5FbDB2315678afecb367f032d93F642f64180aa3 "FEE_PERCENTAGE()" --rpc-url http://127.0.0.1:8545

# address creator()
cast call 0x5FbDB2315678afecb367f032d93F642f64180aa3 "creator()" --rpc-url http://127.0.0.1:8545

# uint256 currentReward()
cast call 0x5FbDB2315678afecb367f032d93F642f64180aa3 "currentReward()" --rpc-url http://127.0.0.1:8545

# uint256 feeCollected()
cast call 0x5FbDB2315678afecb367f032d93F642f64180aa3 "feeCollected()" --rpc-url http://127.0.0.1:8545

# bool isInStakersArray(address)
cast call 0x5FbDB2315678afecb367f032d93F642f64180aa3 "isInStakersArray(address)" 0x0000000000000000000000000000000000000000 --rpc-url http://127.0.0.1:8545

# address stakers(uint256)
cast call 0x5FbDB2315678afecb367f032d93F642f64180aa3 "stakers(uint256)" 0 --rpc-url http://127.0.0.1:8545

# (uint256 amount, uint256 timestamp, bool active) stakes(address)
cast call 0x5FbDB2315678afecb367f032d93F642f64180aa3 "stakes(address)" 0x0000000000000000000000000000000000000000 --rpc-url http://127.0.0.1:8545

# uint256 totalStaked()
cast call 0x5FbDB2315678afecb367f032d93F642f64180aa3 "totalStaked()" --rpc-url http://127.0.0.1:8545

# cleanup()
cast send 0x5FbDB2315678afecb367f032d93F642f64180aa3 "cleanup()" \
  --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 \
  --rpc-url http://127.0.0.1:8545

# slash(address user)
cast send 0x5FbDB2315678afecb367f032d93F642f64180aa3 "slash(address)" 0x0000000000000000000000000000000000000000 \
  --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 \
  --rpc-url http://127.0.0.1:8545

# stake(uint256 _stakeTime) with some ETH
cast send 0x5FbDB2315678afecb367f032d93F642f64180aa3 "stake(uint256)" 1000 \
  --value 1ether \
  --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 \
  --rpc-url http://127.0.0.1:8545

# withdraw()
cast send 0x5FbDB2315678afecb367f032d93F642f64180aa3 "withdraw()" \
  --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 \
  --rpc-url http://127.0.0.1:8545

# withdrawFees()
cast send 0x5FbDB2315678afecb367f032d93F642f64180aa3 "withdrawFees()" \
  --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 \
  --rpc-url http://127.0.0.1:8545
