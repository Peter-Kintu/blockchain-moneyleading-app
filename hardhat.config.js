require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.0", // Ensure this matches your contract's pragma version
  networks: {
    ganache: {
       url: "http://127.0.0.1:8545", // IMPORTANT: This must match your Ganache RPC server address and port
      // You can specify a chainId if Ganache provides one, but it's often not strictly necessary for local development
      // chainId: 1337 // Common chainId for Ganache, check your Ganache UI
    }
    // You can add other networks like Sepolia here later
  }
  // Optional: paths to customize where Hardhat looks for contracts, tests, etc.
  // paths: {
  //   sources: "./contracts",
  //   tests: "./test",
  //   cache: "./cache",
  //   artifacts: "./artifacts"
  // }
};