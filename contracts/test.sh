#!/bin/bash

# Doomstake Contract Test Script
# Tests the Doomstake contract functionality using cast

set -e  # Exit on any error

# Contract details
CONTRACT_ADDRESS="0x3F471b9Fe520c5B8dFe1D92d5f00A846429C797b"
RPC_URL="https://testnet.evm.nodes.onflow.org"  

# Account addresses and private keys
CREATOR_ADDRESS="0xd62596571E08A029279A78ac42F9135962ffa436"
CREATOR_PRIVATE_KEY="71029672d47fd6c1584b284dd9dd5188f28a487cbb941ec6645b274c15e30fa3"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

# Create and fund user accounts
print_header "Creating and Funding User Accounts"

# User 1
USER1_DATA=$(cast wallet new)
USER1_ADDRESS=$(echo "$USER1_DATA" | grep "Address" | awk '{print $2}')
USER1_PRIVATE_KEY=$(echo "$USER1_DATA" | grep "Private key" | awk '{print $3}')
print_info "User 1 Address: $USER1_ADDRESS"
cast send --private-key $CREATOR_PRIVATE_KEY --rpc-url $RPC_URL $USER1_ADDRESS --value 10ether
print_success "Funded User 1 with 10 ETH"

# User 2
USER2_DATA=$(cast wallet new)
USER2_ADDRESS=$(echo "$USER2_DATA" | grep "Address" | awk '{print $2}')
USER2_PRIVATE_KEY=$(echo "$USER2_DATA" | grep "Private key" | awk '{print $3}')
print_info "User 2 Address: $USER2_ADDRESS"
cast send --private-key $CREATOR_PRIVATE_KEY --rpc-url $RPC_URL $USER2_ADDRESS --value 10ether
print_success "Funded User 2 with 10 ETH"

# User 3
USER3_DATA=$(cast wallet new)
USER3_ADDRESS=$(echo "$USER3_DATA" | grep "Address" | awk '{print $2}')
USER3_PRIVATE_KEY=$(echo "$USER3_DATA" | grep "Private key" | awk '{print $3}')
print_info "User 3 Address: $USER3_ADDRESS"
cast send --private-key $CREATOR_PRIVATE_KEY --rpc-url $RPC_URL $USER3_ADDRESS --value 10ether
print_success "Funded User 3 with 10 ETH"


# Function to get contract state
get_contract_state() {
    local user_addr=$1
    echo "Contract State:"
    echo "  Total Staked: $(cast call $CONTRACT_ADDRESS "totalStaked()" --rpc-url $RPC_URL | cast --to-dec) wei"
    echo "  Fee Collected: $(cast call $CONTRACT_ADDRESS "feeCollected()" --rpc-url $RPC_URL | cast --to-dec) wei"
    echo "  Current Reward: $(cast call $CONTRACT_ADDRESS "currentReward()" --rpc-url $RPC_URL | cast --to-dec) wei"
    
    if [ ! -z "$user_addr" ]; then
        local stake_data=$(cast call $CONTRACT_ADDRESS "stakes(address)" $user_addr --rpc-url $RPC_URL)
        echo "  User $user_addr stake:"
        echo "    Amount: $(echo $stake_data | cut -d' ' -f1 | cast --to-dec) wei"
        echo "    Timestamp: $(echo $stake_data | cut -d' ' -f2 | cast --to-dec)"
        echo "    Active: $(echo $stake_data | cut -d' ' -f3)"
    fi
}

# Function to get user ETH balance
get_eth_balance() {
    local addr=$1
    cast balance $addr --rpc-url $RPC_URL
}

print_header "DOOMSTAKE CONTRACT TESTING"

# Test 1: Initial contract state
print_header "Test 1: Initial Contract State"
echo "Creator: $(cast call $CONTRACT_ADDRESS "creator()" --rpc-url $RPC_URL)"
echo "Fee Percentage: $(cast call $CONTRACT_ADDRESS "FEE_PERCENTAGE()" --rpc-url $RPC_URL | cast --to-dec)%"
get_contract_state
print_success "Initial state retrieved"

