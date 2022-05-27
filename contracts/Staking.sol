

// SPDX-License-Identifier: CC-BY-SA-4.0

pragma solidity ^0.8.4;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";



contract StakeContract is ERC20 {



            event Withdrawal(address _to, uint208 amount, uint40 time);
            event AddStack(address _from, uint208 amount, uint40 time);
            
            struct Stake{
            uint40 timeStaked;
            uint208 amount;
            bool status;
        }  


         constructor() ERC20("EncodePolygonHack", "EPH"){
        _mint(msg.sender, (3000000*10**18));
        }


        mapping(address =>Stake ) public stakers;
        uint40 minStakeTime = 3 days;
        function stakeToken(uint208 _amount) external {
            require(balanceOf(msg.sender) >= _amount, "insuffient fund");
            transfer(address(this), _amount);
            Stake storage stake = stakers[msg.sender];
            if(stake.status == true){
                uint40 daysSpent = uint40(block.timestamp) - stake.timeStaked;
                if(daysSpent > minStakeTime){
                    uint208 reward = calculateReward(msg.sender);
                    stake.amount += reward;
                    stake.amount += _amount;
                    stake.timeStaked = uint40(block.timestamp);
                }
                else {
                    stake.amount += _amount;
                    stake.timeStaked = uint40(block.timestamp);
                }
            }
            else {
                stake.timeStaked = uint40(block.timestamp);
                stake.amount = _amount;
                stake.status = true;

            }
            emit AddStack(msg.sender, _amount, stake.timeStaked);
        }

   function withdraw(uint208 _amount) external {
         Stake storage stake = stakers[msg.sender];
        uint40 daysSpent = uint40(block.timestamp) - stake.timeStaked;
           require(_amount <= stake.amount, "Insufficient fund");

        if(daysSpent > minStakeTime){
        uint208 reward =  calculateReward(msg.sender);
           stake.amount +=   uint208(reward);
            stake.amount -=  uint208(_amount);
            stake.timeStaked = uint40(block.timestamp);
        }else{
        stake.amount = stake.amount - uint208(_amount);
        stake.timeStaked = uint40(block.timestamp);
        }
        _transfer(address(this),msg.sender, _amount);
        stake.timeStaked = uint40(block.timestamp);
        stake.amount > 0? stake.status = true : stake.status = false;
    emit Withdrawal(msg.sender, _amount, stake.timeStaked);
      
    } 

 uint40 rewardInSecond =2592000;
    
    function calculateReward(address _address) public view returns (uint208 reward){
       Stake storage stake  = stakers[_address];
        if (stake.status==false){
        return 0;
    }
       uint208 perMonth = (stake.amount * 10);
       uint40 time = uint40(block.timestamp) - stake.timeStaked;
       reward = uint208((perMonth * time* 1000) /(rewardInSecond));
    }


function getBalance() external view returns (uint){
Stake memory stake = stakers[msg.sender];
return stake.amount;
}

function getStakeDetailsByAddress(address _address) external view returns (Stake memory){
    Stake memory stake = stakers[_address];
    return stake;
}



}