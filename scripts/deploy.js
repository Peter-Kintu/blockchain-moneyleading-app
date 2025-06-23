// scripts/deploy.js
const hre = require("hardhat");

async function main() {
  // Get the ContractFactory for your P2PLoan contract
  const P2PLoan = await hre.ethers.getContractFactory("P2PLoan"); // <--- This now correctly points to "P2PLoan"

  // --- Define Constructor Arguments for P2PLoan ---
  // You need to pass these values when deploying the contract.
  // These are example values. You will need to adjust them for your specific tests.

  const [deployer, borrowerAccount] = await hre.ethers.getSigners(); // Get two accounts from Hardhat
  console.log("Deploying contract with the account (Lender):", deployer.address);
  console.log("Using Borrower account:", borrowerAccount.address);

  // Example addresses for loan and collateral assets (placeholders for now)
  // In a real test, these might be addresses of mock ERC-20 tokens you deploy
  // or a hardcoded address if you're not fully simulating ERC-20s yet.
  // For simplicity, let's use some common test addresses or even zero address for now if not used.
  const exampleLoanAssetAddress = "0x7a30364177d61184918f03a6202f58e454b5258e"; // Placeholder (e.g., Mock DAI address)
  const exampleCollateralAssetAddress = "0x8e870d67f660d95d5415bc866504be09f3e82efc"; // Placeholder (e.g., Mock WETH address)

  // Constructor arguments for P2PLoan:
  // _lender, _borrower, _loanAmount, _collateralAmount, _interestRate, _loanDuration, _loanAssetAddress, _collateralAssetAddress
  const constructorArgs = [
    deployer.address,                   // _lender (using the deployer's address)
    borrowerAccount.address,            // _borrower (using the second Hardhat account)
    hre.ethers.parseUnits("100", 18),   // _loanAmount (e.g., 100 tokens with 18 decimals)
    hre.ethers.parseUnits("1", 18),     // _collateralAmount (e.g., 1 WETH with 18 decimals)
    500,                                // _interestRate (500 = 5%)
    60 * 60 * 24 * 30,                  // _loanDuration (30 days in seconds)
    exampleLoanAssetAddress,            // _loanAssetAddress
    exampleCollateralAssetAddress       // _collateralAssetAddress
  ];

  // Deploy the contract with the specified arguments
  const p2pLoan = await P2PLoan.deploy(...constructorArgs);

  await p2pLoan.waitForDeployment();

  console.log(`P2PLoan deployed to: ${p2pLoan.target}`);
  console.log("Lender Address:", constructorArgs[0]);
  console.log("Borrower Address:", constructorArgs[1]);
  console.log("Loan Amount:", hre.ethers.formatUnits(constructorArgs[2], 18));
  console.log("Collateral Amount:", hre.ethers.formatUnits(constructorArgs[3], 18));
  console.log("Interest Rate:", constructorArgs[4] / 100 + "%");
  console.log("Loan Duration (seconds):", constructorArgs[5]);
  console.log("Loan Asset Address:", constructorArgs[6]);
  console.log("Collateral Asset Address:", constructorArgs[7]);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});