// solidity contract for Doomstake
// App idea:
// People stake ETH to use the app
// If the app catches them using other apps more than a certain threshold, they lose their stake
// If they use the app more than the threshold, they get their stake back plus a reward
// rewards are funded by a small fee on each stake

pragma solidity ^0.8.0;

contract Doomstake {

  struct Stake {
    uint256 amount;
    uint256 timestamp;
    bool active;
  }

  // Address array to keep track of stakers
  address[] public stakers;

  mapping(address => Stake) public stakes;
  uint256 public totalStaked;
  uint256 public totalActive;
  uint256 public feeCollected;

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
    totalActive += 1;
    stakers.push(msg.sender);
  }


  function slash(address user) external {
    // only creator can slash
    require(msg.sender == address(0x123), "Only creator can slash");
    require(totalStaked > 0, "No stakes to slash");
    require(stakes[user].active, "No active stake to slash");
    require(block.timestamp < stakes[user].timestamp, "Stake time already reached");

    uint256 fee = (stakes[user].amount * FEE_PERCENTAGE) / 100;
    uint256 amountToSlash = stakes[user].amount - fee;
    feeCollected += fee;

    totalActive -= 1;

    // Distribute slashed based on stake amount
    for (uint256 i = 0; i < stakers.length; i++) {
      if (stakes[stakers[i]].active) {
        uint256 reward = (amountToSlash * stakes[stakers[i]].amount) / totalStaked;
        stakes[stakers[i]].amount += reward;
      }
      if (stakes[stakers[i]].timestamp < block.timestamp) {
        stakes[stakers[i]].active = false; // deactivate stake if time reached
      }
    }

    delete stakes[user];
  }

  function withdraw() external {
    require(stakes[msg.sender].active, "No active stake to withdraw");
    require(block.timestamp >= stakes[msg.sender].timestamp, "Stake time not yet reached");

    uint256 amount = stakes[msg.sender].amount;
    totalStaked -= amount;
    totalActive -= 1;

    delete stakes[msg.sender];

    payable(msg.sender).transfer(amount);
  }

  function withdrawFees() external {
    // only creator can withdraw fees
    require(msg.sender == address(0x123), "Only creator can withdraw fees");
    uint256 amount = feeCollected;
    feeCollected = 0;
    payable(msg.sender).transfer(amount);
  }

}
