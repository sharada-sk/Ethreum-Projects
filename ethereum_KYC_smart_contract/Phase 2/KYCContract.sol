// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;
//pragma experimental ABIEncoderV2;

import '../contracts/KYCAccControl.sol';

contract KYC is KYCAccControl{          //KYC contract initialisation 

    uint private totalNumberOfBanks;

    constructor() {               //Declare & Initialize total number of banks participatin in the contract
        totalNumberOfBanks = 0;
    }

    struct Customer {                   //Declare customer structure
        string userName;                //customer name
        string data;                    //cuctomer data
        address bank;                   //bank name in which customer wants to crate account
        bool kycStatus;                 //KYC status of customer
        uint downvotes;                 //no. of downVotes gained by customer
        uint upvotes;                   //no. of upVotes gained by customer
    }
    
    struct Bank {                       //Declare Bank structure
        string name;                    //Bank name
        address ethAddress;             //Bank Address
        string regNumber;               //registartion number of bank
        uint complaintsReported;        //No of complaints reported on bank
        uint KYC_count;                 //KYC count done by bank
        bool isAllowedToVote;           //bank is allowed to vote on customer 
    }

    mapping(string => Customer) customers;      //Mapping of index of customer to customre Name 

    mapping(address => Bank) banks;     //Mapping of index of bank to bank Name 

    struct KYC_Request {                //Declare KYC details structure 
        string uName;                   //customers name requesting for KYC
        address bankAddress;            //Bank address in which KYC need to be approved
        bytes32 dataHash;               //string data to be onverted to hash code of customer
        bool isAllowed;                 //KYC request approved/rejected 
    }
    mapping(string => KYC_Request) KYCrequestList;   //Mapping of index of KYC requests to customre Name

    //Process of KYC Verificaton with two conditions check.
    //until customer  kYC request data exists in request stack, check following conditions.  
    //Condition 1: upvites by bank to a custore should be more than downvotes.
    //Condition 2: downvotes by banks to a customer should not exceed 1/3rd of total number of banks.

    function KYCVerify(string memory _userName) public {
        require(KYCrequestList[_userName].bankAddress != address(0),"kyc not requested for the custormer");
        bool tempKYCstatus = false; 
        if(customers[_userName].upvotes >= customers[_userName].downvotes) {
           tempKYCstatus = true; 
        } 
        if (customers[_userName].downvotes*3.0 > 1.0*totalNumberOfBanks){
            tempKYCstatus = false;
        }
        customers[_userName].kycStatus = tempKYCstatus;
    }

    //Process of adding a customer with name,data,bank,kyc status,upvotes,downvotes, 
    //hashcode of customer data, by verifying KYC status and approving the customer.

    function addCustomer(string memory _userName, string memory _customerData) public {
        require(customers[_userName].bank == address(0), "Customer is already present, please call modifyCustomer to edit the customer data");
        customers[_userName].userName = _userName;
        customers[_userName].data = _customerData;
        customers[_userName].bank = msg.sender;
        customers[_userName].kycStatus = true;
        customers[_userName].downvotes = 0;
        customers[_userName].upvotes = 0;
        bytes32 dataHash = sha256(abi.encodePacked(customers[_userName].data));
        addRequest(_userName,dataHash);
        KYCVerify(_userName);
    }

    //Proces of viewing the customer details,if customer exist in database.
    
    function viewCustomer(string memory _userName) public view returns (string memory, string memory, address) {
        require(customers[_userName].bank != address(0), "Customer is not present in the database");
        return (customers[_userName].userName, customers[_userName].data, customers[_userName].bank);
    }

    //Process of modifying Customer details when required if customer exist in database.
    
    function modifyCustomer(string memory _userName, string memory _newcustomerData) public {
        require(customers[_userName].bank != address(0), "Customer is not present in the database");
        removeRequest(_userName);
        customers[_userName].data = _newcustomerData;
        customers[_userName].upvotes = 0;
        customers[_userName].downvotes = 0;
    }    

    //Process of adding the KYC details of a Customer for verification in the request list.
    
    function addRequest(string memory uName, bytes32 dataHash) public {
        KYC_Request memory newKYCrequest = KYC_Request({
            uName : uName,
            dataHash : dataHash,
            bankAddress : msg.sender,
            isAllowed : true });
        KYCrequestList[uName] =  newKYCrequest;
    }
    
    //Process of removing the KYC data of a customer from request list.

    function removeRequest(string memory uName) public {
        require(KYCrequestList[uName].bankAddress != address(0),"KYC request doesn't exist");
        delete KYCrequestList[uName];
    }

    //casting an upvote to a customer by the bank, if customer exist in database.

    function upVoteCustomer(string memory uName) public {
        require(KYCrequestList[uName].bankAddress != address(0),"Customer is not present in the database");
        customers[uName].upvotes++;
        KYCVerify(uName);  
    }

    //casting an downvote to a customer by the bank,if customer exist in database.

    function downVoteCustomer(string memory uName) public  {
        require(KYCrequestList[uName].bankAddress != address(0),"Customer is not present in the database");
        customers[uName].downvotes++;
        KYCVerify(uName);  
    }

    //process of ergistereing complaints aginst bank.

    function getBankComplaints(address ethAddress) public view returns(uint) {
       return banks[ethAddress].complaintsReported;
    }

    //process of viewing bank details such as name, address, regsitration number, complaints reported,
    //KYC count, bank is allowed to vote on customer.

    function viewBankDetails(address ethAddress) public view returns (string memory, address, string memory, uint,uint,bool) {
        require(banks[ethAddress].ethAddress != address(0),"Bank does not exist");
        return ( banks[ethAddress].name,
                  banks[ethAddress].ethAddress,
                  banks[ethAddress].regNumber, 
                  banks[ethAddress].complaintsReported, 
                  banks[ethAddress].KYC_count,
                  banks[ethAddress].isAllowedToVote);
    }

    //process of registering comapint against bank and if more than 1/3rd of banks 
    //have raised complaints then that bank is not allowed to cast any vote on customer.

    function reportBank(address ethAddress) public {
        require(banks[ethAddress].ethAddress != address(0),"Bank does not exist");
            banks[ethAddress].complaintsReported++;
            
            if((banks[ethAddress].complaintsReported*3) > (totalNumberOfBanks)){
                banks[ethAddress].isAllowedToVote = false;
            }
            
    }    

    //process of adding bank details such as name, address, regsitration number, complaints reported,
    //KYC count, bank is allowed to vote on customer and increase the total count of banks 
    //participating in the contract.

    function addBank(string memory name,address ethAddress,string memory regNumber) public onlyAdmin {
        Bank memory bankNew = Bank({name:name,
                        ethAddress:ethAddress,
                        regNumber:regNumber,
                        complaintsReported:0,
                        KYC_count:0,
                        isAllowedToVote:true});
        banks[ethAddress] = bankNew;
        totalNumberOfBanks++;
    }

    //process of modifying the bank status to vote on customer.

    function modifyBankisAllowedToVote(address ethAddress, bool isAllowedToVote) public onlyAdmin{
        banks[ethAddress].isAllowedToVote = isAllowedToVote;
    }

    //process of removing the bank from contract list. 

    function removeBank(address ethAddress) public onlyAdmin{
        delete banks[ethAddress];
        totalNumberOfBanks--;
    }

}   