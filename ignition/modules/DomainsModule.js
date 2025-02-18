const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("DomainsModule", (m) => {
  const tld = m.getParameter("tld", "bizz"); // Default TLD is "bizz"

  const domains = m.contract("Domains", [tld], {
    value: m.getParameter("initialFunds", 100000000000000000n), // Optional initial ETH funding (0.1)
  });

  return { domains };
});
