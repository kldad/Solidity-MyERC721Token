// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.34;

import "./10_IERC6093.sol";
import "./12_IERC721Receiver.sol";

contract MyERC721Token is IERC6093 {

    address private owner;
    uint256 private currentTokenId;

    mapping (address owner => uint256 balance) public override balanceOf;
    mapping (uint256 tokenId => address owner ) public override ownerOf;
    mapping (uint256 tokenId => address approved ) public override getApproved;
    mapping (address owner => mapping (address operator => bool approved)) public override isApprovedForAll;

    modifier onlyOwner {
        require(msg.sender == owner, "Only the contract owner can call this function");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function isContract(address addr) private view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

    function mint() public onlyOwner {
        ownerOf[currentTokenId] = msg.sender;
        balanceOf[msg.sender]++; 

        emit Transfer(address(0), msg.sender, currentTokenId++);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public payable {
        if(tokenId >= currentTokenId)
            revert ERC721NonexistentToken(tokenId);

        address approved = getApproved[tokenId];
        address tokenOwner = ownerOf[tokenId];
        if(msg.sender != from && msg.sender != approved && ! isApprovedForAll[tokenOwner][msg.sender])
            revert ERC721InvalidSender(msg.sender); 

        if(from != tokenOwner) 
            revert ERC721IncorrectOwner(from, tokenId, tokenOwner);

        if(to == address(0) || to == from)
            revert ERC721InvalidReceiver(to);

        if(isContract(to)) {
            bytes4 retval = IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, data);
            if(retval == bytes4(keccak256("onERC721Received(address,address,uint256,bytes)")))
                revert ERC721InvalidReceiver(to);
        }

        ownerOf[tokenId] = to;
        unchecked {
            balanceOf[from]--; 
        }
        balanceOf[to]++; 

        emit Transfer(from, to, tokenId);

        if( approved != address(0) ) {
            getApproved[tokenId] = address(0);
            emit Approval(tokenOwner, approved, tokenId);
        }
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) external payable {
        safeTransferFrom( from, to, tokenId, "");
    }
    
    function transferFrom(address from, address to, uint256 tokenId) public payable override {
        if(tokenId >= currentTokenId)
            revert ERC721NonexistentToken(tokenId);

        address approved = getApproved[tokenId];
        address tokenOwner = ownerOf[tokenId];
        if(msg.sender != from && msg.sender != approved && ! isApprovedForAll[tokenOwner][msg.sender])
            revert ERC721InvalidSender(msg.sender); 

        if(from != tokenOwner) 
            revert ERC721IncorrectOwner(from, tokenId, tokenOwner);

        if(to == address(0) || to == from)
            revert ERC721InvalidReceiver(to);

        ownerOf[tokenId] = to;
        unchecked {
            balanceOf[from]--; 
        }
        balanceOf[to]++; 

        emit Transfer(from, to, tokenId);

        if( approved != address(0) ) {
            getApproved[tokenId] = address(0);
            emit Approval(tokenOwner, approved, tokenId);
        }
    }

    function approve(address approved, uint256 tokenId) public payable {
        if(tokenId >= currentTokenId)
            revert ERC721NonexistentToken(tokenId);

        address tokenOwner = ownerOf[tokenId];
        if(msg.sender != tokenOwner && ! isApprovedForAll[tokenOwner][msg.sender]) 
            revert ERC721InvalidApprover(msg.sender);

        if(approved == tokenOwner) 
            revert ERC721InvalidOperator(approved);

        getApproved[tokenId] = approved;

        emit Approval(tokenOwner, approved, tokenId);
    }

    function setApprovalForAll(address operator, bool approved) public {
        if(operator == msg.sender || operator == address(0)) 
            revert ERC721InvalidOperator(operator);

        isApprovedForAll[msg.sender][operator] = approved;

        emit ApprovalForAll(msg.sender, operator, approved);
    }
}