//SPDX-License-Identifier: Unlicensed

pragma solidity 0.8.4;
import "./interfaces/IERC721.sol";
import "./BRTToken.sol";

contract StakingContract {
    ERC20 private token;
    struct Staking {
        bool checked;
        bool success;
        uint256 stake;
        uint256 earn;
        uint256 time;
    }

    uint256 private id;

    address internal constant BOREDAPES =
        0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D;

    mapping(uint256 => Staking) public stakings;

    function stake(uint256 _stake) external returns (bool x) {
        require(
            IERC721(BOREDAPES).balanceOf(msg.sender) >= 1,
            "No BoredApe NFT"
        );
        Staking storage s = stakings[id];
        s.checked = true;
        s.stake = _stake;
        s.time = block.timestamp + 3 days;
        s.earn = (((_stake**10) ^ 18) * 10) / 100;

        // Deduction and transfer of tokens into the contract.
        uint256 balances = token.balanceOf(msg.sender);
        balances = balances - _stake;
        s.success = token.transfer(address(this), _stake);
        x = s.success;
    }

    function withdrawEarning() external returns (bool success, uint256) {
        Staking memory st = stakings[id];
        require(st.success == true, "No staking yet.");
        require(st.time == 3 days, "Not up to 3 days");
        st.success = token.transfer(msg.sender, st.earn);
        success = st.success;
        st.earn;
    }
}
