// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 * @dev Please notice that this contract is a very lightly modified version of the openzeppelin ERC-721 contract.
 *      Variations are noted in detailed comments throughout the contract.  Here is a summary of changes.
 *
 *      1. Change private contract variables (_name, _symbol, _owners, _balances, _tokenApprovals, _operatorApprovals) to 
           internal so inheriting contracts have access.
 *      2. Removed _mint/_safeMint functions.  This contract is going to be used as the basis of a Fixed Cost Mint contract.
 *      3. Removed _beforeTokenTransfer and _afterTokenTransfer calls - the are not needed for this example.
 *      4. Added _clearApproval, _clearOwnership, and _setOwnership functions.
 *      5. Modified transferFrom implementation.  See detailed comments below.
 *      6. Modified safeTransferFrom implementation.  See detailed comments below.
 *      7. Modified _burn implementation.  See detailed comments below.
 *      8. Modified _isApprovedOrOwner implementation.  See detailed comments below.
 *      9. Modified _transfer implementation.  See detailed comments below.
 */
contract ERC721 is Context, ERC165, IERC721Metadata {
    using Address for address;
    using Strings for uint256;    

    // Token name
    string internal _name;

    // Token symbol
    string internal _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) internal _owners;

    // Mapping owner address to token count
    mapping(address => uint256) internal _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) internal _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) internal _operatorApprovals;    

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }    

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */    
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */    
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */    
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */     
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overriden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */    
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()), 
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(owner, to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */    
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */    
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */    
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     * @dev Please notice that transferFrom is slightly modified from the openzeppelin implementation.
     *      The contract has been modified such that _isApprovedOrOwner returns the owner address.
     *      The owner is now passed in to the _transfer functionso that we don't have to read the owner twice.
     *      This optimization conserves a little bit of gas.
     *      The openzeppelin version is shown commented out below fo comparison.
     */    
    function transferFrom(address from, address to, uint256 tokenId) public virtual override {        
        (address owner, bool isApprovedOrOwner) = _isApprovedOrOwner(_msgSender(), tokenId);
        require(isApprovedOrOwner, "ERC721: transfer caller is not owner nor approved");
        _transfer(owner, from, to, tokenId);
    }

    //function transferFrom(address from, address to, uint256 tokenId) public virtual override {        
    //    require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
    //    _transfer(from, to, tokenId);
    //}

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */    
    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
       @dev Please notice that safeTransferFrom is slightly modified from the openzeppelin implementation.
            In this version it calls through the same logic as transferFrom, followed by the ERC721 Receiver Check.
            The openzeppelin version is shown commented out below fo comparison.
     */         
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public virtual override {
        transferFrom(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, data), "ERC721: transfer to non ERC721Receiver implementer");
    }    

    //function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public virtual override {
    //    require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
    //    _safeTransfer(from, to, tokenId, _data);
    //}

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     * @dev Please notice that _isApprovedOrOwner is slightly modified from the openzeppelin implementation.
     *      The contract has been modified such that _isApprovedOrOwner returns the owner address so that
     *      code downstream does not have to read the owner twice. This optimization conserves a little bit of gas.     
     *      The openzeppelin version is shown commented out below fo comparison.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */    
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (address owner, bool isApprovedOrOwner) {
        owner = _owners[tokenId];
        require(owner != address(0), "ERC721: operator query for nonexistent token");
        isApprovedOrOwner = (spender == owner || _tokenApprovals[tokenId] == spender || isApprovedForAll(owner, spender));
    }   

    //function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
    //    require(_exists(tokenId), "ERC721: operator query for nonexistent token");
    //    address owner = ERC721.ownerOf(tokenId);
    //    return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    //}
    
    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     * @dev Please notice that _burn is slightly modified from the openzeppelin implementation.
     *      The contract has been modified such that _beforeTokenTransfer and _afterTokenTransfer are no longer called.
     *      Calls ownerOf in a way that an inheriting contract could override the ownerOf behavior.
     *      Checks approval so that either the owner or an approved address can burn.
     *      Calls _clearApproval(owner, tokenId) instead of _approve(address(0), tokenId).  This just deletes the approval entry, saving gas.
     *      Calls _clearOwnership(tokenId) so that inheriting contract can override the basic delete of the _owners mapping.          
     *      The openzeppelin version is shown commented out below fo comparison.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ownerOf(tokenId);
        bool isApprovedOrOwner = (_msgSender() == owner || _tokenApprovals[tokenId] == _msgSender() || isApprovedForAll(owner, _msgSender()));
        require(isApprovedOrOwner, "ERC721: burn caller is not owner nor approved");

        // Clear approvals        
        _clearApproval(owner, tokenId);

        _balances[owner] -= 1;
        _clearOwnership(tokenId);

        emit Transfer(owner, address(0), tokenId);
    }    

    //function _burn(uint256 tokenId) internal virtual {
    //    address owner = ERC721.ownerOf(tokenId);
    //
    //    _beforeTokenTransfer(owner, address(0), tokenId);
    //
    //    // Clear approvals
    //    _approve(address(0), tokenId);
    //
    //    _balances[owner] -= 1;
    //    delete _owners[tokenId];
    //
    //    emit Transfer(owner, address(0), tokenId);
    //
    //    _afterTokenTransfer(owner, address(0), tokenId);
    //}

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     * @dev Please notice that _transfer is slightly modified from the openzeppelin implementation.
     *      The contract has been modified such that _beforeTokenTransfer and _afterTokenTransfer are no longer called.
     *      'owner' is passed in to save gas looking it up twice.     
     *      Calls _clearApproval(owner, tokenId) instead of _approve(address(0), tokenId).  This just deletes the approval entry, saving gas.
     *      Calls _setOwnership(to, tokenId) so that inheriting contract can override the implementation of re-assigning owner address.          
     *      The openzeppelin version is shown commented out below fo comparison.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(address owner, address from, address to, uint256 tokenId) internal virtual {
        require(owner == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");        

        // Clear approvals from the previous owner        
        _clearApproval(owner, tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _setOwnership(to, tokenId);
        
        emit Transfer(from, to, tokenId);        
    }

    //function _transfer(address from, address to, uint256 tokenId) internal virtual {
    //    require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
    //    require(to != address(0), "ERC721: transfer to the zero address");
    //
    //    _beforeTokenTransfer(from, to, tokenId);
    //
    //    // Clear approvals from the previous owner
    //    _approve(address(0), tokenId);
    //
    //    _balances[from] -= 1;
    //    _balances[to] += 1;
    //    _owners[tokenId] = to;
    //
    //    emit Transfer(from, to, tokenId);
    //
    //    _afterTokenTransfer(from, to, tokenId);
    //}

    /**
     * @dev Equivalent to approving address(0), but more gas efficient
     * @dev Please notice that _clearApproval is a function that was added that does not exist in the openzeppelin implementation.
     *      It gives you a gas refund when resetting approval to address(0).
     *
     * Emits a {Approval} event.
     */
    function _clearApproval(address owner, uint256 tokenId) internal virtual {
        delete _tokenApprovals[tokenId];
        emit Approval(owner, address(0), tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address owner, address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }    

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits a {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Please notice that _clearOwnership is a function that was added that does not exist in the openzeppelin implementation.
     *      It will be overridden in our fixed cost minting contract.
     */
    function _clearOwnership(uint256 tokenId) internal virtual {
        delete _owners[tokenId];
    }

    /**
     * @dev Please notice that _setOwnership is a function that was added that does not exist in the openzeppelin implementation.
     *      It will be overridden in our fixed cost minting contract.
     */
    function _setOwnership(address to, uint256 tokenId) internal virtual {
        _owners[tokenId] = to;
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     *
     * @dev Slither identifies an issue with unused return value.
     * Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#unused-return
     * This should be a non-issue.  It is the standard OpenZeppelin implementation which has been heavily used and audited.
     */     
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal returns (bool) {
        if (to.isContract()) {            
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {                    
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }    
}