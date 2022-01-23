// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "../contracts//KYCAccControl.sol";
import "../contracts/KYCContract.sol";



contract test {

    function runTest() public {
        address addr = 0x0A098Eda01Ce92ff4A4CCb7A4fFFb5A43EBC70DC;
        string memory bank_name = "SBI";
        string memory regNo = "1RV22IS001";
        KYC K = KYC(0xd9145CCE52D386f254917e481eB44e9943F39138);
        K.addBank(bank_name,addr,regNo);
       // addBank('HDFC',address(keccak256(abi.encodePacked(now)),'1RV22IS002');
        //addBank('KOTAK',address(keccak256(abi.encodePacked(now)),'1RV22IS003');
        //addBank('ICICI',address(keccak256(abi.encodePacked(now)),'1RV22IS004');
        //addBank('AXIS',address(keccak256(abi.encodePacked(now)),'1RV22IS005');
    }
}