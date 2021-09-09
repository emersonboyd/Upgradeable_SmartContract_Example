// test/ftb.proxy.js
// Load dependencies
const { expect } = require('chai');

let Ftb;
let ftb;
 
// Start test block
describe('Ftb', function () {
  beforeEach(async function () {
    Ftb = await ethers.getContractFactory("ForTheBoysContract");
    ftb = await upgrades.deployProxy(Ftb, [], {initializer: 'initialize'}); // deploys the proxy contract
    await ftb.deployed();
  });
 
  // Test case
  it('Should create token with decimals', async function () {
    expect((await ftb.decimals()).toString()).to.equal('18');
  });
});

