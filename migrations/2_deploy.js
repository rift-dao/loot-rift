const { deployProxy } = require('@openzeppelin/truffle-upgrades');
const NotLoot = artifacts.require('NotLoot');
const Mana = artifacts.require('Mana');
const Crystals = artifacts.require('Crystals');
const CrystalsMetadata = artifacts.require('CrystalsMetadata');
const ManaCalculator = artifacts.require('CrystalManaCalculator');
const Rift = artifacts.require('Rift');
const RiftData = artifacts.require('RiftData');
// const RiftQuests = artifacts.require('RiftQuests');
// const EnterRift = artifacts.require('EnterTheRift');

module.exports = function(deployer) {
  deployer.then(async () => {
    const notLoot = await deployer.deploy(NotLoot);
    const riftData = await deployProxy(RiftData, { deployer });
    const mana = await deployer.deploy(Mana);
    const crystals = await deployProxy(Crystals, [mana.address], { deployer });
    const rift = await deployProxy(Rift, [notLoot.address, notLoot.address, notLoot.address], { deployer });
    const crystalsMeta = await deployer.deploy(CrystalsMetadata, crystals.address);
    const calculator = await deployer.deploy(ManaCalculator, crystals.address);
    // const riftQuests = await deployer.deploy(RiftQuests, rift.address);
    // const enterRift = await deployer.deploy(EnterRift, riftQuests.address, crystals.address, mana.address);

    mana.addController(crystals.address);
    mana.addController(rift.address);
    mana.ownerSetRift(rift.address);
    riftData.addRiftController(rift.address);
    crystals.ownerSetMetadataAddress(crystalsMeta.address);
    crystals.ownerSetCalculatorAddress(calculator.address);
    crystals.ownerSetRiftAddress(rift.address);
    rift.addRiftObject(crystals.address);
    rift.ownerSetRiftData(riftData.address);
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
    rift.ownerSetXpRequirement(1, 65);
    rift.ownerSetXpRequirement(2, 130);
    rift.ownerSetXpRequirement(3, 260);
    rift.ownerSetXpRequirement(4, 300);
    rift.ownerSetXpRequirement(5, 345);
    rift.ownerSetXpRequirement(6, 400);
    rift.ownerSetXpRequirement(7, 460);
    rift.ownerSetXpRequirement(8, 530);
    rift.ownerSetXpRequirement(9, 600);

    rift.ownerSetLevelChargeAward(1, 1);
    rift.ownerSetLevelChargeAward(2, 2);
    rift.ownerSetLevelChargeAward(3, 2);
    rift.ownerSetLevelChargeAward(4, 1);
    rift.ownerSetLevelChargeAward(5, 2);
    rift.ownerSetLevelChargeAward(6, 1);
    rift.ownerSetLevelChargeAward(7, 1);
    rift.ownerSetLevelChargeAward(8, 2);
    rift.ownerSetLevelChargeAward(9, 1);
    rift.ownerSetLevelChargeAward(10, 3);

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
