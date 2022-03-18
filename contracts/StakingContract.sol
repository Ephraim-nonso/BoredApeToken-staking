//SPDX-License-Identifier: Unlicensed

pragma solidity 0.8.4;
import "./interfaces/IERC721.sol";
import "./BRTToken.sol";

contract StakingContract {
    // Address generated after the deployment of token contract.
    IERC20 private token;
    IERC721 private apeNFT;

    // Staking for records.
    struct Staking {
        bool success;
        uint256 stake;
        uint256 earn;
        uint256 timeStart;
        uint256 timeDue;
        uint256 balance;
    }
    mapping(address => Staking) public stakings;

    event Deposit(address owner, uint256 time, uint256 _amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);

    constructor(IERC20 _token, IERC721 _apeNFT) public {
        token = IERC20(0xbf8d0F47799ffadF356313487fa8492b84D62CEE);
        apeNFT = IERC721(0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D);
    }

    function stake(uint256 stake) external returns (bool success) {
        require(apeNFT.balanceOf(msg.sender) > 1, "No BoredApe NFT");
        require(token.balanceOf(msg.sender) >= stake, "Insufficient funds");

        _balances[msg.sender] = _balances[msg.sender] - stake;
        token.transfer(address(this), stake);

        // Takes not of the decimals
        Staking storage s = stakings[msg.sender];
        s.stake = stake;
        s.timeStart = block.timestamp;
        s.timeDue = block.timestamp + 3 days;
        s.earn = reward(stake);

        // Update state vaariables.
        s.success = true;

        // return success on staking.
        success = s.success;
        emit Deposit(msg.sender, block.timestamp, stake);
    }

    function reward(uint256 stake) internal returns (uint256 reward) {
        stake = stake * (10**18);
        uint256 monthlyRate = ((stake * 10) / 100);
        uint256 dailyRate = monthlyRate / 30;
        reward = dailyRate;
    }

    function withdrawReward(uint256 _amount) external returns (uint256 reward) {
        Staking memory s = stakings[msg.sender];
        require(_amount <= s.earn, "amount exceeds rewards.");
        // Get the reward.
        uint256 earn = s.earn;
        uint256 bal = _balances[address(this)];
        uint256 balOwner = _balances[address(this)];

        // Do the maths.
        _balances[address(this)] = bal - earn;
        _balances[msg.sender] = balOwner + earn;

        // Transfer from contract to staker.
        address(this).transfer(msg.sender, earn);
        reward = s.earn;
        emit Withdraw(msg.sender, block.timestamp, earn);
    }

    function withdrawAllInPool() external returns (bool) {
        Staking memory s = stakings[msg.sender];
        require(block.timestamp > s.timeDue, "Not up to 3 days.");

        // Get the total of stake and earning.
        uint256 earning = s.earn;
        uint256 totalAmount = s.stake + earning;
        uint256 bal = _balances[address(this)];
        uint256 balOwner = _balances[address(this)];

        // Do the maths.
        _balances[address(this)] = bal - totalAmount;
        _balances[msg.sender] = balOwner + totalAmount;

        // Transfer from contract to staker.
        address(this).transfer(msg.sender, totalAmount);
        emit Withdraw(msg.sender, block.timestamp, totalAmount);
    }
}
