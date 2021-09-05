const Mana = artifacts.require('Mana');
const Crystals = artifacts.require('Crystals');

module.exports = async function (deployer) {
  let manaAddress = await deployer.deploy(Mana);
  
  deployer.deploy(Crystals, manaAddress);
};
