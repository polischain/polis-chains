// SPDX-License-Identifier: MIT

pragma solidity 0.7.6;

import "./SafeMath.sol";
import "./Ownable.sol";
import "../IWETH.sol";

contract Agora is Ownable {
    using SafeMath for uint256;

    IWETH public immutable WETH;

    event TreasurySent(address recipient, uint256 amount);

    constructor(address _WETH) {
        WETH = IWETH(_WETH);
    }

    function deposit() external payable {
        WETH.deposit{value: msg.value}();
    }

    function fund(address _recipient, uint256 _amount) external onlyOwner {
        WETH.transfer(_recipient, _amount);
        emit TreasurySent(_recipient, _amount);
    }


}