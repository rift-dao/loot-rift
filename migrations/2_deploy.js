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
    const crystals = await deployer.deploy(Crystals, mana.address, rift.address);
    const crystalsMeta = await deployer.deploy(CrystalsMetadata, crystals.address);
    const calculator = await deployer.deploy(ManaCalculator, crystals.address);
    const rift = await deployer.deploy(Rift);
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
    riftQuests.addQuest(enterRift.address);
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
