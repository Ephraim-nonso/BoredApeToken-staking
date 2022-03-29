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
        bool autoUpdateStake;
        uint256 stake;
        uint256 timeStaked;
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
    function stake(uint256 stake_) public returns (uint256 reward) {
        require(apeNFT.balanceOf(msg.sender) >= 1, "No BoredApe NFT");
        require(token.balanceOf(msg.sender) >= stake_, "Insufficient funds");
        token.transferFrom(msg.sender, address(this), stake_);
        // Records the input into the struct.
        Staking storage s = stakings[msg.sender];
        s.stake = s.stake.add(stake_);
        s.timeStaked = block.timestamp;
        s.success = true;
        reward = calculateReward(stake_);

        // Update state variable for successful stake.
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
        daysSpent = block.timestamp - s.timeStaked;
        if ((block.timestamp >= (s.timeStaked + 259200)) && (s.stake != 0)) {
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
        uint256 reward = stake(s.stake);
        reward = reward * daysSpent;
        // Ensure that amount to withdraw is not more than rewards.
        require(_amount <= reward, "Amount exceeds reward.");
        require(pass, "Not up to valid date.");
        reward = reward.sub(_amount);
        s.stake = s.stake.sub(_amount);

        if (s.autoUpdateStake == true) {
            reward = updateStake(s.stake);
        }
        // Transfer from contract to staker.
        token.transfer(msg.sender, _amount);

        emit Withdraw(msg.sender, block.timestamp, _amount);
    }

    function withdrawAllInPool() external {
        (, bool pass) = checkTimeForClaim();
        Staking storage s = stakings[msg.sender];
        uint256 reward = stake(s.stake);
        require(block.timestamp > (s.timeStaked + 259200), "Not up to 3 days.");
        require(s.success == true, "Not a staker.");
        require(pass, "Not up to valid date.");
        s.stake = s.stake + reward;
        token.transfer(msg.sender, s.stake);
        s.success = false;

        s.stake = 0;
        s.timeStaked = 0;
        emit Withdraw(msg.sender, block.timestamp, s.stake);
    }

    function allowAutoUpdateStake() external {
        Staking storage autoUpdate = stakings[msg.sender];
        autoUpdate.autoUpdateStake = !autoUpdate.autoUpdateStake;
    }

    function updateStake(uint256 _newStake) internal returns (uint256 val) {
        Staking storage s = stakings[msg.sender];
        _newStake = s.stake;
        s.timeStaked = block.timestamp;
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
