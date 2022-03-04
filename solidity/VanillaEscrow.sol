// SPDX-License-Identifier: MIT
pragma solidity ^0.7.5;

contract  VanillaEscrow {//Simple escrow
    
    address public depositor;// The depositor will be the signer deploying the contract.
    address payable public beneficiary;
    address public arbiter;

    constructor(address _arbiter, address _beneficiary) payable {// The depositary will ask the arbiter and beneficiary for addresses that those two parties have access to.
                                                                 // Then the depositor will provide those addresses as the arguments to the Escrow contract for storage.
        
        depositor = msg.sender;//The depositor will send some ether to the contract, which will be used to pay the beneficiary after the transfer is approved by the arbiter.
        arbiter = _arbiter;
        beneficiary = payable(_beneficiary);//After the contract has been deployed with the appropriate amount of funds, the beneficiary will provide the good or service.
    }

    function approve() external {//Once the good or service is provided, the arbiter needs to approve the transfer of the deposit over to the beneficiary's account.
        require(arbiter == msg.sender,"You are not the arbiter");
        
        (bool success, ) = beneficiary.call {value: address(this).balance} ("");
        require(success, "Failed to send Ether");
    }
}
