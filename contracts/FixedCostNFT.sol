// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import "./IERC2309.sol";
import "./ERC721.sol";

contract FixedCostNFT is ERC721, IERC2309 {
    
    struct TokenOwner {
        bool transferred;
        address ownerAddress;
    }

    struct CollectionStatus {        
        bool isMinted;
        uint88 amountCreated;
        address defaultOwner;
    }    
    
    CollectionStatus internal collectionStatus;

    // Mapping from token ID to owner address and a flag on whether it has left original default owner wallet   
    mapping(uint256 => TokenOwner) internal ownersOptimized;     

    constructor(address defaultOwner_, string memory name_, string memory symbol_) 
    ERC721(name_, symbol_) {
        collectionStatus.defaultOwner = defaultOwner_;
    }

    function getCollectionStatus() public view virtual returns (CollectionStatus memory) {
        return collectionStatus;
    }
 
    function ownerOf(uint256 tokenId) public view virtual override returns (address owner) {
        require(_isValidTokenId(tokenId), "Token does not exist");
        owner = ownersOptimized[tokenId].transferred ? ownersOptimized[tokenId].ownerAddress : collectionStatus.defaultOwner;
        require(owner != address(0), "Token does not exist");
    }        

    function mint(uint256 amount) external {        
        require(amount > 0, "Cannot mint zero NFTs");                
        require(!collectionStatus.isMinted, "NFTs already minted");
        require(collectionStatus.defaultOwner != address(0), "ERC721: transfer to the zero address");
        
        _balances[collectionStatus.defaultOwner] += amount;        
        collectionStatus.amountCreated += uint88(amount);        
        collectionStatus.isMinted = true;

        emit ConsecutiveTransfer(1, amount, address(0), collectionStatus.defaultOwner);
    }  

    function exists(uint256 tokenId) public view returns (bool) {
        return _exists(tokenId);
    }    

    function burn(uint256 tokenId) public {
        _burn(tokenId);
    }      
    
    function _exists(uint256 tokenId) internal view virtual override returns (bool) {
        if(_isValidTokenId(tokenId)) {            
            return ownersOptimized[tokenId].ownerAddress != address(0) || !ownersOptimized[tokenId].transferred;
        }
        return false;   
    }
    
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual override returns (address owner, bool isApprovedOrOwner) {
        owner = ownerOf(tokenId);
        isApprovedOrOwner = (spender == owner || _tokenApprovals[tokenId] == spender || isApprovedForAll(owner, spender));
    }       

    function _clearOwnership(uint256 tokenId) internal virtual override {
        ownersOptimized[tokenId].transferred = true;
        ownersOptimized[tokenId].ownerAddress = address(0);
    }

    function _setOwnership(address to, uint256 tokenId) internal virtual override {
        ownersOptimized[tokenId].transferred = true;
        ownersOptimized[tokenId].ownerAddress = to;
    }               

    function _isValidTokenId(uint256 tokenId) internal view returns (bool) {        
        return tokenId > 0 && tokenId <= collectionStatus.amountCreated;
    }        
}