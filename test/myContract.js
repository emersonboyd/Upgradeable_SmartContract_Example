// test/myContract.js
// Load dependencies
const { expect } = require('chai');

let MyContract;
let myContract;
 
// Start test block
describe('Ftb', function () {
  beforeEach(async function () {
    MyContract = await ethers.getContractFactory("MyUpgradeableContract");
    myContract = await MyContract.deploy(); // deploys the implementation contract
    await myContract.deployed();
    await myContract.initialize();
  });
 
  // Test case
  it('Should create token with totalSupply', async function () {
    const decimals = '000000000000000000'; // 18 decimals
    const wholeNum = '1000000000000'; // 10^12 (1 trillion coins)
    const totalSupplyExpected = wholeNum + decimals;
    const minterAddress = await myContract.getMinter();
    const totalSupply = await myContract.balanceOf(minterAddress);
    expect(totalSupply.toString()).to.equal(totalSupplyExpected);
  });

  // Test case
  it('Should burn 5 percent from transaction', async function () {
    // Only 5 percent is burned because minter is the liquidityPoolAddress for starters
    const minterAddress = await myContract.getMinter();
    const tradeAmount = 924;
    await myContract.transfer(minterAddress, tradeAmount);
    const newMinterAmount = await myContract.balanceOf(minterAddress);
    expect(newMinterAmount.toString()).to.equal('999999999999999999999999999954'); // 46 was burned
  });
});
