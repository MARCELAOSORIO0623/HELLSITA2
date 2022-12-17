require('dotenv').config()
const HDWalletProvider = require('@truffle/hdwallet-provider');

const fs = require('fs');

module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "*",
    },
    goerli: {
      provider: function () {
        return new HDWalletProvider(process.env.PRIVATE_KEY, process.env.GOERLI_RPC_URL);
      },
      network_id: 5,
      gas: 4000000,
      networkCheckTimeout: 10000
    }
  },
  mocha: {
  },
  compilers: {
    solc: {
      version: "0.8.16",
    }
  },
  db: {
    enabled: false
  }
};