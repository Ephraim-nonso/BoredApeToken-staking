//SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.4;
import "./interfaces/IERC721.sol";
import "./BRTToken.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract StakingContract {
    using SafeMath for uint256;
    // Address generated after the deployment of token contract.
    IERC20 private token;
    IERC721 private apeNFT;

    // Staking for records.
    struct Staking {
        bool success;
        uint256 stake;
        uint256 reward;
        uint256 timeStart;
        uint256 timeDue;
        uint256 balance;
    }
    mapping(address => Staking) public stakings;

    event Deposit(address owner, uint256 time, uint256 _amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);

    constructor(address _token) {
        token = IERC20(_token);
        // apeNFT = IERC721(_apeNFT);
    }

    function stake(uint256 stake_) external returns (bool success) {
        // require(apeNFT.balanceOf(msg.sender) >= 1, "No BoredApe NFT");
        require(token.balanceOf(msg.sender) >= stake_, "Insufficient funds");
        token.transferFrom(msg.sender, address(this), stake_);
        uint256 deposit = reward(stake_);
        // Records the input into the struct.
        Staking storage s = stakings[msg.sender];
        s.stake = s.stake + stake_;
        s.timeStart = block.timestamp;
        // s.timeDue = (block.timestamp).add(259200);
        s.timeDue = (block.timestamp).add(60);
        s.reward = s.reward + deposit;
        s.balance = s.stake + s.reward;

        // Update state vaariables.
        s.success = true;

        // return success on staking.
        success = s.success;
        emit Deposit(msg.sender, block.timestamp, stake_);
    }

    function reward(uint256 stake_) public pure returns (uint256 reward_) {
        require(stake_ > 0, "Invalid stake passed.");
        uint256 monthlyRate = ((stake_.mul(10)).div(100));
        uint256 dailyRate = monthlyRate.div(30);
        return dailyRate;
    }

    function checkTimeForClaim() internal view returns (bool condition) {
        Staking memory s = stakings[msg.sender];
        if ((block.timestamp >= s.timeDue) && (s.stake != 0)) {
            // if ((block.timestamp >= (s.timeDue + 86400)) && (s.balance != 0)) {
            if ((block.timestamp >= (s.timeDue + 100)) && (s.balance != 0)) {
                return true;
            }
            return true;
        } else {
            return false;
        }
    }

    function withdrawReward(uint256 _amount) external returns (bool success) {
        Staking memory s = stakings[msg.sender];

        // Ensure that amount to withdraw isn't more than rewards.
        require(_amount <= s.reward, "amount exceeds rewards.");
        require(checkTimeForClaim(), "not up to valid date.");
        s.reward = s.reward - _amount;
        s.balance = s.balance - _amount;
        s.balance = s.stake;
        if (s.stake != 0) {
            s.reward = reward(s.stake);
            s.balance = s.stake.add(s.reward);
        }
        emit Withdraw(msg.sender, block.timestamp, s.reward);
        // Transfer from contract to staker.
        success = token.transfer(msg.sender, _amount);
    }

    function withdrawAllInPool() external returns (bool) {
        Staking memory s = stakings[msg.sender];
        // require(block.timestamp > s.timeDue, "Not up to 3 days.");
        require(checkTimeForClaim(), "not up to valid date.");
        token.transfer(msg.sender, s.balance);
        s.success = false;
        s.balance = 0;
        s.stake = 0;
        s.reward = 0;
        s.timeStart = 0;
        s.timeDue = 0;

        // Transfer from contract to staker.
        emit Withdraw(msg.sender, block.timestamp, s.balance);
        return true;
    }

    function getRecord() external view returns (Staking memory c) {
        c = stakings[msg.sender];
    }
}
