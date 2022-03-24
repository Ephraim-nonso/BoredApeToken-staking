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

    constructor(address _token, address _apeNFT) {
        token = IERC20(_token);
        apeNFT = IERC721(_apeNFT);
    }

    function stake(uint256 stake_) external returns (bool success) {
        // Ensure that input equals the token decimals.
        stake_ = stake_.mul((10**18));
        require(apeNFT.balanceOf(msg.sender) >= 1, "No BoredApe NFT");
        require(token.balanceOf(msg.sender) >= stake_, "Insufficient funds");
        token.transferFrom(msg.sender, address(this), stake_);

        // Records the input into the struct.
        Staking storage s = stakings[msg.sender];
        s.stake = stake_;
        s.timeStart = block.timestamp;
        s.timeDue = (block.timestamp).add(259200);
        s.reward = reward(stake_);
        s.balance = s.stake + s.reward;

        // Update state vaariables.
        s.success = true;

        // return success on staking.
        success = s.success;
        emit Deposit(msg.sender, block.timestamp, stake_);
    }

    function reward(uint256 stake_) internal view returns (uint256 reward_) {
        Staking memory s = stakings[msg.sender];
        stake_ = stake_.mul((10**18));
        uint256 monthlyRate = ((stake_.mul(10)).div(100));
        uint256 dailyRate = monthlyRate.div(30);
        require(stake_ > 0, "No record.");
        require(stake_ > 0, "Invalid stake passed.");
        if ((block.timestamp >= s.timeDue) && (s.stake != 0)) {
            if ((block.timestamp >= (s.timeDue + 86400)) && (s.stake != 0)) {
                return dailyRate.mul(3) + dailyRate;
            }
            return reward_ = dailyRate.mul(3);
        } else {
            return 0;
        }
    }

    function withdrawReward(uint256 _amount) external returns (bool success) {
        Staking memory s = stakings[msg.sender];

        // Ensure that amount to withdraw isn't more than rewards.
        require(_amount <= s.reward, "amount exceeds rewards.");
        s.reward = s.reward.sub(_amount);
        s.balance = s.balance.sub(_amount);
        s.balance = s.stake;
        if (s.stake != 0) {
            s.reward = reward(s.stake);
            s.balance = s.stake.add(s.reward);
        }
        emit Withdraw(msg.sender, block.timestamp, s.reward);
        // Transfer from contract to staker.
        success = token.transfer(msg.sender, s.reward);
    }

    function withdrawAllInPool() external returns (bool) {
        Staking memory s = stakings[msg.sender];
        require(block.timestamp > s.timeDue, "Not up to 3 days.");
        // // Transfer from contract to staker.
        emit Withdraw(msg.sender, block.timestamp, s.balance);
        return token.transfer(msg.sender, s.balance);
    }
}
