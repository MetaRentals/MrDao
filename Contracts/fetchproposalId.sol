//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "https://github.com/smartcontractkit/chainlink/blob/develop/contracts/src/v0.8/ChainlinkClient.sol";
// import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";


contract ProposalId is ChainlinkClient {
  using Chainlink for Chainlink.Request;

  bytes public data;
  string public proposalId;
  
  constructor() {
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
}
