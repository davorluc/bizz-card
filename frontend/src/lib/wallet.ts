// src/lib/wallet.ts
import { ethers } from "ethers";

declare global {
  interface Window {
    ethereum?: any;
  }
}

/**
 * Requests connection to the user's wallet.
 * @returns The connected account address, or throws an error.
 */
export const connectWallet = async (): Promise<string> => {
  const { ethereum } = window;

  if (!ethereum) {
    throw new Error("MetaMask not installed.");
  }

  const accounts = await ethereum.request({ method: "eth_requestAccounts" });

  if (!accounts || accounts.length === 0) {
    throw new Error("No accounts found.");
  }

  return accounts[0];
};

/**
 * Checks if a wallet is already connected.
 * @returns The connected account address, or null if not connected.
 */
export const getCurrentAccount = async (): Promise<string | null> => {
  const { ethereum } = window;

  if (!ethereum) {
    console.warn("MetaMask not installed.");
    return null;
  }

  const accounts = await ethereum.request({ method: "eth_accounts" });

  if (accounts.length > 0) {
    return accounts[0];
  } else {
    return null;
  }
};