# Test 2: User1 stakes 1 ETH for 1 hour (3600 seconds)
print_header "Test 2: User1 Stakes 1 ETH"
print_info "User1 balance before staking: $(get_eth_balance $USER1_ADDRESS)"

STAKE_TIME=120
STAKE_AMOUNT="1000000000000000000"  # 1 ETH in wei

cast send $CONTRACT_ADDRESS "stake(uint256)" $STAKE_TIME \
    --value $STAKE_AMOUNT \
    --private-key $USER1_PRIVATE_KEY \
    --rpc-url $RPC_URL

print_success "User1 staked 1 ETH"
print_info "User1 balance after staking: $(get_eth_balance $USER1_ADDRESS)"
get_contract_state $USER1_ADDRESS

# Test 3: User2 stakes 2 ETH for 1 hour
print_header "Test 3: User2 Stakes 2 ETH"
print_info "User2 balance before staking: $(get_eth_balance $USER2_ADDRESS)"

STAKE_AMOUNT_2="2000000000000000000"  # 2 ETH in wei

cast send $CONTRACT_ADDRESS "stake(uint256)" $STAKE_TIME \
    --value $STAKE_AMOUNT_2 \
    --private-key $USER2_PRIVATE_KEY \
    --rpc-url $RPC_URL

print_success "User2 staked 2 ETH"
print_info "User2 balance after staking: $(get_eth_balance $USER2_ADDRESS)"
get_contract_state $USER2_ADDRESS

# Test 4: User3 stakes 0.5 ETH for 1 hour  
print_header "Test 4: User3 Stakes 0.5 ETH"
print_info "User3 balance before staking: $(get_eth_balance $USER3_ADDRESS)"

STAKE_AMOUNT_3="500000000000000000"  # 0.5 ETH in wei

cast send $CONTRACT_ADDRESS "stake(uint256)" $STAKE_TIME \
    --value $STAKE_AMOUNT_3 \
    --private-key $USER3_PRIVATE_KEY \
    --rpc-url $RPC_URL

print_success "User3 staked 0.5 ETH"
print_info "User3 balance after staking: $(get_eth_balance $USER3_ADDRESS)"
get_contract_state $USER3_ADDRESS

# Test 5: Try to stake again (should fail)
print_header "Test 5: Try Double Staking (Should Fail)"
set +e  # Don't exit on error for this test
cast send $CONTRACT_ADDRESS "stake(uint256)" $STAKE_TIME \
    --value $STAKE_AMOUNT \
    --private-key $USER1_PRIVATE_KEY \
    --rpc-url $RPC_URL 2>/dev/null

if [ $? -eq 0 ]; then
    print_error "Double staking should have failed but didn\'t"
else
    print_success "Double staking correctly failed"
fi
set -e

# Test 6: Creator slashes User1 (caught using other apps)
print_header "Test 6: Creator Slashes User1"
print_info "Slashing User1 for using other apps..."

cast send $CONTRACT_ADDRESS "slash(address)" $USER1_ADDRESS \
    --private-key $CREATOR_PRIVATE_KEY \
    --rpc-url $RPC_URL

print_success "User1 has been slashed"
get_contract_state

# Test 7: Try non-creator slash (should fail)
print_header "Test 7: Non-Creator Slash Attempt (Should Fail)"
set +e
cast send $CONTRACT_ADDRESS "slash(address)" $USER2_ADDRESS \
    --private-key $USER1_PRIVATE_KEY \
    --rpc-url $RPC_URL 2>/dev/null

if [ $? -eq 0 ]; then
    print_error "Non-creator slash should have failed but didn\'t"
else
    print_success "Non-creator slash correctly failed"
fi
set -e

