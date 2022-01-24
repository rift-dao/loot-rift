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
    // const riftData = await upgradeProxy('0x632678bBa8a4DD16255F164e9d74853BeA9856E7', RiftData, { deployer });
    // const crystals = await upgradeProxy('0x3051162ED7DeF8Af730Aaf4C7cB8a10Ee19b8303', Crystals,  { deployer });
    const rift = await upgradeProxy('0x290a1a360F64758D1b46F994E541ac9b7aE5c830', Rift, { deployer });

    // riftData.addXPController(crystals.address);
    // riftData.addXPController(rift.address);

    // crystals.setRiftData(riftData.address);

    // riftData.migrateXP([687,127473,1336418,4727,7146,6434,314994,9997822,5924,246064,4901,479587,45093,1262912,190129,4422,3485,4242,1525,1182,7239,74,1897,5467,240780,150026,3164,37150,1313,73,687,1627,57,3157,5299,246,612]);
   
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
