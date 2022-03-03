/**
 * @type import('hardhat/config').HardhatUserConfig
 */

 const fs = require('fs');
 require("@nomiclabs/hardhat-etherscan");
 require("@nomiclabs/hardhat-truffle5");
 require("@nomiclabs/hardhat-waffle");
 require('dotenv').config();
 require("@nomiclabs/hardhat-ethers");
 require("hardhat-gas-reporter");
 require('hardhat-contract-sizer');
 require('solidity-coverage');
 
 const mnemonic = fs.readFileSync('mnemonic', 'utf-8');
 
 module.exports = {
 
    solidity: {
         version: "0.8.9",
         settings: {
             optimizer: {
                 enabled: true,
                 runs: 1500
             },
         },
    },
    defaultNetwork: "hardhat",
    networks: {
       hardhat: {},
       ganache: {                  
         url: `http://127.0.0.1:8545`
      }
   },   
   gasReporter: {
    enabled: true
   },
   mocha: {
      timeout: 1200000
    }
 }