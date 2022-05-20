//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "@openzeppelin/contracts/utils/Strings.sol";
import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";

/**
 * @notice DO NOT USE THIS CODE IN PRODUCTION. This is an example contract.
 */
contract GetMultiArray is ChainlinkClient {
  using Chainlink for Chainlink.Request;

  // variable bytes returned in a signle oracle response
  uint256[] public timestamps;
  bytes[] public proposalIdBytes;
  uint256 public noProposals;
  uint256 constant private ORACLE_PAYMENT = 1 * LINK_DIVISIBILITY / 100 * 5;
  string constant jobId = "a17f264414784ef0a3a2be850f3db462"; // MUMBAI
  uint256 public tstmp =1652998021;

  constructor(
  ) {

    // MUMBAI
    setChainlinkToken(0x326C977E6efc84E512bB9C30f76E30c160eD06FB);
    setChainlinkOracle(0x1314E350Fc5a3896E2d66C43A83D9391E914a004);

  }

  /**
   * @notice Request variable bytes from the oracle
   */
  function requestInfo()
    public
  {
    string memory dernierTimestamp = Strings.toString(tstmp);
    string memory url= string(abi.encodePacked("https://mrkeeper.herokuapp.com/",dernierTimestamp));
    Chainlink.Request memory req = buildChainlinkRequest(stringToBytes32(jobId), address(this), this.fulfillInfo.selector);
    req.add("get", url);
    req.add("proposalsCountPath", "NewProposals");
    req.add("proposalsIdPath", "proposalsId");
    req.add("expireTimeStampPath", "expireTimeStamp");
    sendOperatorRequest(req, ORACLE_PAYMENT);
  }

  event RequestFulfilled(
    bytes32 indexed requestId,
    uint256 indexed noProposals,
    uint256[] indexed timestamps
  );

    // bytes[] memory bytesData
  function fulfillInfo(
    bytes32 requestId,
    uint256 _noProposals,
    uint256[] memory _timestamps,
    bytes[] memory _proposalIdBytes
  )
    public
    recordChainlinkFulfillment(requestId)
  {
    emit RequestFulfilled(requestId, _noProposals, _timestamps);
    timestamps = _timestamps;
    noProposals = _noProposals;
    proposalIdBytes = _proposalIdBytes;
    tstmp = timestamps[0];
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

  function proposalIdByteValues() public view returns (bytes[] memory) {
      return proposalIdBytes;
  }

  function timestampValues() public view returns (uint256[] memory) {
      return timestamps;
  }
}
