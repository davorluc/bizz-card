<script lang="ts">
  import { onMount } from "svelte";
  import { ethers } from "ethers";
  import uploadToIPFS from "../utils/ipfs";

  // Constants
  const CONTRACT_ADDRESS = "0x5fbdb2315678afecb367f032d93f642f64180aa3";
  const CONTRACT_ABI = [
    "function register(string calldata name, string memory imageURI) public payable",
    "function setRecord(string calldata name, (string, string, address, string, string, string, string, string, string) calldata record) external",
    "function getRecord(string calldata name) public view returns (tuple(string, string, address, string, string, string, string, string, string))",
  ];

  const TWITTER_HANDLE = "puskaimdzep";
  const TWITTER_LINK = `https://twitter.com/${TWITTER_HANDLE}`;
  const tld = ".bizz";

  // State Variables
  let currentAccount = "";
  let domain = "";
  let email = "";
  let twitter = "";
  let linkedin = "";
  let website = "";
  let avatarFile: File | null = null;
  let avatarUrl = "";
  let variant = "";
  let loading = false;
  let successMessage = "";
  let errorMessage = "";

  let contract;
  let signer;
  let hasDomain = false; // Tracks if user has a registered domain

  const connectWallet = async () => {
    try {
      const { ethereum } = window;
      if (!ethereum) {
        alert("Get MetaMask -> https://metamask.io/");
        return;
      }

      const accounts = await ethereum.request({
        method: "eth_requestAccounts",
      });
      currentAccount = accounts[0];
      console.log("Connected", currentAccount);

      await checkDomainStatus();
    } catch (error) {
      console.error(error);
    }
  };

  const checkIfWalletIsConnected = async () => {
    const { ethereum } = window;
    if (!ethereum) {
      console.log("Make sure you have MetaMask!");
      return;
    }

    const accounts = await ethereum.request({ method: "eth_accounts" });
    if (accounts.length !== 0) {
      currentAccount = accounts[0];
      console.log("Found an authorized account:", currentAccount);
      await checkDomainStatus();
    } else {
      console.log("No authorized account found");
    }
  };

  const handleFileChange = (event: Event) => {
    const target = event.target as HTMLInputElement;
    if (target?.files?.[0]) {
      avatarFile = target.files[0];
    }
  };

  const handleUploadAvatar = async () => {
    if (avatarFile) {
      try {
        avatarUrl = await uploadToIPFS(avatarFile);
        console.log("Avatar uploaded to IPFS:", avatarUrl);
      } catch (error) {
        console.error("Error uploading avatar:", error);
        errorMessage = "Failed to upload avatar to IPFS.";
      }
    } else {
      errorMessage = "No avatar file selected.";
    }
  };

  const mintDomain = async () => {
    if (!domain) {
      errorMessage = "Domain name is required.";
      return;
    }

    try {
      loading = true;
      successMessage = "";
      errorMessage = "";

      const tx = await contract.register(domain, "ipfs://default-image", {
        value: ethers.parseEther("0.01"),
      });
      await tx.wait();

      successMessage = `Domain ${domain}${tld} minted successfully!`;
      await checkDomainStatus();
    } catch (error) {
      errorMessage = `Error: ${error.message}`;
    } finally {
      loading = false;
    }
  };

  const handleSetRecord = async () => {
    if (!domain) {
      errorMessage = "Domain name is required.";
      return;
    }
    if (!avatarUrl) {
      errorMessage = "Avatar URL is required.";
      return;
    }

    try {
      loading = true;
      successMessage = "";
      errorMessage = "";

      const domainRecord = {
        name: domain,
        ens: `${domain}${tld}`,
        wallet: currentAccount,
        email,
        twitter,
        linkedin,
        website,
        avatar: avatarUrl,
        variant,
      };

      const tx = await contract.setRecord(domain, domainRecord);
      await tx.wait();

      successMessage = "Domain record updated successfully!";
      await checkDomainStatus();
    } catch (error) {
      errorMessage = `Error: ${error.message}`;
    } finally {
      loading = false;
    }
  };

  const checkDomainStatus = async () => {
    if (!contract || !currentAccount || !domain) return;

    try {
      console.log(`Checking record for ${domain}${tld}...`);

      const record = await contract.getRecord(domain);

      // If domain exists, populate fields
      if (record.wallet !== ethers.ZeroAddress) {
        hasDomain = true;
        email = record.email;
        twitter = record.twitter;
        linkedin = record.linkedin;
        website = record.website;
        avatarUrl = record.avatar;
        variant = record.variant;

        console.log(`Loaded domain record for ${domain}${tld}:`, record);
      } else {
        hasDomain = false;
      }
    } catch (error) {
      console.error("Error fetching domain record:", error);
      hasDomain = false;
    }
  };

  onMount(async () => {
    if (window.ethereum) {
      console.log("Ethereum provider found!");

      const provider = new ethers.BrowserProvider(window.ethereum);
      signer = await provider.getSigner();
      contract = new ethers.Contract(CONTRACT_ADDRESS, CONTRACT_ABI, signer);

      console.log("Connected to contract at:", CONTRACT_ADDRESS);

      await checkIfWalletIsConnected();
    } else {
      console.log("Ethereum provider not found. Please install MetaMask.");
    }
  });
</script>

<div class="App">
  <div class="container">
    <header>
      <div class="left">
        <p class="title">Bizz Card Naming Service</p>
        <p class="subtitle">
          Your immortal API on the blockchain! Powered by Ethereum
        </p>
      </div>
    </header>

    {#if !currentAccount}
      <button on:click={connectWallet} class="cta-button connect-wallet-button">
        Connect Wallet
      </button>
    {:else}
      <div class="form-container">
        <input type="text" placeholder="domain" bind:value={domain} />
        .bizz

        {#if hasDomain}
          <input type="email" placeholder="Email" bind:value={email} />
          <input type="url" placeholder="Twitter" bind:value={twitter} />
          <input type="url" placeholder="LinkedIn" bind:value={linkedin} />
          <input type="url" placeholder="Website" bind:value={website} />
          <input type="file" on:change={handleFileChange} />
          <button on:click={handleUploadAvatar}>Upload Avatar</button>

          {#if avatarUrl}
            <img
              src={avatarUrl}
              alt="Avatar"
              style="width: 100px; height: 100px;"
            />
          {/if}

          <button on:click={handleSetRecord} disabled={loading}>
            {loading ? "Updating..." : "Set Data"}
          </button>
        {:else}
          <button on:click={mintDomain} disabled={loading}>
            {loading ? "Minting..." : "Mint"}
          </button>
        {/if}
      </div>
    {/if}

    <div class="footer-container">
      <a href={TWITTER_LINK} target="_blank" rel="noreferrer"
        >built with @{TWITTER_HANDLE}</a
      >
    </div>
  </div>
</div>

<style>
  .cta-button {
    background-color: #ff6700;
    color: white;
    padding: 12px 24px;
    border: none;
    cursor: pointer;
    border-radius: 8px;
  }
</style>