# Test 8: Run cleanup to distribute rewards
print_header "Test 8: Cleanup and Reward Distribution"
print_info "Running cleanup to distribute rewards to remaining stakers..."

cast send $CONTRACT_ADDRESS "cleanup()" \
    --private-key $CREATOR_PRIVATE_KEY \
    --rpc-url $RPC_URL

print_success "Cleanup completed"
get_contract_state $USER2_ADDRESS
get_contract_state $USER3_ADDRESS

# Test 9: Wait for stake time to pass (simulate time passage)
print_header "Test 9: Simulating Time Passage"
print_info "In a real scenario, we would wait for the stake time to pass..."
print_info "For testing purposes, just wait a bit and press enter"

read -p "Press enter to continue..."

# Test 10: Run cleanup again to deactivate expired stakes
print_header "Test 10: Final Cleanup"
cast send $CONTRACT_ADDRESS "cleanup()" \
    --private-key $CREATOR_PRIVATE_KEY \
    --rpc-url $RPC_URL

print_success "Final cleanup completed"
get_contract_state

# Test 11: User2 withdraws stake + rewards
print_header "Test 11: User2 Withdraws Stake + Rewards"
print_info "User2 balance before withdrawal: $(get_eth_balance $USER2_ADDRESS)"

cast send $CONTRACT_ADDRESS "withdraw()" \
    --private-key $USER2_PRIVATE_KEY \
    --rpc-url $RPC_URL

print_success "User2 withdrew stake + rewards"
print_info "User2 balance after withdrawal: $(get_eth_balance $USER2_ADDRESS)"
get_contract_state

# Test 12: User3 withdraws stake + rewards
print_header "Test 12: User3 Withdraws Stake + Rewards"
print_info "User3 balance before withdrawal: $(get_eth_balance $USER3_ADDRESS)"

cast send $CONTRACT_ADDRESS "withdraw()" \
    --private-key $USER3_PRIVATE_KEY \
    --rpc-url $RPC_URL

print_success "User3 withdrew stake + rewards"
print_info "User3 balance after withdrawal: $(get_eth_balance $USER3_ADDRESS)"
get_contract_state

# Test 13: Creator withdraws fees
print_header "Test 13: Creator Withdraws Fees"
print_info "Creator balance before fee withdrawal: $(get_eth_balance $CREATOR_ADDRESS)"

cast send $CONTRACT_ADDRESS "withdrawFees()" \
    --private-key $CREATOR_PRIVATE_KEY \
    --rpc-url $RPC_URL

print_success "Creator withdrew fees"
print_info "Creator balance after fee withdrawal: $(get_eth_balance $CREATOR_ADDRESS)"
get_contract_state

# Test 14: Try to withdraw non-existent stake (should fail)
print_header "Test 14: Try Invalid Withdrawal (Should Fail)"
set +e
cast send $CONTRACT_ADDRESS "withdraw()" \
    --private-key $USER1_PRIVATE_KEY \
    --rpc-url $RPC_URL 2>/dev/null

if [ $? -eq 0 ]; then
    print_error "Invalid withdrawal should have failed but didn\'t"
else
    print_success "Invalid withdrawal correctly failed"
fi
set -e

# Test 15: Final state check
print_header "Test 15: Final Contract State"
get_contract_state
print_success "All tests completed!"

print_header "TESTING SUMMARY"
echo -e "${GREEN}✓ Contract deployment verified${NC}"
echo -e "${GREEN}✓ Staking functionality tested${NC}"
echo -e "${GREEN}✓ Slashing mechanism tested${NC}"
echo -e "${GREEN}✓ Reward distribution tested${NC}"
echo -e "${GREEN}✓ Withdrawal functionality tested${NC}"
echo -e "${GREEN}✓ Fee collection tested${NC}"
echo -e "${GREEN}✓ Error handling tested${NC}"
echo -e "${GREEN}✓ Access control tested${NC}"

print_header "Test Complete!"
