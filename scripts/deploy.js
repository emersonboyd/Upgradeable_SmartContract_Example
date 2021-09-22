// scripts/deploy.js
async function main() {
    const MyContract = await ethers.getContractFactory("MyUpgradeableContract");
    console.log("Deploying MyContract proxy, implementation, and proxy admin...");
    const myContract = await upgrades.deployProxy(MyContract, [], { initializer: 'initialize' });
    console.log("MyContract deployed to:", myContract.address);
  }
  
  main()
    .then(() => process.exit(0))
    .catch(error => {
      console.error(error);
      process.exit(1);
    });
