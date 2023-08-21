pragma solidity ^0.8.10;

interface IWrappedToken {
    function deposit() external payable;

    function approve(address guy, uint wad) external returns (bool);
}
