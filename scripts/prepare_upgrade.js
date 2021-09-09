// scripts/prepare_upgrade.js
async function main() {
    // const proxyAddress = '0x516F3862d4FdA27A3e015B715a8FeC5f179c2433'; // moralisRinkeby proxy address from initial deployment/previous upgrade
    const proxyAddress = '0x7054228818693B8008217b5ed4A2380A0290CBe8'; // moralisBscMainnet proxy address from initial deployment/previous upgrade

    // "Ftb" could also be "FtbUpgrade". and "ForTheBoysContract" could also be "ForTheBoysContractV2". Those names don't have to match from initial deployment
    const Ftb = await ethers.getContractFactory("ForTheBoysContract");
    console.log("Preparing upgrade...");
    const newFtbImplAddress = await upgrades.prepareUpgrade(proxyAddress, Ftb);
    console.log("New Ftb implementation at:", newFtbImplAddress);
  }
  
main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
