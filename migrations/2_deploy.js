const Mana = artifacts.require('Mana');
const Crystals = artifacts.require('Crystals');
const CrystalsMetadata = artifacts.require('CrystalsMetadata');
const ManaCalculator = artifacts.require('CrystalManaCalculator');

module.exports = function(deployer) {
  deployer.then(async () => {
    const mana = await deployer.deploy(Mana);
    const crystals = await deployer.deploy(Crystals, mana.address);
    const crystalsMeta = await deployer.deploy(CrystalsMetadata, crystals.address);
    const calculator = await deployer.deploy(ManaCalculator, crystals.address);

    mana.addController(crystals.address);
    crystals.ownerSetMetadataAddress(crystalsMeta.address);
    crystals.ownerSetCalculatorAddress(calculator.address);
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
