// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

import "./interfaces/IERC20.sol";
import "./utils/Ownable.sol";

contract Agora is Ownable {

    IERC20 public immutable polis;

    event TreasurySent(address recipient, uint256 amount);

    constructor(IERC20 _polis) {
        polis = _polis;
    }
    
    // ** View functions ** //

    function getTreasuryBalance() external view returns(uint256) {
        return polis.balanceOf(address(this));
    }

    function fundAddress(address _recipient, uint256 _amount) external onlyOwner {
        polis.transfer(_recipient, _amount);
        emit TreasurySent(_recipient, _amount);
    }

    function extractToken(address _recipient, uint256 _amount, IERC20 _token) external onlyOwner {
        require(address(_token) != address(polis), "invalid");
        require(_token.balanceOf(address(this)) >= _amount, "not enough balance");
        _token.transfer(_recipient, _amount);
    }
}
