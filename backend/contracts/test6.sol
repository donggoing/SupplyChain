pragma solidity ^0.4.4;

contract test6 {
    
    struct Bank {
        string name;
        address _address;
        uint16 recommendRate;//financingRate*10000
    }
    
    struct CoreCompany {
        string name;
        address _address;
    }
    
    struct Company {
        string name;
        address _address;
    }
    
    struct Receipt {
        uint256 index;
        address borrower;
        address lender;
        address bank;
        uint256 amount;
        uint256 sTimeStamp;
        uint256 eTimeStamp;
        bool signed;
        bool confirmed;
        bool checkByBank;
        bool accepted;
        bool settled;
    }
    
    struct Token {
        uint256 recIndex;
        uint256 amount;
        address owner;
        address lender;
        uint256 returnTimestamp;
        bool hasSettled;
        // uint16 cashRate;
    }
    
    struct Apply4Withdraw {
        uint256 tokenIndex;
        uint256 amount;
        address applyer;
        address bank;
        bool checked;
        bool confirmed;
    }
    
    struct Apply4Finance {
        uint256 tokenIndex;
        uint256 amount;
        uint16 applyRate;
        address applyer;
        address bank;
        bool checked;
        bool confirmed;
        uint256 expireDate;
    }
    
    address private admin; 
    uint256 curIndex;
    

    
    mapping(address=>uint256) banks; 
    mapping(address=>uint256) coreCompanys;
    mapping(address=>uint256) companys;
    
    mapping(address=>Apply4Withdraw[]) ap4Withdraws;
    mapping(address=>Apply4Finance[]) ap4Finances;
    
    mapping(address=>uint256[]) allNormCompRec;
    mapping(address=>uint256[]) allCoCompRec;
    mapping(address=>uint256[]) allBankRec;
    
    mapping(address=>uint256[]) tokenOf;
    mapping(uint256=>uint256[]) recTokens;
    
    
    mapping(address=>uint256[]) unsignedRec;
    
    mapping(uint256=>uint256) unsignedRecMap;
    mapping(uint256=>uint256) pendingRecMap;
    
    mapping(address=>uint256[]) pendingRec;
    mapping(address=>uint256[]) unsettledRec;
    mapping(address=>uint256[]) settledRec; 
    
    mapping(uint256=>uint256) unsettledRecMap;
    
    mapping(address=>uint256) cash;
    
    Receipt[] receipts;
    // uint256[] pendingRec;
    
    Bank[] allbanks;
    CoreCompany[] allCoreCompanys;
    // Company[] allNormalCompanys;
    
    
    address[] bankAddresses;
    address[] coreCompanyAddresses;
    
    Token[] tokens;
    
    
    modifier onlyAdmin(){
        require(
            msg.sender==admin
            );
        _;
    }
    
    modifier adminOrBank(){
        require(
            msg.sender==admin ||
            (
            allbanks.length!=0&&
            banks[msg.sender]<allbanks.length&&
            allbanks[banks[msg.sender]]._address==msg.sender
            )
            );
        _;
    }

    modifier onlyBank(){
        require(
            allbanks.length!=0&&
            banks[msg.sender]<allbanks.length&&
            allbanks[banks[msg.sender]]._address==msg.sender
            );
        _;
    }

    modifier onlyCoreCompany(){
        require(            
            allCoreCompanys.length!=0&&
            coreCompanys[msg.sender]<allCoreCompanys.length&&
            allCoreCompanys[coreCompanys[msg.sender]]._address==msg.sender
            );
        _;
    }
    
    modifier isBank(address _address){
        require(
            allbanks.length!=0&&
            banks[_address]<allbanks.length&&
            allbanks[banks[_address]]._address==_address
            );
        _;
    }
    
    modifier isCoreCompany(address _address){
        require(
            allCoreCompanys.length!=0&&
            coreCompanys[_address]<allCoreCompanys.length&&
            allCoreCompanys[coreCompanys[_address]]._address==_address
            );
        _;
    }
    
    
    constructor() public {
        admin = msg.sender;
        curIndex = 0;
    }
    
    event getAllBanksRes(address[]);
    
    function getAllBanks()public view returns(address[] allbank){
        emit getAllBanksRes(bankAddresses);
        return bankAddresses;
    }
    
    event getAllCoreCompanysRes(address[] coreCompanys);
    function getAllCoreCompanys()public view returns(address[] coreCompany){
        emit getAllCoreCompanysRes(coreCompanyAddresses);
        return coreCompanyAddresses;
        
    }
    
    event getBankRes(string,uint16);
    function getBank(address bankAddress)public isBank(bankAddress) view 
        returns(string name,uint16 recommendRate)
    {
        require(banks[bankAddress]>=0&&banks[bankAddress]<allbanks.length);
        Bank storage bank = allbanks[banks[bankAddress]];
        emit getBankRes(bank.name,bank.recommendRate);
        return (bank.name,bank.recommendRate);
    }
    
    event getCoreCompanyRes(string);
    function getCoreCompany(address compAddress)public isCoreCompany(compAddress) view 
        returns(string name)
    {
        require(coreCompanys[compAddress]>=0&&coreCompanys[compAddress]<allCoreCompanys.length);
        CoreCompany storage coreCompany = allCoreCompanys[coreCompanys[compAddress]];
        emit getCoreCompanyRes(coreCompany.name);
        return (coreCompany.name);
    }
    
    event addBankRes(bool);
    function addBank(address _address, string _name) 
        public onlyAdmin returns(bool success)
    {
        if(allbanks.length!=0&&
            banks[_address]<allbanks.length&&
            allbanks[banks[_address]]._address==_address)
        {   
            emit addBankRes(false);
            return false;
        }
        banks[_address] = allbanks.length;
        allbanks.push(Bank(_name,_address,8000));
        bankAddresses.push(_address);
        emit addBankRes(true);
        return true;
    }
    
    
    // function setRate(uint16 rate)
    //     public onlyBank returns(bool success)
    // {
    //     allbanks[banks[msg.sender]].recommendRate = rate;
    //     return true;
    // }
    
    event addCoreCompanyRes(bool);
    function addCoreCompany(address _address, string _name) 
        public onlyAdmin returns(bool success) 
    {
        if(allCoreCompanys.length!=0&&
            coreCompanys[_address]<allCoreCompanys.length&&
            allCoreCompanys[coreCompanys[_address]]._address==_address
            )
        {
            emit addCoreCompanyRes(false);
            return false;
        }
        coreCompanys[_address]=allCoreCompanys.length;
        allCoreCompanys.push(CoreCompany(_name,_address));
        coreCompanyAddresses.push(_address);
        emit addCoreCompanyRes(true);
        return true;
    }
    
    event uploadReceiptRes(bool,uint256);
    function uploadReceipt(address _compAddress,address _bankAddress, uint256 amount, uint256 returnTimestamp)
        public isCoreCompany(_compAddress) isBank(_bankAddress) returns(bool success,uint256 receiptIndex)
    {
        uint256 current = now;
        if(current>returnTimestamp){
            emit uploadReceiptRes(false,0);
            return (false,0);
        }
        receipts.push(Receipt(curIndex,_compAddress,msg.sender,_bankAddress,amount,current,returnTimestamp,false,false,false,false,false));
        unsignedRecMap[curIndex]=unsignedRec[_compAddress].length;
        unsignedRec[_compAddress].push(curIndex);
        allCoCompRec[_compAddress].push(curIndex);
        curIndex++;
        emit uploadReceiptRes(true,curIndex);
        return (true,curIndex-1);
    }
    
    event unsignedRecRes(uint256[]);
    function getUnsignedRec()
        public onlyCoreCompany returns(uint256[] unsignedRecIndex)
    {
        uint256[] ret = uint256[](unsignedRec[msg.sender]);
        emit unsignedRecRes(ret);
        return ret;
    }
    
    event signRecRes(bool);
    function signRec(uint256 index,bool confirm)
        public onlyCoreCompany returns(bool success)
    {
        if(receipts[index].borrower != msg.sender){
            emit signRecRes(false);
            return false;
        }
            
        receipts[index].signed = true;
        if(confirm){
            receipts[index].confirmed = true;
            uint len = unsignedRec[msg.sender].length;
            uint i = unsignedRecMap[index];
            unsignedRec[msg.sender][i]= unsignedRec[msg.sender][len-1];
            unsignedRec[msg.sender].length--;
            
            pendingRecMap[index]=pendingRec[receipts[index].bank].length;
            pendingRec[receipts[index].bank].push(index);
        }
        allBankRec[receipts[index].bank].push(index);
        emit signRecRes(true);
        return true;
    }
    
    
    event getRecRes(uint256 recIndex,address coreCompanyAdd,
                address lenderAddress,
                address bankAddress,
                uint256 amount,uint256 sTimeStamp,
                uint256 eTimeStamp,bool signed,
                bool confirmed,bool checkByBank,
                bool accepted,bool settled);
    function getRec(uint256 index)
        public returns(uint256 recIndex,address coreCompanyAdd,
                address lenderAddress,
                address bankAddress,
                uint256 amount,uint256 sTimeStamp,
                uint256 eTimeStamp,bool signed,
                bool confirmed,bool checkByBank,
                bool accepted,bool settled)
    {
        require(
            index>=0&&
            index<receipts.length
            );
        Receipt storage receipt = receipts[index];      
        // return receipt;
        emit getRecRes(index,receipt.borrower,
                receipt.lender,
                receipt.bank,
                receipt.amount,receipt.sTimeStamp,
                receipt.eTimeStamp,receipt.signed,
                receipt.confirmed,receipt.checkByBank,
                receipt.accepted,receipt.settled);
        return (index,receipt.borrower,
                receipt.lender,
                receipt.bank,
                receipt.amount,receipt.sTimeStamp,
                receipt.eTimeStamp,receipt.signed,
                receipt.confirmed,receipt.checkByBank,
                receipt.accepted,receipt.settled);
    }
    
    event getPendingRecRes(uint256[]);
    function getPendingRec()
        public onlyBank returns(uint256[] pendingRecIndex)
    {
        pendingRecIndex =  uint256[](pendingRec[msg.sender]);
        emit getPendingRecRes(pendingRecIndex);
    }
    
    event acceptRecRes(bool);
    function acceptRec(uint256 index,bool accept)
        public onlyBank returns(bool success)
    {
        Receipt storage receipt = receipts[index];
        if(!receipt.confirmed||receipt.checkByBank||receipt.bank!=msg.sender)
        {
            emit acceptRecRes(false);
            return false;
        }
        receipt.checkByBank = true;
        if(accept){
            receipt.accepted = true;
            tokens.push(Token(index,receipt.amount,receipt.lender,msg.sender,receipt.eTimeStamp,false));
            tokenOf[receipt.lender].push(tokens.length-1);
            recTokens[index].push(tokens.length-1);
            unsettledRecMap[index]=unsettledRec[msg.sender].length;
            unsettledRec[msg.sender].push(index);
            pendingRec[msg.sender][pendingRecMap[index]] = pendingRec[msg.sender][pendingRec[msg.sender].length-1];
            pendingRec[msg.sender].length--;
        }
        emit acceptRecRes(true);
        return true;
    }
    
    event transferRes(bool);
    function transfer(address receiver, uint256 index, uint256 amount)
        public returns(bool success)
    {
        require(
            index>=0&&
            index<tokens.length&&
            tokens[index].owner==msg.sender&&
            tokens[index].amount>=amount
            );
        Token storage token =  tokens[index];
        token.amount -= amount;
        tokenOf[receiver].push(tokens.length);
        recTokens[index].push(tokens.length);
        Token memory newToken = Token(index,amount,receiver,token.lender,token.returnTimestamp, token.hasSettled);
        tokens.push(newToken);
        emit transferRes(true);
        return true;
    }
    
    event getAllTokenRes(uint256[]);
    function getAllToken()public returns(uint256[] tokenIndex){
        tokenIndex = uint256[](tokenOf[msg.sender]);
        emit getAllTokenRes(tokenIndex);
    }
    
    event getTokenRes(uint256 recIndex,address coreCompanyAdd,string coreCompanyName,uint256 amount,uint256 returnTimestamp, bool hasSettled);
    
    function getToken(uint256 index)
        public returns(uint256 recIndex,address coreCompanyAdd,string coreCompanyName,uint256 amount,uint256 returnTimestamp, bool hasSettled)
        // returns (Token)
    {
        require(
            index>=0&&
            index<tokens.length&&
            tokens[index].owner == msg.sender
            );
        Token storage token = tokens[index];
        emit getTokenRes(token.recIndex,receipts[token.recIndex].borrower,
                allCoreCompanys[coreCompanys[receipts[token.recIndex].borrower]].name,
                token.amount,token.returnTimestamp ,token.hasSettled);
        // return token;
        return (token.recIndex,receipts[token.recIndex].borrower,
                allCoreCompanys[coreCompanys[receipts[token.recIndex].borrower]].name,
                token.amount,token.returnTimestamp ,token.hasSettled);
    }
    
    event settleRecRes(bool);
    function settleRec(uint256 index)
        public returns(bool success)
    {
        require(
            index>=0&&
            index<receipts.length&&
            msg.sender==receipts[index].bank
            );
        uint256[] memory tokenIndex = recTokens[index];
        for(uint256 i = 0 ; i<tokenIndex.length;i++){
            tokens[tokenIndex[i]].hasSettled=true;
        }
        
        uint256 len = unsettledRec[msg.sender].length;
        i = unsettledRecMap[index];
        unsettledRec[msg.sender][i]= unsettledRec[msg.sender][len-1];
        unsettledRec[msg.sender].length--;
        
        settledRec[msg.sender].push(index);
        emit settleRecRes(true);
        return true;
    }
    
    event getNormCompRecRes(uint256[]);
    function getNormCompRec()public returns(uint256 [] recIndex){
        recIndex = allNormCompRec[msg.sender];
        return recIndex;
    }
    
    event getAllUnsettledRecRes(uint256[]);
    function getAllUnsettledRec()
        public onlyBank returns(uint256[] unsettledRecIndex)
    {
        unsettledRecIndex = unsettledRec[msg.sender];
        emit getAllUnsettledRecRes(unsettledRecIndex);
        return unsettledRecIndex;
    }
        
    // function getAllSettledRec()
    //     public onlyBank returns(uint256[] settledRecIndex)
    // {
    //     return settledRec[msg.sender];
    // }
    
    event applyWithdrawRes(bool);
    function applyWithdraw(uint256 index,uint256 amount)
        public returns(bool success)
    {
        if(!(index>=0&&
            index<tokens.length&&
            tokens[index].owner==msg.sender&&
            tokens[index].amount>=amount&&
            tokens[index].hasSettled&&
            now>=tokens[index].returnTimestamp
        )){
            emit applyWithdrawRes(false);
            return false;
        }
        address bank = receipts[tokens[index].recIndex].bank;
        ap4Withdraws[bank].push(Apply4Withdraw(index,amount,msg.sender,bank,false,false));
        emit applyWithdrawRes(true);
        return true;
    }
    
    // function getAp4WithdrawLen()
    //     public onlyBank returns(uint256 applylen)
    // {
    //     return ap4Withdraws[msg.sender].length;
    // }
    
    event getAp4WithdrawRes(uint256 tokenIndex,
            uint256 amount,
            address applyer,
            address bank,
            bool checked,
            bool confirmed);
    function getAp4Withdraw(uint256 index)
        public onlyBank 
        returns(
            uint256 tokenIndex,
            uint256 amount,
            address applyer,
            address bank,
            bool checked,
            bool confirmed)
    {
        require(index>=0&&index<ap4Withdraws[msg.sender].length);
        Apply4Withdraw storage ap = ap4Withdraws[msg.sender][index];
        emit getAp4WithdrawRes(ap.tokenIndex,ap.amount,ap.applyer,ap.bank,ap.checked,ap.confirmed);
        return (ap.tokenIndex,ap.amount,ap.applyer,ap.bank,ap.checked,ap.confirmed);
    }
    
    event checkAp4WithdrawRes(bool);
    function checkAp4Withdraw(uint256 index, bool confirm)
        public onlyBank returns(bool success)
    {
        if(!(index>=0&&index<ap4Withdraws[msg.sender].length)
            ||ap4Withdraws[msg.sender][index].bank!=msg.sender
            ||ap4Withdraws[msg.sender][index].checked){
                emit checkAp4WithdrawRes(false);
                return false;
            }
        Apply4Withdraw[] storage aps = ap4Withdraws[msg.sender];
        aps[index].checked = true;
        if(confirm){
            Token storage token = tokens[aps[index].tokenIndex];
            if(token.amount<aps[index].amount||!(token.hasSettled&&now>=token.returnTimestamp)){
                emit checkAp4WithdrawRes(false);
                return false;
            }
            token.amount -= aps[index].amount;
            //TODO:Token to cash
            cash[token.owner]+=aps[index].amount;
            aps[index]=aps[aps.length-1];
            aps.length--;
            emit checkAp4WithdrawRes(true);
            return true;
        }
        else {
            emit checkAp4WithdrawRes(false);
            return false;
        }
    }
    
    
    event applyFinanceRes(bool);
    function applyFinance(uint256 index,uint256 amount,address bank,uint16 rate)
        public returns(bool success)
    {
        if(index<0||
            index>=tokens.length||
            tokens[index].owner!=msg.sender||
            tokens[index].amount<amount||
            (tokens[index].hasSettled&&
            now>=tokens[index].returnTimestamp)
        ){
            emit applyFinanceRes(false);
            return false;
        }
        ap4Finances[bank].push(Apply4Finance(index,amount,rate,msg.sender,bank,false,false,tokens[index].returnTimestamp));
        emit applyFinanceRes(true);
        return true;
    }
    
    event getApLenRes(uint256,uint256);
    function getApLen()
        public onlyBank returns(uint256 financelen,uint256 withdrawlen)
    {
        emit getApLenRes(ap4Finances[msg.sender].length,ap4Withdraws[msg.sender].length);
        return (ap4Finances[msg.sender].length,ap4Withdraws[msg.sender].length);
    }
    
    event getAp4FinanceRes(
            uint256 tokenIndex,
            uint256 amount,
            address applyer,
            uint16 applyRate,
            address bank,
            bool checked,
            bool confirmed);
    function getAp4Finance(uint256 index)
        public onlyBank
        returns(
            uint256 tokenIndex,
            uint256 amount,
            address applyer,
            uint16 applyRate,
            address bank,
            bool checked,
            bool confirmed)
    {
        require(index>=0&&index<ap4Finances[msg.sender].length);
        Apply4Finance storage ap = ap4Finances[msg.sender][index];
        emit getAp4FinanceRes(ap.tokenIndex,ap.amount,ap.applyer,ap.applyRate,ap.bank,ap.checked,ap.confirmed);
        return (ap.tokenIndex,ap.amount,ap.applyer,ap.applyRate,ap.bank,ap.checked,ap.confirmed);
    }
    
    
    event checkAp4FinanceRes(bool);
    function checkAp4Finance(uint256 index, bool confirm)
        public onlyBank returns(bool success)
    {
        if(!(index>=0&&index<ap4Finances[msg.sender].length)
            ||msg.sender!=ap4Finances[msg.sender][index].bank
            ||ap4Finances[msg.sender][index].checked
            ){
                emit checkAp4FinanceRes(false);
                return false;
            }
        Apply4Finance[] storage aps = ap4Finances[msg.sender];
        
        if(aps[index].expireDate<=now){
            aps[index]=aps[aps.length-1];
            aps.length--;
            emit checkAp4FinanceRes(false);
            return false;
        }
        aps[index].checked = true;
        if(confirm){
            Token storage token = tokens[aps[index].tokenIndex];
            if(token.amount<aps[index].amount)return false;
            token.amount -= aps[index].amount;
            //TODO:Token to cash
            cash[aps[index].applyer]+=aps[index].amount*aps[index].applyRate/10000;
            // if(msg.sender!=receipts[token.recIndex].bank){
            tokenOf[msg.sender].push(tokens.length);
            recTokens[token.recIndex].push(tokens.length);
            tokens.push(Token(token.recIndex,aps[index].amount,msg.sender,token.lender,token.returnTimestamp,false));
            // }
            aps[index]=aps[aps.length-1];
            aps.length--;
            emit checkAp4FinanceRes(true);
            return true;
        }
        else{
            emit checkAp4FinanceRes(false);
            return false;
        } 
            
    }
    
    
    event getCashRes(uint256);
    function getCash() public returns(uint256 cashAmount){
        emit getCashRes(cash[msg.sender]);
        return cash[msg.sender];
    }
    
}


