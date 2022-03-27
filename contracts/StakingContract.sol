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
        bool updateStake;
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

    /**
     * @dev Returns success on staking successfully.
     */
    function stake(uint256 stake_) public {
        require(apeNFT.balanceOf(msg.sender) >= 1, "No BoredApe NFT");
        token.transferFrom(msg.sender, address(this), stake_);
        uint256 rewardFromDeposit = calculateReward(stake_);
        // Records the input into the struct.
        Staking storage s = stakings[msg.sender];
        s.stake = s.stake.add(stake_);
        s.timeStart = block.timestamp;
        s.timeDue = (block.timestamp).add(259200);
        s.reward = s.reward.add(rewardFromDeposit);
        s.balance = s.stake.add(s.reward);

        // Update state variable for successful stake.
        s.success = true;

        emit Deposit(msg.sender, block.timestamp, stake_);
    }

    /**
     * @dev Calcuates the reward on staking token.
     */
    function calculateReward(uint256 stake_)
        internal
        pure
        returns (uint256 reward_)
    {
        require(stake_ > 0, "Invalid stake passed.");
        stake_ = stake_ * 1e18;
        uint256 monthlyRate = ((stake_.mul(10)).div(100));
        uint256 dailyRate = monthlyRate.div(30);
        reward_ = dailyRate.div(86400);
    }

    /**
     * @dev Check for the time of withdrawal.
     */
    function checkTimeForClaim()
        internal
        view
        returns (uint256 daysSpent, bool condition)
    {
        Staking storage s = stakings[msg.sender];
        daysSpent = block.timestamp - s.timeStart;
        if ((block.timestamp >= s.timeDue) && (s.stake != 0)) {
            return (daysSpent, true);
        } else {
            return (daysSpent, false);
        }
    }

    /**
     * @dev Returns success on withdrawal of tokeen having met the criteria.
     */
    function withdrawRewardFromBalance(uint256 _amount) external {
        (uint256 daysSpent, bool pass) = checkTimeForClaim();
        Staking storage s = stakings[msg.sender];
        s.reward = s.reward * daysSpent;
        // Ensure that amount to withdraw is not more than rewards.
        require(_amount <= s.reward, "Amount exceeds reward.");
        require(pass, "Not up to valid date.");
        s.reward = s.reward.sub(_amount);
        s.stake = s.balance.sub(_amount);
        s.balance = s.stake.add(s.reward);
        if (s.updateStake == true) {
            s.reward = updateStake(s.stake);
        }
        // Transfer from contract to staker.
        token.transfer(msg.sender, _amount);

        emit Withdraw(msg.sender, block.timestamp, _amount);
    }

    function withdrawAllInPool() external {
        (, bool pass) = checkTimeForClaim();
        Staking storage s = stakings[msg.sender];
        // require(block.timestamp > s.timeDue, "Not up to 3 days.");
        require(s.success == true, "Not a staker.");
        require(pass, "Not up to valid date.");
        token.transfer(msg.sender, s.balance);
        s.success = false;
        s.balance = 0;
        s.stake = 0;
        s.reward = 0;
        s.timeStart = 0;
        s.timeDue = 0;

        emit Withdraw(msg.sender, block.timestamp, s.balance);
    }

    function allowAutoUpdateStake() external {
        Staking storage autoUpdate = stakings[msg.sender];
        autoUpdate.updateStake = !autoUpdate.updateStake;
    }

    function updateStake(uint256 _newStake) internal returns (uint256 val) {
        Staking storage s = stakings[msg.sender];
        _newStake = s.balance;
        s.timeStart = block.timestamp;
        s.timeDue = (block.timestamp).add(259200);
        uint256 newReward = calculateReward(_newStake);
        val = newReward;
    }

    function getRecord(address _address)
        external
        view
        returns (Staking memory c)
    {
        c = stakings[_address];
    }

    function getContractBalance() external view returns (uint256 bal) {
        return token.balanceOf(address(this));
    }
}
