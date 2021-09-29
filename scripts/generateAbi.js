/**
 * Generates a Human-Readable ABI
 * 
 */
const { ethers } = require('ethers');

const crystalsJsonAbi = require('../artifacts/contracts/Crystals.sol/Crystals.json');

(async () => {
  const iface = new ethers.utils.Interface(crystalsJsonAbi.abi);
  const abi = iface.format(ethers.utils.FormatTypes.full);
  console.log(JSON.stringify(abi));
  
  process.exit();
})();
