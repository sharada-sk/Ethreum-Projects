// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

contract KYCAccControl {
     
    address admin;

    constructor()  {
        admin = msg.sender;
    }

    modifier onlyAdmin(){
        require(msg.sender == admin,"This action requires admin permission");
        _;
    }

}