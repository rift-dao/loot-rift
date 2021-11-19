const open = require('open');
const { accounts } = require('@openzeppelin/test-environment');
const { getArgs, decodeToken, hasFlag, setup, MAX_CRYSTALS } = require('./helpers');

const args = getArgs();

(async () => {
  console.log('\n🔮 generating stats for #' + args.seeds.join(', #'), '\n\n');

  const {
    crystals,
  } = await setup();
  const owner = await crystals.owner();

  const tokens = [...args.seeds];
  const tokenImages = [];
  
  for (let i = 0; i < tokens.length; i++) {
    console.log('registering...')
    await crystals.testRegister(tokens[i]);
    console.log('register done\n');
    console.log('minting...');
    await crystals.testMint(tokens[i]);
    console.log('minting done\n');
  }

  for (let i = 0; i < tokens.length; i++) {
    console.log('registering...')
    await crystals.testRegister(tokens[i]);
    console.log('register done\n');
    
    console.log('data...');
    const gen2 = await crystals.getRegisteredCrystal(tokens[i]);
    console.log('data done\n');

    console.log('minting...');
    await crystals.testMint(gen2);
    console.log('minting done\n');
    
    console.log('transfer 1...');
    await crystals.transferFrom(owner, accounts[5], gen2);
    console.log('transfer 1 done\n');

    console.log('tokenURI...');
    const encodedToken = await crystals.tokenURI(gen2);
    console.log('tokenURI done\n');

    tokens[i] = decodeToken(encodedToken);
    tokenImages.push(tokens[i].image);
  }

  tokens.forEach(token => {
    console.log('Token:', token);
  });

  console.log('\n ----- IMAGES -----\n');

  for(let i = 0; i < tokenImages.length; i++) {
    const image = tokenImages[i];
    console.log(image, '\n');

    if (hasFlag('--openImage') || hasFlag('-o')) {
      await open('', {app: {name: 'chrome', arguments: [`--app=${image}`, '--ash-force-desktop', '--window-size=200x200', '--window-position=20,20']}});
    }
  };

  process.exit();
})();
