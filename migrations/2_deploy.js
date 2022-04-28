const { deployProxy, upgradeProxy } = require('@openzeppelin/truffle-upgrades');
// const Mana = artifacts.require('Mana');
// const Crystals = artifacts.require('Crystals');
// const CrystalsMetadata = artifacts.require('CrystalsMetadata');
const Rift = artifacts.require('Rift');
// const RiftData = artifacts.require('RiftData');
// const RiftQuests = artifacts.require('RiftQuests');
// const EnterRift = artifacts.require('EnterTheRift');

module.exports = function(deployer) {
  deployer.then(async () => {

    // const riftData = await upgradeProxy('0x632678bBa8a4DD16255F164e9d74853BeA9856E7', RiftData, { deployer });
    // const crystals = await upgradeProxy('0x3051162ED7DeF8Af730Aaf4C7cB8a10Ee19b8303', Crystals,  { deployer });
    // MAINNET
    const rift = await upgradeProxy('0x290a1a360F64758D1b46F994E541ac9b7aE5c830', Rift, { deployer });
    
    // ROPSTEN
    // const rift = await upgradeProxy('0xf0CdC112A01AA657a6283fe9B61BC2eD0869c0f1', Rift, { deployer });
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
