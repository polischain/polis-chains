pragma solidity 0.5.10;

interface IAgora {
    function deposit() external payable;
    function fund(address _recipient, uint256 _amount) external;
}
