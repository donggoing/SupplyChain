
pragma solidity ^0.4.4;

contract SupplyChain{
    
    struct Bank{
        string name;
        address _address;
        uint16 recommendRate;//financingRate*10000
    }
    
    struct CoreCompany{
        string name;
        address _address;
    }
    
    struct Company{
        string name;
        address _address;
    }
    
    struct Receivable{
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
    
    struct Token{
        uint256 recIndex;
        uint256 amount;
        address owner;
        address lender;
        uint256 returnTimestamp;
        bool hasSettled;
        // uint16 cashRate;
    }
    
    struct Apply4Withdraw{
        uint256 tokenIndex;
        uint256 amount;
        address applyer;
        address bank;
        bool checked;
        bool confirmed;
    }
    
    struct Apply4Finance{
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
    
    Receivable[] receivables;
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
    
    
    function SupplyChain() public {
        admin = msg.sender;
        curIndex = 0;
    }
    
    
    function getAllBanks()public view returns(address[] allbank){
        return bankAddresses;
    }
    
    function getAllCoreCompanys()public view returns(address[] coreCompany){
        return coreCompanyAddresses;
    }
    
    function getBank(address bankAddress)public isBank(bankAddress) view 
        returns(string name,uint16 recommendRate)
    {
        require(banks[bankAddress]>=0&&banks[bankAddress]<allbanks.length);
        Bank storage bank = allbanks[banks[bankAddress]];
        return (bank.name,bank.recommendRate);
    }
    
    function getCoreCompany(address compAddress)public isCoreCompany(compAddress) view 
        returns(string name)
    {
        require(coreCompanys[compAddress]>=0&&coreCompanys[compAddress]<allCoreCompanys.length);
        CoreCompany storage coreCompany = allCoreCompanys[coreCompanys[compAddress]];
        return (coreCompany.name);
    }
    
    function addBank(address _address, string _name) 
        public onlyAdmin returns(bool success)
    {
        if(allbanks.length!=0&&
            banks[_address]<allbanks.length&&
            allbanks[banks[_address]]._address==_address)
            return false;
        banks[_address] = allbanks.length;
        allbanks.push(Bank(_name,_address,8000));
        bankAddresses.push(_address);
        return true;
    }
    
    // function setRate(uint16 rate)
    //     public onlyBank returns(bool success)
    // {
    //     allbanks[banks[msg.sender]].recommendRate = rate;
    //     return true;
    // }
    
    function addCoreCompany(address _address, string _name) 
        public onlyAdmin returns(bool success) 
    {
        if(allCoreCompanys.length!=0&&
            coreCompanys[_address]<allCoreCompanys.length&&
            allCoreCompanys[coreCompanys[_address]]._address==_address
            )return false;
        coreCompanys[_address]=allCoreCompanys.length;
        allCoreCompanys.push(CoreCompany(_name,_address));
        coreCompanyAddresses.push(_address);
        return true;
    }
    
    function uploadReceivable(address _compAddress,address _bankAddress, uint256 amount, uint256 returnTimestamp)
        public isCoreCompany(_compAddress) isBank(_bankAddress) returns(bool success,uint256 receivableIndex)
    {
        uint256 current = now;
        if(current>returnTimestamp)return (false,0);
        receivables.push(Receivable(curIndex,_compAddress,msg.sender,_bankAddress,amount,current,returnTimestamp,false,false,false,false,false));
        unsignedRecMap[curIndex]=unsignedRec[_compAddress].length;
        unsignedRec[_compAddress].push(curIndex);
        allCoCompRec[_compAddress].push(curIndex);
        curIndex++;
        return (true,curIndex-1);
    }
    
    function getUnsignedRec()
        public onlyCoreCompany returns(uint256[] unsignedRecIndex)
    {
        return uint256[](unsignedRec[msg.sender]);
    }
    
    function signRec(uint256 index,bool confirm)
        public onlyCoreCompany returns(bool success)
    {
        if(receivables[index].borrower != msg.sender)
            return false;
        receivables[index].signed = true;
        if(confirm){
            receivables[index].confirmed = true;
            uint len = unsignedRec[msg.sender].length;
            uint i = unsignedRecMap[index];
            unsignedRec[msg.sender][i]= unsignedRec[msg.sender][len-1];
            unsignedRec[msg.sender].length--;
            
            pendingRecMap[index]=pendingRec[receivables[index].bank].length;
            pendingRec[receivables[index].bank].push(index);
        }
        allBankRec[receivables[index].bank].push(index);
    
        return true;
    }
    
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
            index<receivables.length
            );
        Receivable storage receivable = receivables[index];      
        // return receivable;
        return (index,receivable.borrower,
                receivable.lender,
                receivable.bank,
                receivable.amount,receivable.sTimeStamp,
                receivable.eTimeStamp,receivable.signed,
                receivable.confirmed,receivable.checkByBank,
                receivable.accepted,receivable.settled);
    }
    
    function getPendingRec()
        public onlyBank returns(uint256[] pendingRecIndex)
    {
        return uint256[](pendingRec[msg.sender]);
    }
    
    function acceptRec(uint256 index,bool accept)
        public onlyBank returns(bool success)
    {
        Receivable storage receivable = receivables[index];
        if(!receivable.confirmed||receivable.checkByBank||receivable.bank!=msg.sender)
            return false;
        receivable.checkByBank = true;
        if(accept){
            receivable.accepted = true;
            tokens.push(Token(index,receivable.amount,receivable.lender,msg.sender,receivable.eTimeStamp,false));
            tokenOf[receivable.lender].push(tokens.length-1);
            recTokens[index].push(tokens.length-1);
            unsettledRecMap[index]=unsettledRec[msg.sender].length;
            unsettledRec[msg.sender].push(index);
            pendingRec[msg.sender][pendingRecMap[index]] = pendingRec[msg.sender][pendingRec[msg.sender].length-1];
            pendingRec[msg.sender].length--;
        }
        return true;
    }
    
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
        return true;
    }
    
    function getAllToken()public returns(uint256[] tokenIndex){
        return uint256[](tokenOf[msg.sender]);
    }
    
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
        // return token;
        return (token.recIndex,receivables[token.recIndex].borrower,
                allCoreCompanys[coreCompanys[receivables[token.recIndex].borrower]].name,
                token.amount,token.returnTimestamp ,token.hasSettled);
    }
    
    function settleRec(uint256 index)
        public returns(bool success)
    {
        require(
            index>=0&&
            index<receivables.length&&
            msg.sender==receivables[index].bank
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
        return true;
    }
    
    function getNormCompRec()public returns(uint256 [] recIndex){
        return allNormCompRec[msg.sender];
    }
    
    function getAllUnsettledRec()
        public onlyBank returns(uint256[] unsettledRecIndex)
    {
        return unsettledRec[msg.sender];
    }
        
    // function getAllSettledRec()
    //     public onlyBank returns(uint256[] settledRecIndex)
    // {
    //     return settledRec[msg.sender];
    // }
    
    function applyWithdraw(uint256 index,uint256 amount)
        public returns(bool success)
    {
        if(!(index>=0&&
            index<tokens.length&&
            tokens[index].owner==msg.sender&&
            tokens[index].amount>=amount&&
            tokens[index].hasSettled&&
            now>=tokens[index].returnTimestamp
        ))return false;
        
        address bank = receivables[tokens[index].recIndex].bank;
        ap4Withdraws[bank].push(Apply4Withdraw(index,amount,msg.sender,bank,false,false));
        return true;
    }
    
    // function getAp4WithdrawLen()
    //     public onlyBank returns(uint256 applylen)
    // {
    //     return ap4Withdraws[msg.sender].length;
    // }
    
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
        return (ap.tokenIndex,ap.amount,ap.applyer,ap.bank,ap.checked,ap.confirmed);
    }
    
    function checkApp4Withdraw(uint256 index, bool confirm)
        public onlyBank returns(bool success)
    {
        if(!(index>=0&&index<ap4Withdraws[msg.sender].length)
            ||ap4Withdraws[msg.sender][index].bank!=msg.sender
            ||ap4Withdraws[msg.sender][index].checked)return false;
        Apply4Withdraw[] storage aps = ap4Withdraws[msg.sender];
        aps[index].checked = true;
        if(confirm){
            Token storage token = tokens[aps[index].tokenIndex];
            if(token.amount<aps[index].amount||!(token.hasSettled&&now>=token.returnTimestamp))
                return false;
            token.amount -= aps[index].amount;
            //TODO:Token to cash
            cash[token.owner]+=aps[index].amount;
            aps[index]=aps[aps.length-1];
            aps.length--;
            return true;
        }
        else return false;
    }
    
    function applyFinance(uint256 index,uint256 amount,address bank,uint16 rate)
        public returns(bool success)
    {
        if(index<0||
            index>=tokens.length||
            tokens[index].owner!=msg.sender||
            tokens[index].amount<amount||
            (tokens[index].hasSettled&&
            now>=tokens[index].returnTimestamp)
        )return false;
        
        ap4Finances[bank].push(Apply4Finance(index,amount,rate,msg.sender,bank,false,false,tokens[index].returnTimestamp));
        return true;
    }
    
    function getApLen()
        public onlyBank returns(uint256 financelen,uint256 withdrawlen)
    {
        return (ap4Finances[msg.sender].length,ap4Withdraws[msg.sender].length);
    }
    
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
        return (ap.tokenIndex,ap.amount,ap.applyer,ap.applyRate,ap.bank,ap.checked,ap.confirmed);
    }
    
    
    function checkApp4Finance(uint256 index, bool confirm)
        public onlyBank returns(bool success)
    {
        if(!(index>=0&&index<ap4Finances[msg.sender].length)
            ||msg.sender!=ap4Finances[msg.sender][index].bank
            ||ap4Finances[msg.sender][index].checked
            )return false;
        
        Apply4Finance[] storage aps = ap4Finances[msg.sender];
        
        if(aps[index].expireDate<=now){
            aps[index]=aps[aps.length-1];
            aps.length--;
            return false;
        }
        aps[index].checked = true;
        if(confirm){
            Token storage token = tokens[aps[index].tokenIndex];
            if(token.amount<aps[index].amount)return false;
            token.amount -= aps[index].amount;
            //TODO:Token to cash
            cash[aps[index].applyer]+=aps[index].amount*aps[index].applyRate/10000;
            // if(msg.sender!=receivables[token.recIndex].bank){
            tokenOf[msg.sender].push(tokens.length);
            recTokens[token.recIndex].push(tokens.length);
            tokens.push(Token(token.recIndex,aps[index].amount,msg.sender,token.lender,token.returnTimestamp,false));
            // }
            aps[index]=aps[aps.length-1];
            aps.length--;
            return true;
        }
        else return false;
    }
    
    
    function getCash() public returns(uint256 cashAmount){
        return cash[msg.sender];
    }
    
}


