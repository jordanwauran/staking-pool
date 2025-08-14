require("@nomicfoundation/hardhat-toolbox");
require("@nomicfoundation/hardhat-ignition-ethers");
require("dotenv").config();

module.exports = {
  solidity: "0.8.28", // Match your contract's Solidity version
  networks: {
    baseSepolia: {
      url: "https://sepolia.base.org", // Base Sepolia RPC URL
      accounts: [process.env.PRIVATE_KEY], // Your wallet private key (store in .env)
    },
  },
};