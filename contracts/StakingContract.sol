//SPDX-License-Identifier: Unlicensed

pragma solidity 0.8.4;
import "./interfaces/IERC721.sol";
import "./BRTToken.sol";

contract StakingContract {
    // Address generated after the deployment of token contract.
    address private token = 0x5c16027BeAA623a275009022fDf325a7DB078664;

    // Staking for records.
    struct Staking {
        bool checked;
        bool success;
        uint256 stake;
        uint256 earn;
        uint256 timeStart;
        uint256 timeDue;
    }
    mapping(uint256 => Staking) public stakings;

    // Track the id of staking.
    uint256 private id;

    // BoredApe NFT address.
    address internal constant BOREDAPES =
        0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D;

    function stake(uint256 _stake) external returns (bool x) {
        require(
            IERC721(BOREDAPES).balanceOf(msg.sender) >= 1,
            "No BoredApe NFT"
        );
        Staking storage s = stakings[id];
        s.checked = true;
        s.stake = _stake;
        s.timeStart = block.timestamp;
        s.timeDue = block.timestamp + 3 days;
        uint256 monthly = ((_stake * 10) / 100);
        s.earn = monthly / 30;

        // Deduction and transfer of tokens into the contract.
        uint256 bal = _balances[msg.sender];
        _balances[msg.sender] = bal - _stake;
        s.success = BRT(token).transfer(address(this), _stake);
        x = s.success;
    }

    function withdrawEarning() external returns (bool success, uint256 earn) {
        Staking memory st = stakings[id];
        require(st.success == true, "No staking yet.");
        require((block.timestamp > st.timeDue), "Not up to 3 days");
        st.earn = st.earn + st.stake;
        st.success = BRT(token).transfer(msg.sender, st.earn);
        success = st.success;
        earn = st.earn;
    }

    function reward(uint256 stake) external returns (uint256) {
        uint256 rate = (10 / 30) * 10;
        uint256 timeDeposited = block.timestamp + 3 days;
        if (timeDeposited == 3 days) {
            rate = rate * 3;
        }
        uint256 reward = (rate * stake);
        earn = stake + reward;
    }
}
