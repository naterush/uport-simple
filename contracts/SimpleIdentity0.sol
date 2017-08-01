pragma solidity 0.4.11;

/*
Basic contract to allow for a user to control/recover a DDO
For reason for this contract, see here: https://consensys.quip.com/s7TsAYbkYxul

Assumptions:
1. Owner key is never compromised (same assumption as IdentityManager, though it has benefit
   that there may be multiple owners. Note, it is not secure w/ less than 3 owners).
2. Recovery may be compromised, but owner will realize within WAIT_TIME;
*/

contract SimpleIdentity {
  event Claimed(bytes32 identifier, address owner, bytes32 DDO);
  event OwnerChanged(bytes32 identifier, address newOwner);
  event DDOChanged(bytes32 identifier, bytes32 newDDO);

  uint generator;

  mapping (bytes32 => address) ownerOf;
  mapping (bytes32 => bytes32) ddoOf;


  modifier onlyOwner(bytes32 identifier) {
    if (ownerOf[identifier] == msg.sender)  {_;}
    else throw;
  }

  function SimpleIdentity(uint startingValue) {
    generator = startingValue; //Should be a random number
  }

  //Equivalent of creating an identity.
  function claim(address owner, bytes32 DDO) returns (bytes32 identifier) {
    generator++;
    identifier = sha3(generator); //sha3 is missleading. Should use kekkak256

    ownerOf[identifier] = owner;
    ddoOf[identifier] = DDO;

    Claimed(identifier, owner, DDO);
  }

  /*
    Owner Functions
  */

  function changeDDO(bytes32 identifier, bytes32 DDO) onlyOwner(identifier)  {
    ddoOf[identifier] = DDO;
    DDOChanged(identifier, DDO);
  }
}
