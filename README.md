# fixed-cost-nft-mint

An example of how to make a fixed-cost minting smart contract.  The code in this repo contains a derivative of the OpenZeppelin ERC721 contract that has been optimized for Fixed-Cost Minting of an NFT project.

## Gas Usage

The gas usage as measured by a simple test suite.  3 runs were performed - minting for 1/1, 100/100, and 1000/1000 collections.  No matter how many NFTs were minted, mint costs were 52,000 gas.

```
  Contract: ERC721
    minting only
      ✓ measure minting costs
    after mint reserved collection
      ✓ measure transferFrom gas (withdraw from omnibus)
      ✓ measure safeTransferFrom gas (withdraw from omnibus)
      ✓ measure approve gas (approve entire collection from omnibus)
      ✓ measure burn gas (burn entire collection from omnibus)
    after all tokens withdrawn to users
      ✓ measure transferFrom gas (withdraw from omnibus)
      ✓ measure safeTransferFrom gas (withdraw from omnibus)
      ✓ measure approve gas (approve entire collection from omnibus)
      ✓ measure burn gas (burn entire collection from omnibus)
    minting only
      ✓ measure minting costs
    after mint reserved collection
      ✓ measure transferFrom gas (withdraw from omnibus)
      ✓ measure safeTransferFrom gas (withdraw from omnibus)
      ✓ measure approve gas (approve entire collection from omnibus)
      ✓ measure burn gas (burn entire collection from omnibus)
    after all tokens withdrawn to users
      ✓ measure transferFrom gas (withdraw from omnibus)
      ✓ measure safeTransferFrom gas (withdraw from omnibus)
      ✓ measure approve gas (approve entire collection from omnibus)
      ✓ measure burn gas (burn entire collection from omnibus)
    minting only
      ✓ measure minting costs
    after mint reserved collection
      ✓ measure transferFrom gas (withdraw from omnibus)
      ✓ measure safeTransferFrom gas (withdraw from omnibus)
      ✓ measure approve gas (approve entire collection from omnibus)
      ✓ measure burn gas (burn entire collection from omnibus)
    after all tokens withdrawn to users
      ✓ measure transferFrom gas (withdraw from omnibus)
      ✓ measure safeTransferFrom gas (withdraw from omnibus)
      ✓ measure approve gas (approve entire collection from omnibus)
      ✓ measure burn gas (burn entire collection from omnibus)
gasUsed transferFrom (omnibus) (samples = 1101)
  min. = 59300
  max. = 81200
  avg. = 64142
  dev. = 842
  sum. = 70619904
gasUsed safeTransferFrom (omnibus) (samples = 1101)
  min. = 62154
  max. = 84054
  avg. = 66996
  dev. = 842
  sum. = 73762158
gasUsed approve (omnibus) (samples = 1101)
  min. = 50897
  max. = 50909
  avg. = 50905
  dev. = 6
  sum. = 56046501
gasUsed burn (omnibus) (samples = 1101)
  min. = 52992
  max. = 57804
  avg. = 57787
  dev. = 251
  sum. = 63623496
gasUsed transferFrom (users) (samples = 1101)
  min. = 42244
  max. = 64144
  avg. = 47086
  dev. = 842
  sum. = 51841248
gasUsed safeTransferFrom (users) (samples = 1101)
  min. = 45098
  max. = 66998
  avg. = 49940
  dev. = 842
  sum. = 54983502
gasUsed approve (users) (samples = 1101)
  min. = 50941
  max. = 50953
  avg. = 50949
  dev. = 6
  sum. = 56094945
gasUsed burn (users) (samples = 1101)
  min. = 35948
  max. = 40760
  avg. = 40743
  dev. = 251
  sum. = 44858052

·-------------------------------------|---------------------------|--------------|-----------------------------·
|         Solc version: 0.8.9         ·  Optimizer enabled: true  ·  Runs: 1500  ·  Block limit: 30000000 gas  │
······································|···························|··············|······························
|  Methods                                                                                                     │
·················|····················|·············|·············|··············|···············|··············
|  Contract      ·  Method            ·  Min        ·  Max        ·  Avg         ·  # calls      ·  eur (avg)  │
·················|····················|·············|·············|··············|···············|··············
|  FixedCostNFT  ·  approve           ·      50897  ·      50953  ·       50927  ·         2202  ·          -  │
·················|····················|·············|·············|··············|···············|··············
|  FixedCostNFT  ·  burn              ·      35948  ·      57804  ·       49265  ·         2202  ·          -  │
·················|····················|·············|·············|··············|···············|··············
|  FixedCostNFT  ·  mint              ·      52010  ·      52022  ·       52014  ·           27  ·          -  │
·················|····················|·············|·············|··············|···············|··············
|  FixedCostNFT  ·  safeTransferFrom  ·      45098  ·      84054  ·       58468  ·         2202  ·          -  │
·················|····················|·············|·············|··············|···············|··············
|  FixedCostNFT  ·  transferFrom      ·      42244  ·      81200  ·       61299  ·         6606  ·          -  │
·················|····················|·············|·············|··············|···············|··············
|  Deployments                        ·                                          ·  % of limit   ·             │
······································|·············|·············|··············|···············|··············
|  FixedCostNFT                       ·          -  ·          -  ·     1535806  ·        5.1 %  ·          -  │
·-------------------------------------|-------------|-------------|--------------|---------------|-------------·

  27 passing (7m)
```
