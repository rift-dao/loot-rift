const { deployProxy, upgradeProxy } = require('@openzeppelin/truffle-upgrades');
// const Mana = artifacts.require('Mana');
const Crystals = artifacts.require('Crystals');
// const CrystalsMetadata = artifacts.require('CrystalsMetadata');
const Rift = artifacts.require('Rift');
const RiftData = artifacts.require('RiftData');
// const RiftQuests = artifacts.require('RiftQuests');
// const EnterRift = artifacts.require('EnterTheRift');

module.exports = function(deployer) {
  deployer.then(async () => {
    await upgradeProxy('0xD65a69C01a5Fe2486B1AB96010b19609a940f0a1', RiftData, { deployer });
    await upgradeProxy('0xE1603e8a45D62e3B94306E2659b33a0811B30234', Crystals,  { deployer });
    await upgradeProxy('0x896F8c7fA07D2Cd1e7afa002F25D27B79ec3BDC7', Rift, { deployer });

    // const riftData = await deployProxy(RiftData, { deployer });
    // const mana = await deployer.deploy(Mana);
    // const crystals = await deployProxy(Crystals, [mana.address, riftData.address], { deployer });
    // const rift = await deployProxy(Rift, ['0xFF9C1b15B16263C61d017ee9F65C50e4AE0113D7', '0x1dfe7Ca09e99d10835Bf73044a23B73Fc20623DF', '0x8dB687aCEb92c66f013e1D614137238Cc698fEdb'], { deployer });
    // const crystalsMeta = await deployer.deploy(CrystalsMetadata, crystals.address);
    // // const riftQuests = await deployer.deploy(RiftQuests, rift.address);
    // // const enterRift = await deployer.deploy(EnterRift, riftQuests.address, crystals.address, mana.address);

    // mana.addMintController(crystals.address);
    // mana.addMintController(rift.address);
    // mana.addBurnController(crystals.address);
    // mana.addBurnController(rift.address);
    // mana.ownerSetRift(rift.address);
    // riftData.addRiftController(rift.address);
    // crystals.ownerSetMetadataAddress(crystalsMeta.address);
    // crystals.ownerSetRiftAddress(rift.address);
    // rift.addRiftObject(crystals.address);
    // rift.ownerSetRiftData(riftData.address);
    // // rift.ownerSetRiftQuestsAddress(riftQuests.address);
    // rift.addRiftQuest(crystals.address);
    // rift.addRiftQuest(rift.address);
    // // rift.addRiftQuest(riftQuests.address);
    // rift.ownerSetManaAddress(mana.address);
    // // riftQuests.addQuest(enterRift.address);

    // // riftQuests.ownerSetXP(enterRift.address, 1, 2);
    // // riftQuests.ownerSetXP(enterRift.address, 2, 2);
    // // riftQuests.ownerSetXP(enterRift.address, 3, 2);

    // // starting rift information
    // rift.ownerSetLevelChargeAward(1, 1);
    // rift.ownerSetLevelChargeAward(2, 2);
    // rift.ownerSetLevelChargeAward(3, 2);
    // rift.ownerSetLevelChargeAward(4, 1);
    // rift.ownerSetLevelChargeAward(5, 2);
    // rift.ownerSetLevelChargeAward(6, 1);
    // rift.ownerSetLevelChargeAward(7, 1);
    // rift.ownerSetLevelChargeAward(8, 2);
    // rift.ownerSetLevelChargeAward(9, 1);
    // rift.ownerSetLevelChargeAward(10, 3);

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
