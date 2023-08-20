require("dotenv").config();

const PRIVATE_KEY = process.env.PRIVATE_KEY;

const networks = {
  goerli: {
    url: process.env.GOERLI_RPC_URL || "UNSET",
    gasPrice: undefined,
    accounts: PRIVATE_KEY !== undefined ? [PRIVATE_KEY] : [],
    verifyApiKey: process.env.ETHERSCAN_API_KEY || "UNSET",
    chainId: 5,
    nativeCurrencySymbol: "ETH",
    WAIT_BLOCK_CONFIRMATIONS: 3,
  },
  polygonMumbai: {
    url: process.env.POLYGON_MUMBAI_RPC_URL || "UNSET",
    gasPrice: undefined,
    accounts: PRIVATE_KEY !== undefined ? [PRIVATE_KEY] : [],
    verifyApiKey: process.env.POLYGONSCAN_API_KEY || "UNSET",
    chainId: 80001,
    nativeCurrencySymbol: "MATIC",
    WAIT_BLOCK_CONFIRMATIONS: 5,
  },
  optimisticGoerli: {
    url: process.env.OPTIMISM_GOERLI_RPC_URL || "UNSET",
    gasPrice: undefined,
    accounts: PRIVATE_KEY !== undefined ? [PRIVATE_KEY] : [],
    verifyApiKey: process.env.OPTIMISTIC_API_KEY || "UNSET",
    chainId: 420,
    WAIT_BLOCK_CONFIRMATIONS: 5,
  },
};

module.exports = {
  networks,
};
