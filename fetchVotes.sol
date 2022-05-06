// SPDX-License-Identifier: MIT
/* 
  * Generated by NinjaDB
  *  
  */ 
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";
import "./getProposalId.sol";

contract SnapshotRequest is ChainlinkClient,ConfirmedOwner {
 using Chainlink for Chainlink.Request;

  uint256 constant private ORACLE_PAYMENT = 1 * LINK_DIVISIBILITY / 100 * 5;
  uint256 public noYays;
  uint256 public noNays;
  uint256 public noAbstenstions;
  bytes32 public lastRequestIdSent;
  bytes32 public lastRequestIdReceived;
  string public proposalIdURL;

  ProposalId proposalContract;
  
  string constant jobId = "8ebf12e2380f4a78afe3f74eac1d3f97";
  
  constructor(address _address) ConfirmedOwner(msg.sender){
    proposalContract = ProposalId(_address);  
    setChainlinkToken(0xa36085F69e2889c224210F603D836748e7dC0088);
    setChainlinkOracle(0xd23cB7C9bDa53734ef4595F7a23398a85443246E);
  }

       function concatenate(string memory a,string memory _proposalIdURL ,string memory b ,uint256 _id) public view returns (string memory){
        _proposalIdURL = proposalContract.Proposals(_id);
        return string(abi.encodePacked(a,' ',b));
    } 
 
  function requestVotes(uint256 _id)
    public
    onlyOwner
  { 
    proposalIdURL = proposalContract.Proposals(_id);
    string memory voteURL = string(abi.encodePacked("https://hub.snapshot.org/graphql?operationName=Votes&query=query%20Votes%20%7B%0A%20%20proposal%20(id%3A%20%22",proposalIdURL,"%22)%20%7B%0A%20%20%20%20scores%0A%20%20%20%20quorum%0A%20%20%7D%0A%7D%0A"));

    Chainlink.Request memory req = buildChainlinkRequest(stringToBytes32(jobId), address(this), this.fulfillVotes.selector);
    req.add("get", voteURL);
    lastRequestIdSent = sendOperatorRequest(req, ORACLE_PAYMENT);
  }

  event RequestFulfilledVotes(
    bytes32 requestId,
    uint256 indexed yays,
    uint256 indexed nays,
    uint256 indexed abstensions
  );

  function fulfillVotes(
    bytes32 requestId,
    uint256 _yays,
    uint256 _nays,
    uint256 _abstensions
  )
    public
    recordChainlinkFulfillment(requestId)
  {
    emit RequestFulfilledVotes(requestId, _yays, _nays, _abstensions);
    noYays = _yays;
    noNays = _nays;
    noAbstenstions = _abstensions;
  }

  function stringToBytes32(string memory source) private pure returns (bytes32 result) {
    bytes memory tempEmptyStringTest = bytes(source);
    if (tempEmptyStringTest.length == 0) {
      return 0x0;
    }

    assembly { // solhint-disable-line no-inline-assembly
      result := mload(add(source, 32))
    }
  }

}
