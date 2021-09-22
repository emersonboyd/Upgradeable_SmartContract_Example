// scripts/transfer_ownership.js
async function main() {
  const gnosisSafe = '0x462B230e57353823418C2C105494A7c13206979E'; // rinkeby gnosis safe address (not address of token, token address is taken into account in .openzeppelin folder)

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
