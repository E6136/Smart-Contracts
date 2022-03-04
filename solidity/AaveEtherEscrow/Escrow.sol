//SPDX-License-Identifier: Unlicense
pragma solidity ^0.7.5;

import "./IERC20.sol";
import "./IWETHGateway.sol";

contract Escrow {
    address arbiter;
    address depositor;
    address beneficiary;
    uint256 originalDeposit;
    
    IWETHGateway gateway = IWETHGateway(0xDcD33426BA191383f1c9B431A342498fdac73488);
    IERC20 aWETH = IERC20(0x030bA81f1c18d280636F32af80b9AAd02Cf0854e);
    /*The Escrow Contract sends ether to the WETH Gateway, 
      which sends WETH to the AAVE LendingPool which mints Aave Interest Bearing WETH or aWETH.*/

    constructor(address _arbiter, address _beneficiary) payable {
        arbiter = _arbiter;
        beneficiary = _beneficiary;
        depositor = msg.sender;
        originalDeposit = msg.value;

        //Deposit ETH through the WETH gateway
        gateway.depositETH {value : address(this).balance} (address(this), 0);
    }

    receive() external payable {}
    
    /*When the arbiter decides the transaction is ready, they will call the approve method. 
      In this approve method, will be withdrawn the balance of the escrow from the AAVE pool.*/
    function approve() external {        
        require(msg.sender == arbiter); 
        
        aWETH.approve(address(gateway), type(uint256).max/*aWETH.balanceOf(address(this))*/); /*The gateway is approved to spend 
                                                                                                the escrow's entire balance of aWETH.*/
        
        gateway.withdrawETH(type(uint256).max, address(this));/*We call withdrawETH on the WETHGateway to go from aWETH to ETH.
                                                                This function assumes that the gateway has been approved to spend the aWETH tokens.
                                                                Otherwise, the transferFrom will fail and the transacton will be reverted.*/

        
      /*In this Escrow the resulting ether withdrawn will be larger than the ether initially deposited, 
        thanks to the interest earned in the AAVE protocol.
        We will transfer the initial deposit, to the beneficiary as that was the payment they were promised.
        As far as the interest, we will grant that to the depositor,
        as they deposited the amount far in advance of the payment being sent.*/
        (bool success, ) = payable(beneficiary).call {value: originalDeposit} ("");
        require(success, "The transaction to the beneficiary has failed.");

        selfdestruct(payable(depositor));/*After sending the agreed amount to the beneficiary,
                                           the interest earned on AAVE is sent to the depositor 
                                           and the contract is destroyed.*/
    }
    
}