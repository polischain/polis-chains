// SPDX-License-Identifier: MIT

pragma solidity 0.7.6;

import "./Ownable.sol";

contract Agora is Ownable {

    event TreasurySent(address recipient, uint256 amount);

    function deposit() public payable {}

    function fund(address payable _recipient, uint256 _amount) public onlyOwner {
        (bool success, ) = _recipient.call{value: _amount}("");
        require(success, "Agora: Failed to fund address");
        emit TreasurySent(_recipient, _amount);
    }

}