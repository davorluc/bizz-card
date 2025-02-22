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

    it("Should fail when trying to register an empty domain name", async function () {
      const { domainsContract, owner } = await loadFixture(
        deployDomainsFixture
      );

      await expect(
        domainsContract.connect(owner).register("", testImageURI, {
          value: 10000000000000000n,
        })
      ).to.be.revertedWith("Domain name cannot be empty");
    });

    it("Should fail when sending insufficient Ether", async function () {
      const price = await domainsContract.price("doom");
      await expect(
        domainsContract.connect(owner).register("doom", testImageURI, {
          value: price - 100000000000000n,
        })
      ).to.be.revertedWith("Not enough Ether paid");
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

    it("Should return correct price for different domain lengths", async function () {
      const price3Char = await domainsContract.price("abc");
      const price4Char = await domainsContract.price("abcd");
      const price5Char = await domainsContract.price("abcde");

      expect(price3Char).to.equal(BigInt(5 * 10 ** 16));
      expect(price4Char).to.equal(BigInt(3 * 10 ** 16));
      expect(price5Char).to.equal(BigInt(1 * 10 ** 16));
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
    beforeEach(async function () {
      const price = await domainsContract.price("doom");
      await domainsContract.register("doom", testImageURI, { value: price });
    });

    it("Should allow the owner to set a domain record", async function () {
      await domainsContract.setEmail("doom", "d.lucic4@hotmail.com");
      const record = await domainsContract.getRecord("doom");

      expect(record.name).to.equal("");
      expect(record.email).to.equal("d.lucic4@hotmail.com");
      expect(record.twitter).to.equal("");
      expect(record.linkedin).to.equal("");
      expect(record.website).to.equal("");
      expect(record.avatar).to.equal("");
      expect(record.variant).to.equal("");
    });

    it("Should prevent non-owners from setting a domain record", async function () {
      await expect(
        domainsContract
          .connect(randomPerson)
          .setEmail("doom", "spongebob@krustykrab.com")
      ).to.be.revertedWith("Not domain owner");
    });

    it("Should return an empty record for a newly registered domain", async function () {
      const record = await domainsContract.getRecord("doom");

      expect(record.name).to.equal("");
      expect(record.email).to.equal("");
      expect(record.variant).to.equal("");
      expect(record.twitter).to.equal("");
      expect(record.linkedin).to.equal("");
      expect(record.website).to.equal("");
      expect(record.avatar).to.equal("");
    });

    it("Should allow partial updates to the domain record", async function () {
      await domainsContract.setEmail("doom", "spongebob@krustykrab.com");
      await domainsContract.setTwitter("doom", "x.com/spongebob");
      await domainsContract.setLinkedIn("doom", "linkedin link");
      await domainsContract.setName("doom", "Spongebob Squarepants");
      const record = await domainsContract.getRecord("doom");

      expect(record.email).to.equal("spongebob@krustykrab.com");
      expect(record.twitter).to.equal("x.com/spongebob"); // other fields should stay the same
      expect(record.linkedin).to.equal("linkedin link"); // other fields should stay the same
      expect(record.name).to.equal("Spongebob Squarepants"); // other fields should stay the same
    });

    it("Should fail when trying to set a record for an unregistered domain", async function () {
      await expect(
        domainsContract
          .connect(owner)
          .setEmail("nonexistent", "spongebob@krustykrab.com")
      ).to.be.revertedWith("Not domain owner"); // Will return this message, since smart contract checks if sender is domain owner before checking anything else, and since domain doesn't exist, no one is the owner technically
    });

    it("Should allow the avatar to be updated", async function () {
      const updatedAvatar = "ipfs://QmNewAvatarHash";

      await domainsContract.setAvatar("doom", updatedAvatar);

      const record = await domainsContract.getRecord("doom");
      expect(record.avatar).to.equal(updatedAvatar);
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
