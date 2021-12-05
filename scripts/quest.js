const open = require('open');

const { getArgs, decodeToken, hasFlag, setup } = require('./helpers');

const args = getArgs();

(async () => {
  console.log('\n🔮 generating image for step #' + args.seeds.join(', #'), '\n\n');

  const tokens = [...args.seeds];
  const tokenImages = [];

  const { enterRift } = await setup();
  
  for (let i = 0; i < tokens.length; i++) {
    const encodedToken = await enterRift.testTokenURI(tokens[i]);
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
