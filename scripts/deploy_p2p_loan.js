// scripts/deploy_p2p_loan.js
const hre = require("hardhat");

async function main() {
  // Get the contract factory for P2PLoan
  const P2PLoan = await hre.ethers.getContractFactory("P2PLoan");

  // --- Define constructor arguments for your P2PLoan contract ---
  // These are dummy values for local deployment.
  // In a real scenario, these would come from your Django backend or a configuration.

  // Get some accounts from Hardhat (which uses Ganache's accounts)
  const [deployer, lenderAccount, borrowerAccount] = await hre.ethers.getSigners();

  // For simplicity, let's use the first two accounts from Ganache
  const lenderAddress = lenderAccount.address; // Account 1 in Ganache
  const borrowerAddress = borrowerAccount.address; // Account 2 in Ganache

  // Loan terms (example values)
  const loanAmount = hre.ethers.parseEther("100"); // 100 units of the loan asset (e.g., DAI)
  const collateralAmount = hre.ethers.parseEther("0.5"); // 0.5 units of collateral (e.g., WETH)
  const interestRate = 500; // 5% (500 means 5.00%, using 2 decimal places fixed implicitly)
  const loanDuration = 30 * 24 * 60 * 60; // 30 days in seconds

  // Dummy token addresses (replace with actual testnet ERC-20 addresses later)
  // For Ganache, these can be any valid Ethereum address, as we're not actually
  // interacting with real ERC-20 contracts in this simplified example.
  // You could use addresses from Ganache's accounts for simplicity:
  const dummyLoanAssetAddress = deployer.address; // Use deployer's address as a dummy
  const dummyCollateralAssetAddress = lenderAccount.address; // Use lender's address as a dummy

  // Deploy the contract
  console.log("Deploying P2PLoan contract with the account:", deployer.address);
  console.log("Account balance:", (await hre.ethers.provider.getBalance(deployer.address)).toString());

  const p2pLoan = await P2PLoan.deploy(
    lenderAddress,
    borrowerAddress,
    loanAmount,
    collateralAmount,
    interestRate,
    loanDuration,
    dummyLoanAssetAddress,
    dummyCollateralAssetAddress
  );

  // Wait for the contract to be deployed
  await p2pLoan.waitForDeployment();

  console.log(`P2PLoan contract deployed to address: ${await p2pLoan.getAddress()}`);

  // You can also print the contract's initial state if needed
  console.log(`  Lender: ${await p2pLoan.lender()}`);
  console.log(`  Borrower: ${await p2pLoan.borrower()}`);
  console.log(`  Loan Amount: ${hre.ethers.formatEther(await p2pLoan.loanAmount())}`);
  console.log(`  Collateral Amount: ${hre.ethers.formatEther(await p2pLoan.collateralAmount())}`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });