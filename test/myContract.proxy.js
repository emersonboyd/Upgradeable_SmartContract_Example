// test/myContract.proxy.js
// Load dependencies
const { expect } = require('chai');

let MyContract;
let myContract;

// Start test block
describe('MyContract', function () {
  beforeEach(async function () {
    MyContract = await ethers.getContractFactory("MyUpgradeableContract");
    myContract = await upgrades.deployProxy(MyContract, [], {initializer: 'initialize'}); // deploys the proxy contract
    await myContract.deployed();
  });

  // Test case
  it('Should create token with decimals', async function () {
    expect((await myContract.decimals()).toString()).to.equal('18');
  });
});
