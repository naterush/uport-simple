const SimpleIdentity = artifacts.require("./SimpleIdentity.sol")

const WAIT_TIME = 100;
const startingValue = 1000;

contract('SimpleIdentity', function(accounts) {
  var simpleIdentity
  var userPlaceholder
  var user1
  var user2
  var recoveryPlaceholder
  var recovery
  var newRecovery
  var bytesPlaceholder
  var bytes
  var newBytes

  beforeEach(() => {
    userPlaceholder     = accounts[0]
    user1               = accounts[1]
    user2               = accounts[2]
    recoveryPlaceholder = accounts[3]
    recovery            = accounts[4]
    newRecovery         = accounts[5]
    bytesPlaceholder    = "0xaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    bytes               = "0xabaabaaaaaaaaaaaaaaaaaaaaabaaaaaaaaaaaaaaaaaaaaabbaaaaaaaaaabaaa"
    newBytes            = "0xaaxxxxxxxxaaaaaaaaaaaaaaaaaaaaaaaaaavvvvvvvaaaaaaaaaaaaaaaaaaaaa"
    return SimpleIdentity.new(startingValue, WAIT_TIME).then((instance) => {
      simpleIdentity = instance
    })
  })

  it("should deploy allow a claim", function() {
    var identifier
    return simpleIdentity.claim(userPlaceholder, recoveryPlaceholder, bytesPlaceholder).then(tx => {
      let log = tx.logs[0]
      assert.equal(log.event, "Claimed", "Wrong event")
      identifier = log.args.identifier
      assert.equal(log.args.owner, userPlaceholder, "Wrong Owner")
      assert.equal(log.args.recovery, recoveryPlaceholder, "Wrong Recovery")
      assert.equal(log.args.DDO, bytesPlaceholder, "Wrong DDO")
      console.log("Gas used by initial tx", tx.receipt.gasUsed)
      return simpleIdentity.changeAll(identifier, user1, recovery, bytes)
    }).then(tx => {
      let log = tx.logs[0]
      assert.equal(log.event, "Claimed", "Wrong event")
      assert.equal(log.args.owner, user1, "Wrong Owner")
      assert.equal(log.args.recovery, recovery, "Wrong Recovery")
      assert.equal(log.args.DDO, bytes, "Wrong DDO")
      console.log("Gas used by next tx", tx.receipt.gasUsed)
    })
  })
})
