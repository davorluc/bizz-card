<script lang="ts">
  import { onMount } from "svelte";
  import { connectWallet, getCurrentAccount } from "$lib/wallet";
  import "../app.css";

  let currentAccount: string = "";

  const handleConnect = async () => {
    try {
      currentAccount = await connectWallet();
    } catch (error) {
      console.error(error);
      alert((error as Error).message);
    }
  };

  onMount(async () => {
    const account = await getCurrentAccount();
    if (account) {
      currentAccount = account;
    }
  });
</script>

<main>
  <div class="container mx-auto px-4 py-12">
    <!-- Wallet Connection Section -->
    <section class="mb-16 text-center">
      <h1 class="text-4xl md:text-5xl font-bold mb-6 gradient-text">
        Web3 Identity Hub
      </h1>
      <p class="text-lg text-gray-300 mb-8 max-w-2xl mx-auto">
        Connect your wallet to unlock your decentralized identity and networking
        tools
      </p>

      <div class="max-w-md mx-auto glass-card rounded-xl p-8 shadow-lg">
        <div class="flex flex-col items-center">
          <div
            class="w-20 h-20 rounded-full bg-gradient-to-br from-blue-500 to-purple-600 mb-6 flex items-center justify-center"
          >
            <i class="fas fa-wallet text-3xl text-white"></i>
          </div>

          {#if !currentAccount}
            <h3 class="text-xl font-semibold mb-4">Connect Your Wallet</h3>
            <p class="text-gray-400 mb-6 text-sm">
              Choose your preferred wallet provider to continue
            </p>

            <div class="w-full space-y-3">
              <button
                class="wallet-btn w-full py-3 px-6 rounded-lg font-medium flex items-center justify-center gap-3"
                on:click={handleConnect}
              >
                <i class="fab fa-ethereum"></i>
                MetaMask
              </button>
              <button
                class="wallet-btn w-full py-3 px-6 rounded-lg font-medium flex items-center justify-center gap-3"
                id="walletConnect-btn"
              >
                <i class="fas fa-bolt"></i>
                WalletConnect
              </button>
              <button
                class="wallet-btn w-full py-3 px-6 rounded-lg font-medium flex items-center justify-center gap-3"
                id="coinbaseWallet-btn"
              >
                <i class="fab fa-bitcoin"></i>
                Coinbase Wallet
              </button>
            </div>

            <p class="text-xs text-gray-500 mt-6">
              By connecting, you agree to our <a
                href="#"
                class="text-blue-400 hover:underline">Terms</a
              >
              and
              <a href="#" class="text-blue-400 hover:underline"
                >Privacy Policy</a
              >
            </p>
          {:else}
            <p>Connected Wallet: {currentAccount}</p>
          {/if}
        </div>
      </div>
    </section>

    <!-- Business Card Section -->
    <section class="max-w-6xl mx-auto mt-20">
      <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
        <!-- Business Card Image (Left Side) -->
        <div class="business-card rounded-2xl p-8 h-full">
          <div class="flex flex-col h-full">
            <div class="flex items-center mb-8">
              <div
                class="w-16 h-16 rounded-full bg-gradient-to-br from-blue-500 to-purple-600 flex items-center justify-center mr-4"
              >
                <span class="text-2xl font-bold text-white">JD</span>
              </div>
              <div>
                <h2 class="text-2xl font-bold">John Doe</h2>
                <p
                  class="text-transparent bg-clip-text bg-gradient-to-r from-blue-400 to-purple-500"
                >
                  Web3 Developer
                </p>
              </div>
            </div>

            <div class="mb-8">
              <h3 class="text-lg font-semibold mb-3">About</h3>
              <p class="text-gray-300">
                Blockchain architect with 5+ years building decentralized
                systems. Passionate about smart contract security and composable
                DeFi protocols.
              </p>
            </div>

            <div class="mb-8">
              <h3 class="text-lg font-semibold mb-3">Skills</h3>
              <div class="flex flex-wrap gap-2">
                <span class="px-3 py-1 skill-tag rounded-full text-sm"
                  >Solidity</span
                >
                <span class="px-3 py-1 skill-tag rounded-full text-sm"
                  >Rust</span
                >
                <span class="px-3 py-1 skill-tag rounded-full text-sm"
                  >ZK Proofs</span
                >
                <span class="px-3 py-1 skill-tag rounded-full text-sm"
                  >React</span
                >
                <span class="px-3 py-1 skill-tag rounded-full text-sm"
                  >Subgraphs</span
                >
              </div>
            </div>

            <div class="mt-auto">
              <div class="qr-code">
                <!-- Placeholder for QR code -->
                <div
                  class="w-32 h-32 bg-gray-200 flex items-center justify-center"
                >
                  <span class="text-gray-600 text-xs">QR Code</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Contact Information (Right Side) -->
        <div class="contact-box rounded-2xl p-8 h-full">
          <h2 class="text-2xl font-bold mb-6 gradient-text">
            Contact Information
          </h2>

          <div class="space-y-6">
            <div class="flex items-start">
              <div
                class="w-10 h-10 rounded-full bg-gradient-to-br from-blue-500 to-purple-600 flex items-center justify-center mr-4 flex-shrink-0"
              >
                <i class="fas fa-user text-white text-sm"></i>
              </div>
              <div>
                <h3 class="font-semibold">Full Name</h3>
                <p class="text-gray-300">John Doe</p>
              </div>
            </div>

            <div class="flex items-start">
              <div
                class="w-10 h-10 rounded-full bg-gradient-to-br from-blue-500 to-purple-600 flex items-center justify-center mr-4 flex-shrink-0"
              >
                <i class="fas fa-envelope text-white text-sm"></i>
              </div>
              <div>
                <h3 class="font-semibold">Email</h3>
                <p class="text-gray-300">john.doe@web3dev.com</p>
              </div>
            </div>

            <div class="flex items-start">
              <div
                class="w-10 h-10 rounded-full bg-gradient-to-br from-blue-500 to-purple-600 flex items-center justify-center mr-4 flex-shrink-0"
              >
                <i class="fab fa-linkedin-in text-white text-sm"></i>
              </div>
              <div>
                <h3 class="font-semibold">LinkedIn</h3>
                <p class="text-gray-300">linkedin.com/in/johndoe-web3</p>
              </div>
            </div>

            <div class="flex items-start">
              <div
                class="w-10 h-10 rounded-full bg-gradient-to-br from-blue-500 to-purple-600 flex items-center justify-center mr-4 flex-shrink-0"
              >
                <i class="fab fa-github text-white text-sm"></i>
              </div>
              <div>
                <h3 class="font-semibold">GitHub</h3>
                <p class="text-gray-300">github.com/johndoe-web3</p>
              </div>
            </div>

            <div class="flex items-start">
              <div
                class="w-10 h-10 rounded-full bg-gradient-to-br from-blue-500 to-purple-600 flex items-center justify-center mr-4 flex-shrink-0"
              >
                <i class="fab fa-twitter text-white text-sm"></i>
              </div>
              <div>
                <h3 class="font-semibold">Twitter</h3>
                <p class="text-gray-300">@johndoe_web3</p>
              </div>
            </div>

            <div class="divider my-4"></div>

            <div class="flex items-start">
              <div
                class="w-10 h-10 rounded-full bg-gradient-to-br from-blue-500 to-purple-600 flex items-center justify-center mr-4 flex-shrink-0"
              >
                <i class="fas fa-wallet text-white text-sm"></i>
              </div>
              <div>
                <h3 class="font-semibold">Wallet Address</h3>
                <p class="text-gray-300 font-mono text-sm break-all">
                  0x71C7656EC7ab88b098defB751B7401B5f6d8976F
                </p>
              </div>
            </div>

            <div class="flex items-start">
              <div
                class="w-10 h-10 rounded-full bg-gradient-to-br from-blue-500 to-purple-600 flex items-center justify-center mr-4 flex-shrink-0"
              >
                <i class="fas fa-link text-white text-sm"></i>
              </div>
              <div>
                <h3 class="font-semibold">ENS</h3>
                <p class="text-gray-300">johndoe.eth</p>
              </div>
            </div>

            <div class="flex items-start">
              <div
                class="w-10 h-10 rounded-full bg-gradient-to-br from-blue-500 to-purple-600 flex items-center justify-center mr-4 flex-shrink-0"
              >
                <i class="fas fa-coins text-white text-sm"></i>
              </div>
              <div>
                <h3 class="font-semibold">Tokens</h3>
                <p class="text-gray-300">ETH, USDC, DAI</p>
              </div>
            </div>
          </div>

          <div class="mt-8 pt-6 border-t border-gray-800">
            <button class="wallet-btn w-full py-3 px-6 rounded-lg font-medium">
              <i class="fas fa-share-alt mr-2"></i> Share Profile
            </button>
          </div>
        </div>
      </div>
    </section>
  </div>
</main>

<style>
  @import url("https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@300;400;500;600;700&display=swap");

  main {
    font-family: "Space Grotesk", sans-serif;
    background-color: #0a0a0a;
    color: #f8fafc;
    background-image: radial-gradient(
        at 80% 0%,
        hsla(189, 100%, 56%, 0.15) 0px,
        transparent 50%
      ),
      radial-gradient(
        at 0% 50%,
        hsla(355, 100%, 93%, 0.15) 0px,
        transparent 50%
      );
  }

  .glass-card {
    background: rgba(15, 23, 42, 0.7);
    backdrop-filter: blur(10px);
    border: 1px solid rgba(255, 255, 255, 0.1);
    box-shadow: 0 8px 32px 0 rgba(31, 38, 135, 0.15);
  }

  .wallet-btn {
    transition: all 0.3s ease;
    background: linear-gradient(90deg, #3b82f6 0%, #8b5cf6 100%);
  }

  .wallet-btn:hover {
    transform: translateY(-2px);
    box-shadow: 0 5px 15px rgba(59, 130, 246, 0.4);
  }

  .business-card {
    background: linear-gradient(
      145deg,
      rgba(30, 41, 59, 0.8) 0%,
      rgba(15, 23, 42, 0.9) 100%
    );
    border: 1px solid rgba(255, 255, 255, 0.1);
    box-shadow: 0 10px 25px rgba(0, 0, 0, 0.3);
  }

  .contact-box {
    background: rgba(15, 23, 42, 0.7);
    backdrop-filter: blur(10px);
    border: 1px solid rgba(255, 255, 255, 0.1);
  }

  .gradient-text {
    background: linear-gradient(90deg, #3b82f6, #8b5cf6, #ec4899);
    -webkit-background-clip: text;
    background-clip: text;
    color: transparent;
  }

  .skill-tag {
    background: rgba(30, 41, 59, 0.8);
    border: 1px solid rgba(255, 255, 255, 0.1);
  }

  .qr-code {
    background: rgba(255, 255, 255, 0.9);
    padding: 12px;
    border-radius: 8px;
    display: inline-block;
  }

  .divider {
    height: 1px;
    background: linear-gradient(
      90deg,
      transparent,
      rgba(255, 255, 255, 0.2),
      transparent
    );
  }

  #walletConnect-btn,
  #coinbaseWallet-btn {
    display: none;
  }
</style>
