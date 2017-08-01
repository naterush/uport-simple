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
  event Claimed(bytes32 identifier, address owner, address recovery, bytes32 DDO);
  event OwnerChanged(bytes32 identifier, address newOwner);
  event DDOChanged(bytes32 identifier, bytes32 newDDO);
  event RecoveryChanged(bytes32 identifier, address newRecovery);

  uint generator;

  mapping (bytes32 => address) ownerOf;
  mapping (bytes32 => address) recoveryOf;
  mapping (bytes32 => bytes32) ddoOf;

  modifier onlyOwner(bytes32 identifier) {
    if (ownerOf[identifier] == msg.sender)  {_;}
    else throw;
  }

  modifier onlyRecovery(bytes32 identifier) {
    if (recoveryOf[identifier] == msg.sender) _;
    else throw;
  }

  function SimpleIdentity(uint startingValue) {
    generator = startingValue; //Should be a random number
  }

  //Equivalent of creating an identity.
  function claim(address owner, address recovery, bytes32 DDO) returns (bytes32 identifier) {
    generator++;
    identifier = sha3(generator); //sha3 is missleading. Should use kekkak256

    ownerOf[identifier] = owner;
    recoveryOf[identifier] = recovery;
    ddoOf[identifier] = DDO;

    Claimed(identifier, owner, recovery, DDO);
  }

  /*
    Owner Functions
  */

  //Update all at once. This allows for some nice gas savings using the pre-store trick
  function changeAll(bytes32 identifier, address owner, address recovery, bytes32 DDO)
    onlyOwner(identifier)
  {
    ownerOf[identifier] = owner;
    recoveryOf[identifier] = recovery;
    ddoOf[identifier] = DDO;

    OwnerChanged(identifier, owner);
    RecoveryChanged(identifier, recovery);
    DDOChanged(identifier, DDO);
  }

  function changeOwner(bytes32 identifier, address owner) onlyOwner(identifier)  {
    ownerOf[identifier] = owner;
    OwnerChanged(identifier, owner);
  }

  function changeRecovery(bytes32 identifier, address recovery) onlyOwner(identifier)  {
    recoveryOf[identifier] = recovery;
    RecoveryChanged(identifier, recovery);
  }

  function changeDDO(bytes32 identifier, bytes32 DDO) onlyOwner(identifier)  {
    ddoOf[identifier] = DDO;
    DDOChanged(identifier, DDO);
  }

  /*
    Recovery Functions
  */

  function changeOwnerAsRecovery(bytes32 identifier, address owner) {
    ownerOf[identifier] = owner;
    OwnerChanged(identifier, owner);
  }
}
