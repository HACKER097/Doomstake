// SPDX-License-Identifier: MIT
// solidity contract for Doomstake
// App idea:
// People stake ETH to use the app
// If the app catches them using other apps more than a certain threshold, they lose their stake
// If they use the app more than the threshold, they get their stake back plus a reward
// rewards are funded by slashed stakes

pragma solidity ^0.8.0;

contract Doomstake {

  // Creator address
  address public creator = address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);

  struct Stake {
    uint256 amount;
    uint256 timestamp;
    bool active;
  }

  // Address array to keep track of stakers
  address[] public stakers;

  mapping(address => Stake) public stakes;
  mapping(address => bool) public isInStakersArray;
  uint256 public totalStaked;
  uint256 public feeCollected;
  uint256 public currentReward;

  uint8 public constant FEE_PERCENTAGE = 1; // 1% fee on stake slash

  function stake(uint256 _stakeTime) external payable {
    require(msg.value > 0, "Must stake a positive amount");
    require(!stakes[msg.sender].active, "Already have an active stake");

    stakes[msg.sender] = Stake({
      amount: msg.value,
      timestamp: block.timestamp + _stakeTime,
      active: true
    });

    totalStaked += msg.value;

    if (!isInStakersArray[msg.sender]) {
        stakers.push(msg.sender);
        isInStakersArray[msg.sender] = true;
    }
  }


  function slash(address user) external {
    // only creator can slash
    require(msg.sender == creator, "Only creator can slash");
    require(totalStaked > 0, "No stakes to slash");
    require(block.timestamp < stakes[user].timestamp, "Stake time already reached");
    require(stakes[user].active, "No active stake to slash");

    uint256 fee = (stakes[user].amount * FEE_PERCENTAGE) / 100;
    uint256 amountToSlash = stakes[user].amount - fee;
    feeCollected += fee;
    totalStaked -= fee + amountToSlash;
    currentReward += amountToSlash;
    delete stakes[user];
  }

function cleanup() external {
    // FIX 1: Add a check to prevent division by zero.
    // If there is no total stake or no rewards, there's nothing to distribute.
    if (totalStaked > 0 && currentReward > 0) {
        for (uint256 i = 0; i < stakers.length; i++) {
            if (stakes[stakers[i]].active && stakes[stakers[i]].amount != 0) {
                uint256 reward = (currentReward * stakes[stakers[i]].amount) / totalStaked;
                stakes[stakers[i]].amount += reward;
            }
        }
    }
    totalStaked += currentReward;
    currentReward = 0; // Reset rewards after distribution

    // FIX 2: Iterate backwards to safely remove elements without underflow.
    for (uint256 i = stakers.length; i > 0; i--) {
        // We use i-1 because the loop condition is i > 0
        address stakerAddress = stakers[i - 1];
        
        if (stakes[stakerAddress].timestamp < block.timestamp) {
            stakes[stakerAddress].active = false;
            isInStakersArray[stakerAddress] = false;
            
            // Remove the element at i-1 by swapping with the last element
            stakers[i - 1] = stakers[stakers.length - 1];
            stakers.pop();
        }
    }
}

  function withdraw() external {
    require(!stakes[msg.sender].active, "Stake is still active");
    require(block.timestamp >= stakes[msg.sender].timestamp, "Stake time not yet reached");
    require(stakes[msg.sender].amount > 0, "No stake to withdraw");

    uint256 amount = stakes[msg.sender].amount;
    totalStaked -= amount;

    delete stakes[msg.sender];

    payable(msg.sender).transfer(amount);
  }

  function withdrawFees() external {
    // only creator can withdraw fees
    require(msg.sender == creator, "Only creator can withdraw fees");
    uint256 amount = feeCollected;
    feeCollected = 0;
    payable(msg.sender).transfer(amount);
  }

}
