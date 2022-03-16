//SPDX-License-Identifier: Unlicensed

pragma solidity 0.8.4;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract BRT is ERC20 {
    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _initialSupply
    ) public ERC20(_name, _symbol) {
        // _mint(msg.sender, initialSupply);
        _balances[msg.sender] += _initialSupply;
    }
}
