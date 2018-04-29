pragma solidity ^0.4.0;
 
contract ReviewSmartContract{
    
    address public reviewer; //address of current reviewer
    address SPEthereumAddress; //address of company
    address IPFS_Address; //address of IPFS 
    uint ReviewNumber;  //Review Number
    uint256 RewardAmount; //Amount to Reward to Reviewer
    
    
    
    mapping (address => uint256) Token; //Token number issued that allows user to write Review
    mapping (address => bytes) IPFSHash; //Store the IPFS Hash Of reviewer
    
    //Event Logs for debugging and information
    event LogDep (address sender,    uint amount, uint balance,string text);
    event LogSent(address recipient, uint amount, uint balance,string text);
    event LogErr (address recipient, uint amount, uint balance,string text);
    event TokenCreated(address reviewer,address ipfs ,uint256 tokenNo,string text);
    
    modifier onlySP{
        require(msg.sender == SPEthereumAddress);// Only allow company to have access
        _;
    }
    
    modifier onlyIPFS{
        require(msg.sender == IPFS_Address);// Only allows IPFS server to have access
        _;
    }
    function SetIPFSaddress(address _IPFSaddress) onlySP
    {   //set the IPFS Ethereum address 
        IPFS_Address = _IPFSaddress;
    }
    
    
    function ReviewSmartContract(){ //Constructor
        SPEthereumAddress=msg.sender; //address of contract creator as the company
        ReviewNumber=0;//initialize ReviewNumer to 0
        IPFS_Address = 0x14723a09acff6d2a60dcdf7aa4aff308fddc160c;
        RewardAmount = 1 ether; //
    }
    
    
    function showBalance() public returns(uint256){
        return this.balance; //shows current balance in the smart contract
    }
    
    function showaddress() public returns(address){
        return msg.sender; //shows current balance in the smart contract
    }
    
    function depositFunds() public payable onlySP returns(bool success){
            //deposit funds into the smart contract 
            LogDep(msg.sender, msg.value, this.balance,"Funds added"); 
            return true;
        
    }
    
    function IssueToken(address _reviewer) onlySP returns(uint256){
        //Issues a Token for Reviewer based on his Ethereum Address
        require(this.balance>=RewardAmount && Token[_reviewer]==0x0);
        //condition to check if there is balance available and users EA has no token assigned to it
         uint256 tokenNum=uint256(keccak256(block.timestamp,_reviewer,ReviewNumber));
         
         Token[_reviewer]=tokenNum;
         
         TokenCreated(_reviewer,IPFS_Address,tokenNum,"Token created");
        
         return tokenNum;
            
        
    }
    
    
    
    function reviewDone(address _reviewer,bytes _ipfshash,uint256 tokenNum) payable onlyIPFS{
        if(Token[_reviewer]==tokenNum && Token[_reviewer]!=0)
        {
            IPFSHash[_reviewer]=_ipfshash;
            Token[_reviewer]=0;//remove token from user(Set to 0)
            reward(_reviewer);
            LogSent(_reviewer, RewardAmount, this.balance,"reviewer rewarded");
            ReviewNumber++;
            
        }
    }
    
  function reward(address _reviewer) onlyIPFS payable{
        //perform reward function
        require(this.balance >= RewardAmount);
        if(_reviewer.send(RewardAmount))
        {
                LogSent(_reviewer, RewardAmount, this.balance,"reviewer rewarded");
        }
        else{
                LogErr(_reviewer, RewardAmount, this.balance,"error");
        }
    }
        
    
}
