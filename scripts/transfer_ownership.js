// scripts/transfer_ownership.js
async function main() {
  // switch gnosisSafe address depending on rinkeby vs. bsc mainnet
  // const gnosisSafe = '0x462B230e57353823418C2C105494A7c13206979E'; // rinkeby gnosis safe address (not address of token, token address is taken into account in .openzeppelin folder)
  const gnosisSafe = '0xD19A15326D32BF2e31568C4d23f6433F18a39eE9'; // bsc mainnet gnosis safe address (not address of token, token address is taken into account in .openzeppelin folder)

  console.log("Transferring ownership of ProxyAdmin...");
  // The owner of the ProxyAdmin can upgrade our contracts
  await upgrades.admin.transferProxyAdminOwnership(gnosisSafe);
  console.log("Transferred ownership of ProxyAdmin to:", gnosisSafe);
}
 
main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
