// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";

contract SnapshotRequest is ChainlinkClient, ConfirmedOwner {
  using Chainlink for Chainlink.Request;

  uint256 constant private ORACLE_PAYMENT = 1 * LINK_DIVISIBILITY / 100 * 5;
  uint256 public noYays;
  uint256 public noNays;
  uint256 public noAbstenstions;
  bytes32 public lastRequestIdSent;
  bytes32 public lastRequestIdReceived;

  string constant jobId = "8ebf12e2380f4a78afe3f74eac1d3f97";

  constructor() ConfirmedOwner(msg.sender){
    setChainlinkToken(0xa36085F69e2889c224210F603D836748e7dC0088);
    setChainlinkOracle(0xd23cB7C9bDa53734ef4595F7a23398a85443246E);
  }

  function requestVotes(string memory _voteURL)
    public
    onlyOwner
  {
    Chainlink.Request memory req = buildChainlinkRequest(stringToBytes32(jobId), address(this), this.fulfillVotes.selector);
    req.add("get", _voteURL);
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
