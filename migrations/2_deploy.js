const NotLoot = artifacts.require('NotLoot');
const Mana = artifacts.require('Mana');
const Crystals = artifacts.require('Crystals');
const CrystalsMetadata = artifacts.require('CrystalsMetadata');
const ManaCalculator = artifacts.require('CrystalManaCalculator');
const Rift = artifacts.require('Rift');
// const RiftQuests = artifacts.require('RiftQuests');
// const EnterRift = artifacts.require('EnterTheRift');

module.exports = function(deployer) {
  deployer.then(async () => {
    const notLoot = await deployer.deploy(NotLoot);
    const mana = await deployer.deploy(Mana);
    const rift = await deployer.deploy(Rift);
    const crystals = await deployer.deploy(Crystals, mana.address);
    const crystalsMeta = await deployer.deploy(CrystalsMetadata, crystals.address);
    const calculator = await deployer.deploy(ManaCalculator, crystals.address);
    // const riftQuests = await deployer.deploy(RiftQuests, rift.address);
    // const enterRift = await deployer.deploy(EnterRift, riftQuests.address, crystals.address, mana.address);

    mana.addController(crystals.address);
    mana.addController(rift.address);
    mana.ownerSetRift(rift.address);
    crystals.ownerSetMetadataAddress(crystalsMeta.address);
    crystals.ownerSetCalculatorAddress(calculator.address);
    crystals.ownerSetRiftAddress(rift.address);
    crystals.ownerSetLootAddress(notLoot.address);
    crystals.ownerSetMLootAddress(notLoot.address);
    rift.addRiftObject(crystals.address);
    rift.ownerSetLootAddress(notLoot.address);
    // rift.ownerSetRiftQuestsAddress(riftQuests.address);
    rift.addRiftQuest(crystals.address);
    rift.addRiftQuest(rift.address);
    // rift.addRiftQuest(riftQuests.address);
    rift.ownerSetManaAddress(mana.address);
    // riftQuests.addQuest(enterRift.address);

    // riftQuests.ownerSetXP(enterRift.address, 1, 2);
    // riftQuests.ownerSetXP(enterRift.address, 2, 2);
    // riftQuests.ownerSetXP(enterRift.address, 3, 2);

    // starting rift information
    rift.ownerSetXpRequirement(1, 100);
    rift.ownerSetXpRequirement(2, 150);
    rift.ownerSetXpRequirement(3, 225);
    rift.ownerSetXpRequirement(4, 350);
    rift.ownerSetXpRequirement(5, 525);

    rift.ownerSetLevelChargeAward(1, 2);
    rift.ownerSetLevelChargeAward(2, 3);
    rift.ownerSetLevelChargeAward(3, 1);
    rift.ownerSetLevelChargeAward(4, 1);
    rift.ownerSetLevelChargeAward(5, 2);
  });
}

// module.exports = function (deployer) {
//   return deployer.deploy(Mana)
//     .then((mana) => {
//       deployer.deploy(Crystals, mana.address)
//         .then((crystals) => {
//           mana.ownerSetCContractAddress(crystals.address);
//         });
//     });
  
//   // await deployer.deploy(Crystals, manaAddress);
// };
