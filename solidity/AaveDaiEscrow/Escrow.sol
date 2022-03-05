//SPDX-License-Identifier: Unlicense
pragma solidity ^0.7.5;

import "./IERC20.sol";
import "./ILendingPool.sol";

contract Escrow {
    address arbiter;
    address depositor;
    address beneficiary;
    uint256 originalDeposit;


    // the mainnet AAVE v2 lending pool
    ILendingPool pool = ILendingPool(0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9);
    // aave interest bearing DAI
    IERC20 aDai = IERC20(0x028171bCA77440897B824Ca71D1c56caC55b68A3);
    // the DAI stablecoin 
    IERC20 dai = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);

    constructor(address _arbiter, address _beneficiary, uint _amount) {
        arbiter = _arbiter;
        beneficiary = _beneficiary;
        depositor = msg.sender;
        originalDeposit = _amount;
        
      /*The constructor of our Escrow will transfer the DAI from the depositor to itself.
        It can assume that the depositor has already approved the contract to spend its funds.*/
        dai.transferFrom(msg.sender, address(this), _amount);
      
      /*The Lending Pool will take the DAI and, in exchange,
        mint new aDAI for the contract to hold on to.*/
        dai.approve(address(pool), _amount);
        pool.deposit(address(dai), _amount, address(this), 0);
    }

    function approve() external {
        require(msg.sender == arbiter);
        
      /*The DAI deposited in this Escrow will earn interest,
        so that by the time it is withdrawn,
        there will be more DAI available than initially deposited. */
        pool.withdraw(address(dai), originalDeposit, beneficiary);
      
      /*After sending the original amount to the beneficiary,
        we send the interest earned (the remaining balance of the pool) to the depositary.*/
        pool.withdraw(address(dai), type(uint256).max, depositor);
    }
    
}