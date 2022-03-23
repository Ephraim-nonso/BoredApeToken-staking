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
        // Takes not of the decimals
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
            return reward_ = dailyRate.mul(3);
        } else if ((block.timestamp >= (s.timeDue + 86400)) && (s.stake != 0)) {
            return dailyRate.mul(3) + dailyRate;
        } else {
            return 0;
        }
    }

    // function withdrawReward(uint256 _amount) external returns (bool suc) {
    //     Staking memory s = stakings[msg.sender];

    //     // Ensure that amount to withdraw isn't more than rewards.
    //     require(_amount <= s.earn, "amount exceeds rewards.");
    //     s.balance = s.balance.sub(s.earn);
    //     s.balance = s.stake;
    //     if (s.stake != 0) {
    //         uint256 newReward = reward(s.stake);
    //         s.balance = s.stake.add(newReward);
    //     }
    //     // Transfer from contract to staker.
    //     uint256 done = address(this).transfer(msg.sender, s.earn);
    //     reward = done;
    //     emit Withdraw(msg.sender, block.timestamp, earn);
    // }

    // function withdrawAllInPool() external returns (bool) {
    //     Staking memory s = stakings[msg.sender];
    //     require(block.timestamp > s.timeDue, "Not up to 3 days.");

    //     // Get the total of stake and earning.
    //     // uint256 earning = s.earn;
    //     // uint256 totalAmount = s.stake + earning;
    //     // uint256 bal = _balances[address(this)];
    //     // uint256 balOwner = _balances[address(this)];

    //     // // Do the maths.
    //     // _balances[address(this)] = bal - totalAmount;
    //     // _balances[msg.sender] = balOwner + totalAmount;

    //     // // Transfer from contract to staker.
    //     address(this).transfer(msg.sender, totalAmount);
    //     emit Withdraw(msg.sender, block.timestamp, totalAmount);
    // }
}
