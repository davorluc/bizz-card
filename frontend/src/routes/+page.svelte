<script>
  import { onMount } from "svelte";

  // Constant
  const TWITTER_HANDLE = "puskaimdzep";
  const TWITTER_LINK = `https://twitter.com/${TWITTER_HANDLE}`;
  let walletConnected = false;

  // Check if the wallet is connected
  const checkIfWalletIsConnected = () => {
    // Make sure we have access to window.ethereum
    const { ethereum } = window;

    if (!ethereum) {
      console.log("Make sure you have MetaMask!");
    } else {
      console.log("We have the ethereum object", ethereum);
      walletConnected = true;
    }
  };

  // Call checkIfWalletIsConnected when the component is mounted
  onMount(() => {
    checkIfWalletIsConnected();
  });

  // Render wallet not connected view
  const renderNotConnectedContainer = () => {
    return `
      <div class="connect-wallet-container">
        <img src="https://media.giphy.com/media/3ohhwytHcusSCXXOUg/giphy.gif" alt="Ninja gif" />
        <button class="cta-button connect-wallet-button">
          Connect Wallet
        </button>
      </div>
    `;
  };
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

    <!-- Add your render method here -->
    {#if !walletConnected}
      {@html renderNotConnectedContainer()}
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
