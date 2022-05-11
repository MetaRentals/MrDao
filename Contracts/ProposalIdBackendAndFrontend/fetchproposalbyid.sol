//SPDX-License-Identifier: MIT
/* 
  * Generated by NinjaDB and Syd
  *  
  */ 
pragma solidity ^0.8.4;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";


contract ProposalId is ChainlinkClient {
  using Chainlink for Chainlink.Request;

  //tranfer events
  event TransferSent(address _from, address _destAddr, uint amount);
    
  //linkToken Address on KOVAN network
  address public immutable LinkToken;

  uint public link; 

  //amount of Link In Contract
  address payable public owner;  
  bytes public data;
  string public proposalId;
  uint256 public counter;

  struct proposal {
    string propId;
  }

  mapping(uint256 => proposal) public Proposals;

  constructor(address _linkToken) {
    LinkToken = _linkToken;
    owner = payable(msg.sender);
    setChainlinkToken(0xa36085F69e2889c224210F603D836748e7dC0088);
    setChainlinkOracle(0xd23cB7C9bDa53734ef4595F7a23398a85443246E);
  }
  

  
  function requestBytes() public
  {
    bytes32 specId = "ace3149ce96b42c08f9999be703d4517";
    uint256 payment = 50000000000000000;
    Chainlink.Request memory req = buildChainlinkRequest(specId, address(this), this.fulfillBytes.selector);
    req.add("get","https://hub.snapshot.org/graphql?operationName=Proposals&query=query%20Proposals%20%7B%0A%20%20proposals%20(%0A%20%20%20%20first%3A%2020%2C%0A%20%20%20%20skip%3A%200%2C%0A%20%20%20%20where%3A%20%7B%0A%20%20%20%20%20%20space_in%3A%20%5B%223.spaceshot.eth%22%5D%2C%0A%20%20%20%20%0A%20%20%20%20%7D%2C%0A%20%20%20%20orderBy%3A%20%22created%22%2C%0A%20%20%20%20orderDirection%3A%20desc%0A%20%20)%20%7B%0A%20%20%20%20id%0A%20%20%20%20title%0A%20%20%20%20body%0A%20%20%20%20choices%0A%20%20%20%20start%0A%20%20%20%20end%0A%20%20%20%20%0A%20%20%7D%0A%7D");
    req.add("path", "data,proposals,0,id");
    sendOperatorRequest(req, payment);
  }

  event RequestFulfilled(
    bytes32 indexed requestId,
    bytes indexed data
  );

  function fulfillBytes(
    bytes32 requestId,
    bytes memory bytesData
  )
    public
    recordChainlinkFulfillment(requestId)
  {
    emit RequestFulfilled(requestId, bytesData);
    data = bytesData;
    proposalId = iToHex(abi.encodePacked(data));
    bytes memory Alreadyexist = bytes(Proposals[counter].propId);
    require(Alreadyexist.length == 0);
      Proposals[counter].propId = proposalId;
      counter++;
    
  }




  
  function iToHex(bytes memory buffer) public pure returns (string memory) {

        // Fixed buffer size for hexadecimal convertion
        bytes memory converted = new bytes(buffer.length * 2);

        bytes memory _base = "0123456789abcdef";

        for (uint256 i = 0; i < buffer.length; i++) {
            converted[i * 2] = _base[uint8(buffer[i]) / _base.length];
            converted[i * 2 + 1] = _base[uint8(buffer[i]) % _base.length];
        }

        return string(abi.encodePacked("0x", converted));
    }

  
  function returnLinkBalance() view public returns(uint) { 
    return LinkTokenInterface(LinkToken).balanceOf(address(this));      
  }

    function getBalance() view public returns(uint) {
       return address(this).balance;

    }
      //Create A function to to Deposit Link into this function to make an API call 
    function transferERC20(ERC20 token, address to, uint256 amount) public { 
        //sending LINK to this contract 
        require(msg.sender == owner, "Only owner can withdraw funds");
        uint256 totalAmountOfLink = token.balanceOf(address(this));
        //Change Link State variable
        link = totalAmountOfLink;
        require(amount <= totalAmountOfLink, "balance is low ");
        token.transfer(to, amount);
        emit TransferSent(msg.sender,to, amount);
    }
    
    uint public balanceRecived;
    function deposit() public payable { 
      balanceRecived+= msg.value;
    }


    //function that returns the proposalID
    function returnProposalId() view public returns(string memory) { 
      return proposalId;
    }
    //function returns balanceo Link
  

    receive() external payable{}
    fallback() external payable{}
}