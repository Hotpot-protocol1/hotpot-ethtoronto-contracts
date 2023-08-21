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
  avalancheFujiTestnet: {
    url: process.env.AVALANCHE_FUJI_RPC_URL || "UNSET",
    gasPrice: undefined,
    accounts: PRIVATE_KEY !== undefined ? [PRIVATE_KEY] : [],
    verifyApiKey: process.env.AVALANCHE_API_KEY || "UNSET",
    chainId: 43113,
    WAIT_BLOCK_CONFIRMATIONS: 5,
    AXELAR_GATEWAY: "0xC249632c2D40b9001FE907806902f63038B737Ab",
    AXELAR_GAS_SERVICE: "0xbE406F0189A0B4cf3A05C286473D23791Dd44Cc6",
    AXELAR_WRAPPED_NATIVE_TOKEN: "0xd00ae08403B9bbb9124bB305C09058E32C39A48c",
    WRAPPED_TOKEN_SYMBOL: "WAVAX",
  },
  baseGoerliTestnet: {
    url: process.env.BASE_GOERLI_RPC_URL || "UNSET",
    gasPrice: undefined,
    accounts: PRIVATE_KEY !== undefined ? [PRIVATE_KEY] : [],
    verifyApiKey: process.env.BASE_GOERLI_API_KEY || "UNSET",
    chainId: 84531,
    nativeCurrencySymbol: "ETH",
    WAIT_BLOCK_CONFIRMATIONS: 5,
    AXELAR_GATEWAY: "0xe432150cce91c13a887f7D836923d5597adD8E31",
    AXELAR_GAS_SERVICE: "0xbE406F0189A0B4cf3A05C286473D23791Dd44Cc6",
    AXELAR_WRAPPED_NATIVE_TOKEN: "0x254d06f33bDc5b8ee05b2ea472107E300226659A",
    WRAPPED_TOKEN_SYMBOL: "aUSDC",
    EAS: "0xAcfE09Fd03f7812F022FBf636700AdEA18Fd2A7A",
  },
};

module.exports = {
  networks,
};
