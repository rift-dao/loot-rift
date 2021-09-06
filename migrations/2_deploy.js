const Mana = artifacts.require('Mana');
const Crystals = artifacts.require('Crystals');

module.exports = function(deployer) {
  deployer.then(async () => {
     const mana = await deployer.deploy(Mana);
     const crystals = await deployer.deploy(Crystals, mana.address);
     mana.ownerSetCContractAddress(crystals.address);
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
