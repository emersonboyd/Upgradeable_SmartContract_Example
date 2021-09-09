// scripts/deploy.js
async function main() {
    const Ftb = await ethers.getContractFactory("ForTheBoysContract");
    console.log("Deploying Ftb proxy, implementation, and proxy admin...");
    const ftb = await upgrades.deployProxy(Ftb, [], { initializer: 'initialize' });
    console.log("FtbProxy deployed to:", ftb.address);
  }
  
  main()
    .then(() => process.exit(0))
    .catch(error => {
      console.error(error);
      process.exit(1);
    });
