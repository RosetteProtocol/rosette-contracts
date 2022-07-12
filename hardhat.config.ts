import "dotenv/config";
import { HardhatUserConfig } from "hardhat/types";

import "@nomiclabs/hardhat-ethers";
import * as tdly from "@tenderly/hardhat-tenderly";
import "hardhat-deploy";

import { node_url, accounts, addForkConfiguration } from "./utils/network";

tdly.setup();

const defaultNetwork = "hardhat";

const config: HardhatUserConfig = {
  defaultNetwork,
  solidity: {
    compilers: [
      {
        version: "0.8.13",
        settings: {
          optimizer: {
            enabled: true,
            runs: 10000,
          },
        },
      },
    ],
  },
  namedAccounts: {
    deployer: 0,
  },
  networks: addForkConfiguration({
    hardhat: {
      initialBaseFeePerGas: 0, // to fix : https://github.com/sc-forks/solidity-coverage/issues/652, see https://github.com/sc-forks/solidity-coverage/issues/652#issuecomment-896330136
    },
    localhost: {
      url: node_url("localhost"),
      accounts: accounts(),
    },
    goerli: {
      url: node_url("goerli"),
      accounts: accounts("goerli"),
    },
    xdai: {
      url: node_url("xdai"),
      gasPrice: 1000000000,
      accounts: accounts("xdai"),
    },
  }),
  paths: {
    sources: "src",
  },
  tenderly: {
    project: "rosette-contracts",
    username: process.env.TENDERLY_USERNAME as string,
  },
};

export default config;
