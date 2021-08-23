pragma solidity >=0.5.0;

interface IWETH {
    function deposit() external payable;
    function balanceOf(address _address) external returns (uint256);
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}