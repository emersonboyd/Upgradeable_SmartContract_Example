// scripts/prepare_upgrade.js
async function main() {
    const proxyAddress = '0x516F3862d4FdA27A3e015B715a8FeC5f179c2433'; // moralisRinkeby proxy address from initial deployment/previous upgrade

    // "MyContract" could also be "MyContractUpgrade". That name doesn't have to match from initial deployment
    const MyContract = await ethers.getContractFactory("MyUpgradeableContract");
    console.log("Preparing upgrade...");
    const newMyContractImplAddress = await upgrades.prepareUpgrade(proxyAddress, MyContract);
    console.log("New MyContract implementation at:", newMyContractImplAddress);
  }

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
