// SPDX-License-Identifier: GPL-3.0
        
pragma solidity >=0.4.22 <0.9.0;

import "remix_tests.sol"; 

import "remix_accounts.sol";
import "../contracts/11_MyERC721Token.sol";

contract testSuite is MyERC721Token {
    address acc0 = TestsAccounts.getAccount(0); //owner by default
    address acc1 = TestsAccounts.getAccount(1);
    address acc2 = TestsAccounts.getAccount(2);

    function testMint() public returns (bool) {
        mint();
        mint();
        mint();
        return 
            Assert.equal(ownerOf[0], acc0, "owner of TokenId = 0 is not correct") &&
            Assert.equal(ownerOf[1], acc0, "owner of TokenId = 1 is not correct") &&
            Assert.equal(ownerOf[2], acc0, "owner of TokenId = 2 is not correct") &&
            Assert.equal(balanceOf[acc0], 3, "balance of acc0 is not correct") &&
            Assert.equal(balanceOf[acc1], 0, "balance of acc0 is not correct") &&
            Assert.equal(balanceOf[acc2], 0, "balance of acc0 is not correct");
    }

    function testTransferFrom() public returns (bool) {
        transferFrom(acc0, acc1, 1);
        transferFrom(acc0, acc2, 2);
        return 
            Assert.equal(ownerOf[0], acc0, "owner of TokenId = 0 is not correct") &&
            Assert.equal(ownerOf[1], acc1, "owner of TokenId = 1 is not correct") &&
            Assert.equal(ownerOf[2], acc2, "owner of TokenId = 2 is not correct") &&
            Assert.equal(balanceOf[acc0], 1, "balance of acc0 is not correct") &&
            Assert.equal(balanceOf[acc1], 1, "balance of acc1 is not correct") &&
            Assert.equal(balanceOf[acc2], 1, "balance of acc2 is not correct");
    }

    function testApprove() public returns (bool) {
        approve( acc1, 0 );
        return 
            Assert.equal(getApproved[0], acc1, "approved of TokenId = 0 is not correct");
    }

    /// #sender: account-1
    function testTransferFromByApproved() public returns (bool) {
        transferFrom( acc0, acc2, 0 );
        return 
            Assert.equal(getApproved[0], address(0), "approved of TokenId = 0 is not correct") &&
            Assert.equal(ownerOf[0], acc2, "owner of TokenId = 0 is not correct") &&
            Assert.equal(ownerOf[1], acc1, "owner of TokenId = 1 is not correct") &&
            Assert.equal(ownerOf[2], acc2, "owner of TokenId = 2 is not correct") &&
            Assert.equal(balanceOf[acc0], 0, "balance of acc0 is not correct") &&
            Assert.equal(balanceOf[acc1], 1, "balance of acc1 is not correct") &&
            Assert.equal(balanceOf[acc2], 2, "balance of acc2 is not correct");
    }

    /// #sender: account-2
    function testSetApprovalForAll() public returns (bool) {
        setApprovalForAll( acc1, true );
        return 
            Assert.equal(isApprovedForAll[acc2][acc1], true, "operator of acc2 is not correct");
    }

    /// #sender: account-1
    function testTransferFromByOperator() public returns (bool) {
        transferFrom( acc2, acc0, 0 );
        transferFrom( acc2, acc0, 2 );
        return 
            Assert.equal(isApprovedForAll[acc2][acc1], true, "operator of acc2 is not correct") &&
            Assert.equal(ownerOf[0], acc0, "owner of TokenId = 0 is not correct") &&
            Assert.equal(ownerOf[1], acc1, "owner of TokenId = 1 is not correct") &&
            Assert.equal(ownerOf[2], acc0, "owner of TokenId = 2 is not correct") &&
            Assert.equal(balanceOf[acc0], 2, "balance of acc0 is not correct") &&
            Assert.equal(balanceOf[acc1], 1, "balance of acc1 is not correct") &&
            Assert.equal(balanceOf[acc2], 0, "balance of acc2 is not correct");
    }
}
    