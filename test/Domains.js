const {
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { expect } = require("chai");

describe("Domains contract", function () {
  async function deployDomainsFixture() {
    const [owner, randomPerson] = await ethers.getSigners();
    const Domains = await ethers.getContractFactory("Domains");

    const domainsContract = await Domains.deploy("bizz");
    await domainsContract.waitForDeployment();

    return { domainsContract, owner, randomPerson };
  }

  let domainsContract, owner, randomPerson;
  const testImageURI = "ipfs://QmFakeHash"; // Dummy IPFS URL for tests

  beforeEach(async function () {
    ({ domainsContract, owner, randomPerson } = await loadFixture(
      deployDomainsFixture
    ));
  });

  describe("Deployment", function () {
    it("Should deploy successfully and have a valid address", async function () {
      expect(domainsContract.target).to.not.equal(0);
    });
  });

  describe("Domain Registration", function () {
    it("Should allow a user to register a domain", async function () {
      const { domainsContract, owner } = await loadFixture(
        deployDomainsFixture
      );

      const price = await domainsContract.price("doom");

      await domainsContract
        .connect(owner)
        .register("doom", testImageURI, { value: price });

      const domainRecords = await domainsContract.getRecord("doom");
      const domainOwner = domainRecords.wallet;

      expect(domainOwner).to.equal(owner.address);
    });

    it("Should not allow registering an already registered domain", async function () {
      const price = await domainsContract.price("doom");
      await domainsContract.register("doom", testImageURI, { value: price });

      await expect(
        domainsContract
          .connect(randomPerson)
          .register("doom", testImageURI, { value: price })
      ).to.be.revertedWith("Domain already registered");
    });

    it("Wallet should not be empty", async function () {
      const price = await domainsContract.price("doom");
      await domainsContract.register("doom", testImageURI, { value: price });
      const balance = await hre.ethers.provider.getBalance(
        domainsContract.target
      );

      expect(balance).to.not.equal(0);
    });
  });

  describe("Domain Records", function () {
    const newRecord = {
      name: "Doom Slayer",
      ens: "doom.bizz",
      wallet: null, // Will be set dynamically
      email: "doom@web3.com",
      twitter: "@doomslayer",
      linkedin: "linkedin.com/in/doom",
      website: "https://doom.com",
      avatar: "ipfs://QmAvatarHash",
      tagline: "Rip and Tear!",
    };

    beforeEach(async function () {
      const price = await domainsContract.price("doom");
      await domainsContract.register("doom", testImageURI, { value: price });
      newRecord.wallet = owner.address;
    });

    it("Should allow the owner to set a domain record", async function () {
      await domainsContract.setRecord("doom", newRecord);
      const record = await domainsContract.getRecord("doom");

      expect(record.name).to.equal(newRecord.name);
      expect(record.ens).to.equal(newRecord.ens);
      expect(record.email).to.equal(newRecord.email);
      expect(record.twitter).to.equal(newRecord.twitter);
      expect(record.linkedin).to.equal(newRecord.linkedin);
      expect(record.website).to.equal(newRecord.website);
      expect(record.avatar).to.equal(newRecord.avatar);
      expect(record.tagline).to.equal(newRecord.tagline);
    });

    it("Should prevent non-owners from setting a domain record", async function () {
      await expect(
        domainsContract.connect(randomPerson).setRecord("doom", newRecord)
      ).to.be.revertedWith("Not domain owner");
    });

    it("Should return an empty record for a newly registered domain", async function () {
      const record = await domainsContract.getRecord("doom");

      expect(record.name).to.equal("");
      expect(record.email).to.equal("");
      expect(record.tagline).to.equal("");
      expect(record.twitter).to.equal("");
      expect(record.linkedin).to.equal("");
      expect(record.website).to.equal("");
      expect(record.avatar).to.equal("");
    });
  });

  describe("Owner Retrieval", function () {
    it("Should return the correct owner address for a registered domain", async function () {
      const price = await domainsContract.price("doom");
      await domainsContract.register("doom", testImageURI, { value: price });
      const domainRecord = await domainsContract.getRecord("doom");

      expect(domainRecord.wallet).to.equal(owner.address);
    });
  });
});
