const decodeToken = (encodedToken) => {
  const jsonEncoded = encodedToken.substring(29);
  return JSON.parse(Buffer.from(jsonEncoded, 'base64').toString());
};

const getArgs = () => {
  const output = {
    flags: [],
    seeds: [],
  };

  process.argv.slice(2).forEach(arg => {
    const isFlag = arg.indexOf('-') === 0;

    if (isFlag) {
      output.flags.push(arg);
    } else {
      output.seeds.push(arg);
    }
  });
  
  return output;
};

const hasFlag = (flag) => {
  return getArgs().flags.indexOf(flag) !== -1;
};

module.exports = {
  decodeToken,
  getArgs,
  hasFlag,
};
