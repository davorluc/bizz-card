<script>
  import { onMount } from "svelte";
  import { ethers } from "ethers";

  // Constant
  const TWITTER_HANDLE = "puskaimdzep";
  const TWITTER_LINK = `https://twitter.com/${TWITTER_HANDLE}`;
  const tld = ".bizz";

  // States
  let currentAccount = "";
  let domain = "";
  let loading = false;
  let record = "";

  const connectWallet = async () => {
    try {
      const { ethereum } = window;

      if (!ethereum) {
        alert("Get MetaMask -> https://metamask.io/");
        return;
      }

      // Fancy method to request access to account.
      const accounts = await ethereum.request({
        method: "eth_requestAccounts",
      });

      // Boom! This should print out public address once we authorize Metamask.
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
    } else {
      console.log("We have the ethereum object", ethereum);
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

  onMount(() => {
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
        <img
          src="https://media4.giphy.com/media/v1.Y2lkPTc5MGI3NjExa2hvbnFrMjBmamt4YTNpZHAzbmRlMWVyczZncGpmMjBmOTZvYThkdCZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/Jq1T4jCKm9039q2lEV/giphy.gif"
          alt="American Psycho Business Card Scene Gif"
        />
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
          type="text"
          placeholder="whats ur ninja power"
          bind:value={record}
        />

        <div class="button-container">
          <button
            class="cta-button mint-button"
            disabled={null}
            on:click={null}
          >
            Mint
          </button>
          <button
            class="cta-button mint-button"
            disabled={null}
            on:click={null}
          >
            Set data
          </button>
        </div>
      </div>
    {/if}

    <div class="footer-container">
      <img alt="Twitter Logo" class="twitter-logo" src="/logos/x.svg" />
      <a
        class="footer-text"
        href={TWITTER_LINK}
        target="_blank"
        rel="noreferrer"
      >
        {`built with @${TWITTER_HANDLE}`}
      </a>
    </div>
  </div>
</div>

<style>
  /* Add your CSS styles here or import them */
  .connect-wallet-container {
    text-align: center;
  }

  .cta-button {
    background-color: #ff6700;
    color: white;
    padding: 12px 24px;
    border: none;
    cursor: pointer;
    border-radius: 8px;
  }

  .footer-container {
    display: flex;
    justify-content: center;
    padding: 10px;
  }

  .twitter-logo {
    width: 20px;
    height: 20px;
    margin-right: 8px;
  }

  .footer-text {
    color: #1da1f2;
    text-decoration: none;
    font-size: 14px;
  }
</style>
