<script lang="ts">
  import { onMount } from "svelte";
  import { ethers } from "ethers";
  import uploadToIPFS from "../utils/ipfs"; // Import the IPFS utility function

  // Constants
  const TWITTER_HANDLE = "puskaimdzep";
  const TWITTER_LINK = `https://twitter.com/${TWITTER_HANDLE}`;
  const tld = ".bizz";

  // States
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

  const connectWallet = async () => {
    try {
      const { ethereum } = window;

      if (!ethereum) {
        alert("Get MetaMask -> https://metamask.io/");
        return;
      }

      // Request access to the account
      const accounts = await ethereum.request({
        method: "eth_requestAccounts",
      });

      console.log("Connected", accounts[0]);
      currentAccount = accounts[0];
    } catch (error) {
      console.log(error);
    }
  };

  const checkIfWalletIsConnected = async () => {
    const { ethereum } = window;

    if (!ethereum) {
      console.log("Make sure you have metamask!");
      return;
    }

    const accounts = await ethereum.request({ method: "eth_accounts" });

    if (accounts.length !== 0) {
      const account = accounts[0];
      console.log("Found an authorized account:", account);
      currentAccount = account;
    } else {
      console.log("No authorized account found");
    }
  };

  // Handle file input and avatar file selection
  const handleFileChange = (event: Event) => {
    const target = event.target as HTMLInputElement;
    if (target?.files?.[0]) {
      avatarFile = target.files[0];
    }
  };

  // Upload avatar to IPFS
  const handleUploadAvatar = async () => {
    if (avatarFile) {
      try {
        avatarUrl = await uploadToIPFS(avatarFile); // Upload avatar to IPFS
        console.log("Avatar uploaded to IPFS:", avatarUrl);
      } catch (error) {
        console.error("Error uploading avatar:", error);
        errorMessage = "Failed to upload avatar to IPFS.";
      }
    } else {
      errorMessage = "No avatar file selected.";
    }
  };

  // Set domain record in smart contract
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
        name: "", // Optional, you can leave it empty
        ens: `${domain}${tld}`, // Full domain, e.g. "spongebob.bizz"
        wallet: currentAccount,
        email,
        twitter,
        linkedin,
        website,
        avatar: avatarUrl, // Include the IPFS avatar URL here
        variant,
      };

      // Interact with the smart contract
      const tx = await contract.setRecord(domain, domainRecord);
      await tx.wait();

      successMessage = "Domain record updated successfully!";
    } catch (error) {
      errorMessage = `Error: ${error.message}`;
    } finally {
      loading = false;
    }
  };

  // Connect to the Ethereum provider and contract
  onMount(async () => {
    if (window.ethereum) {
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      signer = provider.getSigner();
      const contractAddress = "0xYourContractAddress"; // Replace with your actual contract address
      const abi = [
        // Define the contract ABI (simplified)
        "function setRecord(string calldata name, (string, string, address, string, string, string, string, string, string) calldata record) external",
      ];
      contract = new ethers.Contract(contractAddress, abi, signer);
    } else {
      console.log("Ethereum provider not found. Please install MetaMask.");
    }

    checkIfWalletIsConnected();
  });
</script>

<div class="App">
  <div class="container">
    <div class="header-container">
      <header>
        <div class="left">
          <p class="title">Bizz Card Naming Service</p>
          <p class="subtitle">
            Your immortal API on the blockchain! Powered by Ethereum
          </p>
        </div>
      </header>
    </div>

    {#if !currentAccount}
      <div class="connect-wallet-container">
        <button
          on:click={connectWallet}
          class="cta-button connect-wallet-button"
        >
          Connect Wallet
        </button>
      </div>
    {/if}

    {#if currentAccount}
      <div class="form-container">
        <div class="first-row">
          <input type="text" placeholder="domain" bind:value={domain} />
          <p class="tld">{tld}</p>
        </div>

        <input
          type="email"
          id="email"
          placeholder="john.doe@email.com"
          bind:value={email}
        />
        <input
          type="url"
          id="twitter"
          placeholder="https://x.com/johndoe"
          bind:value={twitter}
        />
        <input
          type="url"
          id="linkedin"
          placeholder="https://www.linkedin.com/in/john-doe-1234567890/"
          bind:value={linkedin}
        />
        <input
          type="url"
          id="website"
          placeholder="https://johndoe.com"
          bind:value={website}
        />

        <input
          type="file"
          alt="user avatar"
          id="avatar"
          on:change={handleFileChange}
        />
        <button on:click={handleUploadAvatar}>Upload Avatar</button>

        {#if avatarUrl}
          <p>Avatar uploaded:</p>
          <img
            src={avatarUrl}
            alt="User Avatar"
            style="width: 100px; height: 100px;"
          />
        {/if}

        <input
          type="text"
          id="variant"
          placeholder="variant"
          bind:value={variant}
        />

        {#if errorMessage}
          <p class="error">{errorMessage}</p>
        {/if}

        {#if successMessage}
          <p class="success">{successMessage}</p>
        {/if}

        <div class="button-container">
          <button
            class="cta-button mint-button"
            on:click={handleSetRecord}
            disabled={loading}
          >
            {loading ? "Updating..." : "Set Data"}
          </button>
        </div>
      </div>
    {/if}

    <div class="footer-container">
      <a
        class="footer-text"
        href={TWITTER_LINK}
        target="_blank"
        rel="noreferrer"
      >
        built with @{TWITTER_HANDLE}
      </a>
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

  .error {
    color: red;
    font-size: 14px;
    margin-top: 10px;
  }

  .success {
    color: green;
    font-size: 14px;
    margin-top: 10px;
  }
</style>
