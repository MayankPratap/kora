pragma solidity 0.4.21;
pragma experimental "v0.5.0";
pragma experimental ABIEncoderV2; 

import "./SafeMathLib.sol";

// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
// ----------------------------------------------------------------------------
contract ERC20Interface {

    function totalSupply() public view returns (uint256) {}
    function balanceOf(address) public view returns (uint256) {}
    function transfer(address, uint256) public returns (bool) {}
    function transferFrom(address, address, uint256) public returns (bool) {}
    function approve(address, uint256) public returns (bool) {}
    function allowance(address, address) public view returns (uint256) {}
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}





// ----------------------------------------------------------------------------
// ERC20 Token, with the addition of symbol, name and decimals and assisted
// token transfers
// ----------------------------------------------------------------------------
contract coin is ERC20Interface {
   
    using SafeMath for uint256; 

    address public owner; 
    bytes32 public symbol;
    bytes32 public  name;
    uint8 public decimals;
    uint64 public totalSupply;
    uint64 public totalCoinPower;
    uint64 public TVA;
    //uint public questions;
    //uint public answers;

    uint64 public LDCR;
    uint64 public LDVA;

    struct ans_instance {
        
        uint16 upvotes;
        uint16 downvotes;
        uint8 reaction;
        bytes32 ansId;
    }


    /*
    struct que_instance {

        bool follow;
        uint32 followers; 
        bytes32 queId; 
    };  

    */
    
    
    struct Answer{
        address author;
        uint16 upvotes;
        uint16 downvotes;
        uint64 coinsMade;   // frontend me moti k form me
        uint64 lastModificationTimestamp;
        uint64 creationTimestamp;
        uint64 vaa;         //  value addition of answer
        bytes32 ansId;      // ansId will be same as initial hash 
        bytes32 ans_hash;   // ans_hash will change if edit 
        bytes32 queId;
        bool isValid;     // to check if answer is valid
        
        
    }
    
    struct  Question{
        address author;
        uint32 followers;
        uint64 coinsMade;
        uint64 lastModificationTimestamp;
        uint64 creationTimestamp;
        bytes32 queId;
        bytes32 que_hash;
        mapping ( bytes32 => Answer ) answers; //ans_id---ans_hash
        bytes32[] answerIndex;   // A list of answer indexes to enumerate keys of the above mapping 
        bool isValid;       // to check if answer is valid 

    }
    
     struct redeem_token {
        uint8 no_of_redeems; 
        uint8 span_over_weeks;//last_time_redeem
        uint64 amount; 
        uint64 time_of_redeem; //time of power_down
        
    }

    
    struct Profile{

        uint64 coinPower;
        uint64 vau;
        uint64 lastSettlementTimestamp;
        uint64 coins;
        uint8 ipower;
        
        mapping (bytes32 => ans_instance ) answersReacted;   // key : answerId and value: is bande k reaction
        bytes32[] answersReactedIndex;                       // A list of keys to enumerate above mapping 
        mapping (bytes32 => Answer) answersWritten;          // key : answerId and value: Answer struct
        bytes32[] answersWrittenIndex;                    
        mapping (bytes32 => Question ) ques;              // key : questionId and value : is bande k Question ki information 
        bytes32[] questionsIndex;                            // A list of keys to enumerate above mapping 
        bytes32 userName;  
        redeem_token[] redeems;
        
    }

 
    mapping (address => Profile) public users;
    mapping (bytes32 => Question) public questions;  // Overall questions key : quesId and value : Question object

    bytes32[] public questionsIndex;            // Index for above mapping
    
    Answer[] public allAnswers; 
    
    mapping( bytes32 => Answer) answerMapping; 

    
    // 1- Ans
    // 2- Que
    // 3- upvote
    // 4- downvote
    // 5- follow
    mapping(uint8 => uint8) public work_done;
   
    
    mapping(address => mapping(address => uint256)) allowed;



    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    function coin() public {
        
        owner = msg.sender;
        symbol = "coin";
        name = "coin Token";
        decimals = 8;
        LDCR = 10**9;
        LDVA = 10**4; 
        
        work_done[1] = 20;
        work_done[2] = 10;
        work_done[3] = 1;
        work_done[4] = 1;
        work_done[5] = 1;
        
        

        totalSupply = 10000000000000000;
        users[msg.sender].coins=totalSupply;     // Give all initial token to contract creator
        emit Transfer(address(0), msg.sender, totalSupply);
        
    }


    // ------------------------------------------------------------------------
    // Total supply
    // ------------------------------------------------------------------------
    function totalSupply() public view returns (uint256) {
        //return totalSupply - users[address(0)].coins;
        return uint256(totalSupply).sub(users[address(0)].coins);
    }


    // ------------------------------------------------------------------------
    // Get the token balance for account tokenOwner
    // ------------------------------------------------------------------------
    function balanceOf(address tokenOwner) public view returns (uint256) {
        return users[tokenOwner].coins;
    }


    // ------------------------------------------------------------------------
    // Transfer the balance from token owner's account to to account
    // - Owner's account must have sufficient balance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transfer(address to, uint256 tokens) public returns (bool) {

        tokens=uint64(tokens);

        if(users[msg.sender].coins >= tokens && tokens> 0){
            users[msg.sender].coins = uint64(uint256(users[msg.sender].coins).sub(uint256(tokens)));
            users[to].coins = uint64(uint256(users[to].coins).add(uint256(tokens)));
            emit Transfer(msg.sender, to, tokens);
            return true;
        }else {
            return false;
        }
    }


    // ------------------------------------------------------------------------
    // Token owner can approve for spender to transferFrom(...) tokens
    // from the token owner's account
    //
    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
    // recommends that there are no checks for the approval double-spend attack
    // as this should be implemented in user interfaces 
    // ------------------------------------------------------------------------
    function approve(address spender, uint256 tokens) public returns (bool) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }


    // ------------------------------------------------------------------------
    // Transfer tokens from the from account to the to account
    // 
    // The calling account must already have sufficient tokens approve(...)-d
    // for spending from the from account and
    // - From account must have sufficient balance to transfer
    // - Spender must have sufficient allowance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transferFrom(address from, address to, uint256 tokens) public returns (bool) {
        users[from].coins = uint64(uint256(users[from].coins).sub(tokens));
        allowed[from][msg.sender] = uint64(uint256(allowed[from][msg.sender]).sub(tokens));
        users[to].coins = uint64(uint256(users[to].coins).add(tokens));
        emit Transfer(from, to, tokens);
        return true;
    }


    // ------------------------------------------------------------------------
    // Returns the amount of tokens approved by the owner that can be
    // transferred to the spender's account
    // ------------------------------------------------------------------------
    function allowance(address tokenOwner, address spender) public view returns (uint256) {
        return allowed[tokenOwner][spender];
    }


    // ------------------------------------------------------------------------
    // Token owner can approve for spender to transferFrom(...) tokens
    // from the token owner's account. The spender contract function
    // receiveApproval(...) is then executed
    // ------------------------------------------------------------------------
    

    // ------------------------------------------------------------------------
    // Don't accept ETH
    // ------------------------------------------------------------------------
    function () external payable {
        revert();
    }


    // ------------------------------------------------------------------------
    // Owner can transfer out any accidentally sent ERC20 tokens
    // ------------------------------------------------------------------------
    function transferAnyERC20Token(address tokenAddress, uint256 tokens) public returns (bool) {
        
        require(msg.sender == owner);
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
    
    function addUserDetails(bytes32 name) public returns (bool){ // This function needs more working ...  
        
        //require(msg.sender==user);  // Check if one who called this function is the user himself otherwise anyone will call 
        users[msg.sender].ipower=100;           
        users[msg.sender].userName=name;  
        return true;
    }

    function valueAddition (uint8 work, uint8 ipower) public pure returns(uint64)  {
        return uint64(uint256(work).mul(ipower));
    }

    
    

   function VAU(address user, uint8 work) public returns(uint64){
        uint64 cp = users[user].coinPower;
        uint64 offset = 10**16;
        uint64 num = uint64(uint256(offset).mul(uint256(valueAddition(work, users[user].ipower)).mul(cp))); 
        totalCoinPower = 10;    // temp 
        uint64 vau = uint64(uint256(num).div(totalCoinPower));
        users[user].vau = uint64(uint256(users[user].vau).add(vau));
        return vau;
    }
    
    function VAU2(address user, uint16 diff) public returns(uint256){ 
        
        uint64 cp = users[user].coinPower;
        uint64 offset = 10**16;
        uint64 num = uint64(uint256(offset).mul(uint256(diff).div(10).mul(cp))); 
        totalCoinPower = 10;    // temp 
        uint64 vau = uint64(uint256(num).div(totalCoinPower));
        users[user].vau = uint64(uint256(users[user].vau).add(vau));
        TVA = uint64(uint256(TVA).add(vau));
        return vau;
        
    }
    
    function diffInWeeks(uint64 time1, uint64 time2) public pure returns (uint64) {
        
        uint64 diff = uint64(uint256(time2).sub(time1));   // diff is in milliseconds
        require(diff>0);
        
        uint64 weeksDiff = uint64(uint256(diff).div(1000*84600*7));  
          
        return weeksDiff;     
        
        
        
    }

    function TVAupdate(address user, uint8 work) public returns(uint64){
        uint64 val=VAU(user, work);
        TVA = uint64(uint256(TVA).add(val));
        return val; 
    }


    function userRefresh() public{
        
        
        //coin power refresh
        address banda = msg.sender;
        uint64 coins = 0; 
        redeem_token[] storage rd = users[banda].redeems;
        uint i;   // iterator
        for(i=0; i<rd.length; i++)
        {
            coins = uint64(uint256(coins).add(uint64(uint256(rd[i].amount).mul(uint256(diffInWeeks(rd[i].time_of_redeem, uint64(now))).div(rd[i].span_over_weeks)))));
        }
        //users[banda].coinPower -= coins;
        users[banda].coinPower = uint64(uint256(users[banda].coinPower).sub(coins));
        //totalCoinPower -= coins;
        totalCoinPower = uint64(uint256(totalCoinPower).sub(coins));
        //users[banda].coins += coins;
        users[banda].coins = uint64(uint256(users[banda].coins).add(coins));
        
        //vote profit
        for(i=0; i< users[msg.sender].answersReactedIndex.length;++i){
            
            ans_instance storage ai = users[msg.sender].answersReacted[users[msg.sender].answersReactedIndex[i]];
            
            Answer storage answer = answerMapping[users[msg.sender].answersReactedIndex[i]];
            
            uint16 diffUpvotes;
            uint16 diffDownvotes;
            
            if(ai.reaction == 3){
                
                diffUpvotes = uint16(uint256(answer.upvotes).sub(ai.upvotes)); // assuming latest answer updates will be >= upvotes in a reaction 
                VAU2(msg.sender, diffUpvotes);
                
                
            }else if(ai.reaction == 4){
                
                diffDownvotes = uint16(uint256(answer.downvotes).sub(ai.downvotes));
                VAU2(msg.sender, diffDownvotes);
                
            }
            
            ai.upvotes = answer.upvotes; 
            ai.downvotes = answer.downvotes; 
            
            
        
        }
        
        
    }

     function coinRelease () view internal returns(uint64 coins) {
        uint64 activity_change = uint64(uint256(LDCR).mul(totalSupply).mul(uint256(TVA).sub(LDVA)).div(LDVA).add(uint256(LDCR).mul(totalSupply)));
        uint64 vad = uint64(uint256(activity_change).div(1000000000000000));
        if(vad >= 10000000000 ){
            
            return 10000000000;
            
        }else{
            
            return vad;  
        }
        
    }
    
    

      function power_up (uint64 coins) public returns(bool res) {
        if(users[msg.sender].coins >= coins){
            users[msg.sender].coins = uint64(uint256(users[msg.sender].coins).sub(coins));
            users[msg.sender].coinPower = uint64(uint256(users[msg.sender].coinPower).add(coins));
            totalCoinPower = uint64(uint256(totalCoinPower).add(coins));
            return true;
        }
        else
            return false;
       }

      function power_down (uint64 coinPower) public returns(bool res)  {
        if(users[msg.sender].coinPower >= coinPower){
            redeem_token memory rd;
            rd.amount = coinPower;
            rd.span_over_weeks = 20;
            rd.time_of_redeem = uint64(now);
            rd.no_of_redeems = 0;
            users[msg.sender].redeems.push(rd);
        }else
            return false;                       
     }

      function NoteReactionAns(bytes32 queId, bytes32 ansId, uint8 reaction) public {
        //NoteReaction
        //va for author if upvote
        // va to user
        require(questions[queId].isValid == true);

        Question storage q = questions[queId];

        require(q.answers[ansId].isValid == true);
    
        Answer storage ans = q.answers[ansId];

        require(users[msg.sender].answersReacted[ansId].reaction == 0 ); 

        //ans.vaa += TVAupdate(msg.sender, work_done[reaction]);

        ans.vaa = uint64(uint256(ans.vaa).add(TVAupdate(msg.sender, work_done[reaction])));

        if(reaction == 3)
            ans.upvotes++;
        if(reaction == 4)
            ans.downvotes++;
        
        ans_instance memory ai;

        ai.reaction = reaction;
        ai.upvotes = ans.upvotes;
        ai.downvotes = ans.downvotes;
        ai.ansId = ansId; 

        users[msg.sender].answersReacted[ansId]=ai; 
        
        if (reaction == 3){  //upvote and follow award money to author 
            //ans.vaa += TVAupdate(ans.author, reaction);
            ans.vaa = uint64(uint256(ans.vaa).add(TVAupdate(ans.author, reaction)));
        }
      }
      
      /*

     function NoteReactionQue(uint8 queId, uint8 reaction){
        //NoteReaction
        //va for author if upvote
        // va to user
        TVAupdate(msg.sender, reaction);
        if (reaction == 5){  //upvote and follow award money to
            TVAupdate([ansId].author, reaction);
        }
     }  */
 
    function addQuestion(bytes32 _hash) public returns (bool){

        Question memory q;
        q.author = msg.sender; 
        q.lastModificationTimestamp = uint64(now);
        q.creationTimestamp = uint64(now); 
        q.queId = _hash;     // ipfs hash on adding question to ipfs 
        q.que_hash = _hash;   // Current hash may be after edits  
        q.isValid=true; 

        questionsIndex.push(_hash);
        questions[_hash]=q; 
        TVAupdate(msg.sender, work_done[2]); 
        return true;
        
    }

    function addAnswer(bytes32 _queId, bytes32 _hash) public {  //  Give question id as input 

        require(questions[_queId].isValid == true);     // Check if this question exist 

        Answer memory answer;

        answer.author=msg.sender;
        answer.lastModificationTimestamp = uint64(now);
        answer.creationTimestamp = uint64(now); 
        answer.ans_hash = _hash;
        answer.ansId = _hash; 
        answer.queId = _queId; 
        answer.isValid = true; 

        questions[_queId].answerIndex.push(_hash);
        questions[_queId].answers[_hash] = answer; 
        
        allAnswers.push(answer);
        answerMapping[_hash]=answer; 
        
        TVAupdate(msg.sender, work_done[1]);
        
        


    }

    function followQuestion(bytes32 _queId) public{    // We only need the question id to follow

        require(questions[_queId].isValid == true);     // Check if this question exist 
        Question storage question = questions[_queId];
        //question.followers +=1;
        question.followers = uint32(uint256(question.followers).add(1));
        
    }

    function updateQuestion(bytes32 _queId, bytes32 _hash) public {

        require(questions[_queId].isValid==true);     // Check if this question exist       
        Question storage question = questions[_queId];
        require(question.author == msg.sender);   // If msg.sender is the author of this question 
        question.que_hash = _hash;
        question.lastModificationTimestamp = uint64(now); 
        
    }

    function updateAnswer(bytes32 _queId, bytes32 _ansId, bytes32 _hash) public{

        require(questions[_queId].isValid == true);     // Check if this question exist  

        Question storage question = questions[_queId];

        require(question.answers[_ansId].isValid == true);   // It means this answer belongs to this question 

        Answer memory answer = question.answers[_ansId];  

        require(answer.author == msg.sender);

        answer.ans_hash = _hash;  
        answer.lastModificationTimestamp = uint64(now);

        question.answers[_ansId]=answer; 

    }

    function getTrendingAnswersLength() public constant returns (uint){

        return allAnswers.length;

    }
    

}

