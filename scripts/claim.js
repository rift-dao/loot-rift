const open = require('open');
const { contract } = require('@openzeppelin/test-environment');

const { getArgs, decodeToken, hasFlag } = require('./helpers');

const Crystals = contract.fromArtifact('Crystals');
const Mana = contract.fromArtifact('Mana');

const args = getArgs();

(async () => {
  console.log('\n🔮 generating stats for #' + args.seeds.join(', #'), '\n\n');

  const manaInstance = await Mana.new();
  const crystalInstance = await Crystals.new(manaInstance.address);

  const tokens = [...args.seeds];
  const tokenImages = [];
  
  for (let i = 0; i < tokens.length; i++) {
    const encodedToken = await crystalInstance.tokenURI(tokens[i]);
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
