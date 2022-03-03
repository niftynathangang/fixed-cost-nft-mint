const { BN } = require("@openzeppelin/test-helpers");
const GasStats = require("./gasStats");
const txGasStats = GasStats.newStats();

const FixedCostNFT = artifacts.require('FixedCostNFT');

async function transferAllToNewOwner(erc721Token, numberOfTokens, fromAccount, toAccount, measureGas, gasFunctionSummary) {
  const collectGasStats = GasStats.makeCollector(txGasStats);
  for(let i = 1; i <= numberOfTokens.toNumber(); i++) {
    const tokenId = new BN(`${i}`);
    const result = await erc721Token.transferFrom(fromAccount, toAccount, tokenId, {from: fromAccount});        
    if(measureGas) {
      collectGasStats(gasFunctionSummary, result);
    }
  }      
}

async function safeTransferAllToNewOwner(erc721Token, numberOfTokens, fromAccount, toAccount, measureGas, gasFunctionSummary) {
  const collectGasStats = GasStats.makeCollector(txGasStats);
  for(let i = 1; i <= numberOfTokens.toNumber(); i++) {
    const tokenId = new BN(`${i}`);
    const result = await erc721Token.methods['safeTransferFrom(address,address,uint256)'](fromAccount, toAccount, tokenId, {from: fromAccount});
    if(measureGas) {
      collectGasStats(gasFunctionSummary, result);
    }
  }      
}

async function burnAll(erc721Token, numberOfTokens, ownerAccount, measureGas, gasFunctionSummary) {
  const collectGasStats = GasStats.makeCollector(txGasStats);
  for(let i = 1; i <= numberOfTokens.toNumber(); i++) {
    const tokenId = new BN(`${i}`);
    const result = await erc721Token.burn(tokenId, {from: ownerAccount});        
    if(measureGas) {
      collectGasStats(gasFunctionSummary, result);
    }
  }      
}

async function approveAll(erc721Token, numberOfTokens, ownerAccount, spenderAccount, measureGas, gasFunctionSummary) {
  const collectGasStats = GasStats.makeCollector(txGasStats);
  for(let i = 1; i <= numberOfTokens.toNumber(); i++) {
    const tokenId = new BN(`${i}`);
    const result = await erc721Token.approve(spenderAccount, tokenId, {from: ownerAccount});        
    if(measureGas) {
      collectGasStats(gasFunctionSummary, result);
    }
  }      
}

function measureGasUsageERC721Operations(name, symbol, reservationSize, omnibus, userAccounts) {
  context('minting only', function() {
    beforeEach(async function () {      
      token = await FixedCostNFT.new(omnibus, name, symbol);      
    });      
    
    it('measure minting costs', async function () {                  
      await token.mint(reservationSize);
    });
  });  

  context('after mint reserved collection', function() {
    beforeEach(async function () {            
      token = await FixedCostNFT.new(omnibus, name, symbol);    
      await token.mint(reservationSize);
    });
    
    it('measure transferFrom gas (withdraw from omnibus)', async function () {            
      await transferAllToNewOwner(token, reservationSize, omnibus, userAccounts[1], true, "transferFrom (omnibus)");      
    });

    it('measure safeTransferFrom gas (withdraw from omnibus)', async function () {      
      await safeTransferAllToNewOwner(token, reservationSize, omnibus, userAccounts[1], true, "safeTransferFrom (omnibus)");      
    });

    it('measure approve gas (approve entire collection from omnibus)', async function () {      
      await approveAll(token, reservationSize, omnibus, userAccounts[1], true, "approve (omnibus)");      
    });

    it('measure burn gas (burn entire collection from omnibus)', async function () {      
      await burnAll(token, reservationSize, omnibus, true, "burn (omnibus)");      
    });
  });

  context('after all tokens withdrawn to users', function() {
    beforeEach(async function () {      
        token = await FixedCostNFT.new(omnibus, name, symbol);    
        await token.mint(reservationSize);
        await transferAllToNewOwner(token, reservationSize, omnibus, userAccounts[1], false, "transferFrom (ignore)");
    });       
    
    it('measure transferFrom gas (withdraw from omnibus)', async function () {      
      await transferAllToNewOwner(token, reservationSize, userAccounts[1], userAccounts[2], true, "transferFrom (users)");      
    });

    it('measure safeTransferFrom gas (withdraw from omnibus)', async function () {      
      await safeTransferAllToNewOwner(token, reservationSize, userAccounts[1], userAccounts[2], true, "safeTransferFrom (users)");      
    });

    it('measure approve gas (approve entire collection from omnibus)', async function () {      
      await approveAll(token, reservationSize, userAccounts[1], userAccounts[2], true, "approve (users)");      
    });

    it('measure burn gas (burn entire collection from omnibus)', async function () {      
      await burnAll(token, reservationSize, userAccounts[1], true, "burn (users)");      
    });
  });  
}

contract('FixedCostNFT', function (accounts) {  
  const name = 'Non Fungible Token';
  const symbol = 'NFT';
  const omnibus = accounts[0];    
  
  after("emit gas stats", function () {
    GasStats.toConsoleLog(txGasStats);
  });

  measureGasUsageERC721Operations(name, symbol, new BN('1'), omnibus, accounts);  
  measureGasUsageERC721Operations(name, symbol, new BN('100'), omnibus, accounts);  
  measureGasUsageERC721Operations(name, symbol, new BN('1000'), omnibus, accounts);  
});