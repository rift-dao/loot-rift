const NotLoot = artifacts.require('NotLoot');
const Mana = artifacts.require('Mana');
const Crystals = artifacts.require('Crystals');
const CrystalsMetadata = artifacts.require('CrystalsMetadata');
const ManaCalculator = artifacts.require('CrystalManaCalculator');
const Rift = artifacts.require('Rift');
const RiftQuests = artifacts.require('RiftQuests');
const EnterRift = artifacts.require('EnterTheRift');

module.exports = function(deployer) {
  deployer.then(async () => {
    const notLoot = await deployer.deploy(NotLoot);
    const mana = await deployer.deploy(Mana);
    const rift = await deployer.deploy(Rift);
    const crystals = await deployer.deploy(Crystals, mana.address);
    const crystalsMeta = await deployer.deploy(CrystalsMetadata, crystals.address);
    const calculator = await deployer.deploy(ManaCalculator, crystals.address);
    const riftQuests = await deployer.deploy(RiftQuests, rift.address);
    const enterRift = await deployer.deploy(EnterRift, riftQuests.address, crystals.address, mana.address);

    mana.addController(crystals.address);
    mana.addController(rift.address);
    crystals.ownerSetMetadataAddress(crystalsMeta.address);
    crystals.ownerSetCalculatorAddress(calculator.address);
    crystals.ownerSetRiftAddress(rift.address);
    crystals.ownerSetLootAddress(notLoot.address);
    crystals.ownerSetMLootAddress(notLoot.address);
    rift.addRiftObject(crystals.address);
    rift.ownerSetLootAddress(notLoot.address);
    rift.ownerSetRiftQuestsAddress(riftQuests.address);
    rift.ownerSetManaAddress(mana.address);
    riftQuests.addQuest(enterRift.address);

    // starting rift information
    await rift.ownerSetXpRequirement(1, 100);
    await rift.ownerSetXpRequirement(2, 150);
    await rift.ownerSetXpRequirement(3, 225);
    await rift.ownerSetXpRequirement(4, 350);
    await rift.ownerSetXpRequirement(5, 525);

    await rift.ownerSetLevelChargeAward(1, 1);
    await rift.ownerSetLevelChargeAward(2, 1);
    await rift.ownerSetLevelChargeAward(3, 1);
    await rift.ownerSetLevelChargeAward(4, 1);
    await rift.ownerSetLevelChargeAward(5, 2);

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
