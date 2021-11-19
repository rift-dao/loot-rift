const Mana = artifacts.require('Mana');
const Crystals = artifacts.require('Crystals');
const CrystalsMetadata = artifacts.require('CrystalsMetadata');

module.exports = function(deployer) {
  deployer.then(async () => {
     const mana = await deployer.deploy(Mana);
     const crystals = await deployer.deploy(Crystals);
     const crystalsMetadata = await deployer.deploy(CrystalsMetadata);
     crystalsMetadata.setCrystalsAddress(crystals.address);
     mana.ownerSetCContractAddress(crystals.address);
     crystals.ownerInit(
       mana.address,
       '0x0000000000000000000000000000000000000000',
       '0x0000000000000000000000000000000000000000'
      );
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
