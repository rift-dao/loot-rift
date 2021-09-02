## Dev Quickstart

1. clone and cd into directory
1. run `yarn`
1. run `yarn test` or `yarn test:watch`

## Environment Setup

* [node](https://nodejs.org/en/) & [npm](https://www.npmjs.com/) ([nvm](https://github.com/nvm-sh/nvm/blob/master/README.md#installing-and-updating) recommended)
* [yarn](https://classic.yarnpkg.com/en/docs/install/#windows-stable)
* [ethlint](https://github.com/duaraghav8/Ethlint) (if running coverage script)

## Scripts

| command | description |
| --- | --- |
| coverage | check test coverage |
| test | compile and run js tests |
| test:quick | run js tests without compiling |
| test:watch | compile and run js tests while watching for test.js changes |

> *Note:* `yarn test:watch` only watches test.js files for changes, any Contract.sol changes will require re-compiling, meaning you have to re-run the test script to compile the contract