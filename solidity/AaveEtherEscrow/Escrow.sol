//SPDX-License-Identifier: Unlicense
pragma solidity ^0.7.5;

import "./IERC20.sol";
import "./IWETHGateway.sol";

contract Escrow {
    address arbiter;
    address depositor;
    address beneficiary;
    
    IWETHGateway gateway = IWETHGateway(0xDcD33426BA191383f1c9B431A342498fdac73488);
    IERC20 aWETH = IERC20(0x030bA81f1c18d280636F32af80b9AAd02Cf0854e);
    //The Escrow Contract sends ether to the WETH Gateway, 
    //which sends WETH to the AAVE LendingPool which mints Aave Interest Bearing WETH or aWETH.

    constructor(address _arbiter, address _beneficiary) payable {
        arbiter = _arbiter;
        beneficiary = _beneficiary;
        depositor = msg.sender;

        //Deposit ETH through the WETH gateway
        gateway.depositETH {value : address(this).balance} (address(this), 0);
    }

    function approve() external view {
        require(msg.sender == arbiter);

    }
}