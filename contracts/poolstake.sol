// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

contract poolstake is ReentrancyGuard {
    using Math for uint256;

    // Staking token (e.g., a custom ERC-20 token)
    IERC20 public stakingToken;
    // Reward token (can be same as staking token or different)
    IERC20 public rewardToken;

    // Reward rate (tokens per second)
    uint256 public rewardRate = 0.1 * 1e18; // 0.1 tokens per second
    // Last time rewards were updated
    uint256 public lastUpdateTime;
    // Total tokens staked
    uint256 public totalStaked;
    // Reward per token staked (accumulated)
    uint256 public rewardPerTokenStored;

    // User balances and rewards
    mapping(address => uint256) public stakedBalance;
    mapping(address => uint256) public rewards;
    mapping(address => uint256) public userRewardPerTokenPaid;

    // Events
    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event RewardRateUpdated(uint256 newRate);

    constructor(address _stakingToken, address _rewardToken) {
        stakingToken = IERC20(_stakingToken);
        rewardToken = IERC20(_rewardToken);
        lastUpdateTime = block.timestamp;
    }

    // Update rewards for a user
    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = block.timestamp;
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }

    // Calculate reward per token
    function rewardPerToken() public view returns (uint256) {
        if (totalStaked == 0) {
            return rewardPerTokenStored;
        }
        return
            rewardPerTokenStored + (
                ((block.timestamp - lastUpdateTime) * rewardRate * 1e18) / totalStaked
            );
    }

    // Calculate earned rewards for a user
    function earned(address account) public view returns (uint256) {
        return
            stakedBalance[account]
                * (rewardPerToken() - (userRewardPerTokenPaid[account]))
                / (1e18)
                +(rewards[account]);
    }

    // Stake tokens
    function stake(uint256 amount) external nonReentrant updateReward(msg.sender) {
        require(amount > 0, "Cannot stake 0");
        totalStaked = totalStaked + (amount);
        stakedBalance[msg.sender] = stakedBalance[msg.sender] + (amount);
        stakingToken.transferFrom(msg.sender, address(this), amount);
        emit Staked(msg.sender, amount);
    }

    // Unstake tokens
    function unstake(uint256 amount) external nonReentrant updateReward(msg.sender) {
        require(amount > 0, "Cannot unstake 0");
        require(stakedBalance[msg.sender] >= amount, "Insufficient balance");
        totalStaked = totalStaked - (amount);
        stakedBalance[msg.sender] = stakedBalance[msg.sender] - (amount);
        stakingToken.transfer(msg.sender, amount);
        emit Unstaked(msg.sender, amount);
    }

    // Claim accumulated rewards
    function claimReward() external nonReentrant updateReward(msg.sender) {
        uint256 reward = rewards[msg.sender];
        require(reward > 0, "No rewards to claim");
        rewards[msg.sender] = 0;
        rewardToken.transfer(msg.sender, reward);
        emit RewardPaid(msg.sender, reward);
    }

    // Update reward rate (only for demo; in production, use governance)
    function setRewardRate(uint256 _rewardRate) external {
        require(_rewardRate > 0, "Reward rate must be positive");
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = block.timestamp;
        rewardRate = _rewardRate;
        emit RewardRateUpdated(_rewardRate);
    }

    // Get staked balance for a user
    function balanceOf(address account) external view returns (uint256) {
        return stakedBalance[account];
    }
}