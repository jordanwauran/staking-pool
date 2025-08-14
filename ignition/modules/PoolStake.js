const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("PoolStakeModule", (m) => {
  const testToken = m.contract("TestToken");
  const poolStake = m.contract("poolstake", [testToken, testToken]);
  m.call(testToken, "transfer", [
    poolStake,
    "10000000000000000000000" // 10,000 tokens * 10^18
  ]);
  return { testToken, poolStake };
});