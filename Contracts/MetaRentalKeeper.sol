// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// KeeperCompatible.sol imports the functions from both ./KeeperBase.sol and
// ./interfaces/KeeperCompatibleInterface.sol
import "@chainlink/contracts/src/v0.8/KeeperCompatible.sol";
import "./getProposalId.sol";
import "./test.sol";

abstract contract MetaKeeper is KeeperCompatibleInterface ,ProposalId , SnapshotRequest{
    /**
    * Public counter variable
    */
    // uint public counter;
    /**
    * Use an interval in seconds and a timestamp to slow execution of Upkeep
    */
    uint public immutable interval;
    uint public lastTimeStamp;
    // uint256 public end;
    string public lastproposal;
    string public newproposal;
    ProposalId proposalcontract;
    SnapshotRequest fetchVotesContract;

    constructor(uint updateInterval) ConfirmedOwner(msg.sender){
      interval = updateInterval;
      lastTimeStamp = block.timestamp;
      proposalcontract = ProposalId(0xDbF65eFC02C9202435220888412a57aa608CE65B);
      fetchVotesContract = SnapshotRequest(0x2318D30CdE5f70404D73344A5d43fA21C74c27B6);
      counter = 0;
    }
  

    function checkUpkeep(bytes calldata checkData ) external override returns (bool upkeepNeeded, bytes memory performData) {
        upkeepNeeded = (block.timestamp - lastTimeStamp) > interval;
        proposalcontract.requestBytes();
        newproposal = proposalcontract.proposalId();
        lastproposal = Proposals[counter].propId;
        bytes memory checknew = bytes(newproposal);
        bytes memory checklast =bytes(lastproposal);
        if(keccak256(checknew) != keccak256(checklast)){
          upkeepNeeded=true;
        }
        
        performData = checkData;
    }

    function performUpkeep(bytes calldata performData ) external override {
        //We highly recommend revalidating the upkeep in the performUpkeep function
        if ((block.timestamp - lastTimeStamp) > interval ) {
            lastTimeStamp = block.timestamp;
            fetchVotesContract.requestVotes();
            

        }
        performData;
        // We don't use the performData in this example. The performData is generated by the Keeper's call to your checkUpkeep function
    }
}
