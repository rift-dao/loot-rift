const { contract } = require('@openzeppelin/test-environment');

const Rift = contract.fromArtifact('Rift');

let tokenId = '0001';
process.argv.forEach((val, index) => {
  if (index === 2) {
    tokenId = val;
  }
});

(async () => {
  console.log('\n🔮 generating for #' + tokenId, '\n\n');

  const riftInstance = await Rift.new();
  const encodedToken = await riftInstance.tokenURI(tokenId);
  
  const jsonEncoded = encodedToken.substring(29);
  const json = Buffer.from(jsonEncoded, 'base64').toString();
  
  console.log('Token:\n', json);

  console.log('\nImage:\n', JSON.parse(json).image, '\n');
  process.exit();
})();
