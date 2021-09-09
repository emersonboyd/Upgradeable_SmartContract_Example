// test/ftb.js
// Load dependencies
const { expect } = require('chai');

let Ftb;
let ftb;
 
// Start test block
describe('Ftb', function () {
  beforeEach(async function () {
    Ftb = await ethers.getContractFactory("ForTheBoysContract");
    ftb = await Ftb.deploy(); // deploys the implementation contract
    await ftb.deployed();
    await ftb.initialize();
  });
 
  // Test case
  it('Should create token with totalSupply', async function () {
    const decimals = '000000000000000000'; // 18 decimals
    const wholeNum = '1000000000000'; // 10^12 (1 trillion coins)
    const totalSupplyExpected = wholeNum + decimals;
    const minterAddress = await ftb.getMinter();
    const totalSupply = await ftb.balanceOf(minterAddress);
    expect(totalSupply.toString()).to.equal(totalSupplyExpected);

    // expect((await box.retrieve()).toString()).to.equal('42');
  });

  // Test case
  it('Should burn 5 percent from transaction', async function () {
    // Only 5 percent is burned because minter is the liquidityPoolAddress for starters
    const minterAddress = await ftb.getMinter();
    const tradeAmount = 924;
    await ftb.transfer(minterAddress, tradeAmount);
    const newMinterAmount = await ftb.balanceOf(minterAddress);
    expect(newMinterAmount.toString()).to.equal('999999999999999999999999999954'); // 46 was burned
  });
});

