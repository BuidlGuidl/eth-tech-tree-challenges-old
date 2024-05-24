// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../contracts/MyToken.sol";
import "../contracts/Voting.sol";

contract VotingTest is Test {
    MyToken public token;
    Voting public voting;
    address public userOne = address(0x123);
    address public userTwo = address(0x456);

    function setUp() public {
        token = new MyToken(1000000 * 10**18); // 1,000,000 tokens
        voting = new Voting(address(token), 86400); // 1 day voting period

        // Distribute tokens
        token.transfer(userOne, 1000 * 10**18); // 1000 tokens to userOne
        token.transfer(userTwo, 2000 * 10**18); // 2000 tokens to userTwo
    }

    function testInitialBalances() public {
        assertEq(token.balanceOf(address(this)), 997000 * 10**18); // Deployer balance after distribution
        assertEq(token.balanceOf(userOne), 1000 * 10**18); // userOne balance after distribution
        assertEq(token.balanceOf(userTwo), 2000 * 10**18); // userTwo balance after distribution
    }

    function testVotingFor() public {
        vm.prank(userOne);
        voting.vote(true);

        assertEq(voting.votesFor(), token.balanceOf(userOne));
        assertEq(voting.votesAgainst(), 0);
        assertTrue(voting.hasVoted(userOne));
    }

    function testVotingAgainst() public {
        vm.prank(userTwo);
        voting.vote(false);

        assertEq(voting.votesFor(), 0);
        assertEq(voting.votesAgainst(), token.balanceOf(userTwo));
        assertTrue(voting.hasVoted(userTwo));
    }

    function testDoubleVoting() public {
        vm.startPrank(userOne);
        voting.vote(true);
        vm.expectRevert();
        voting.vote(true);
        vm.stopPrank();
    }

    function testNoTokensToVote() public {
        // 0 in the balanceof userThree, so he can't vote
        address userThree = address(0x789);
        vm.prank(userThree);
        vm.expectRevert();
        voting.vote(true);
        assertFalse(voting.hasVoted(userThree));
    }

    function testVotingResultRejected() public {
        // 1000 for vs 2000 against
        vm.prank(userOne);
        voting.vote(true);

        vm.prank(userTwo);
        voting.vote(false);

        vm.warp(block.timestamp + 86400 + 1);

        bool result = voting.getResult();
        assertEq(result, false); 
    }

    function testVotingResultApproved() public {
         // 2000 for vs 1000 against
           
        vm.prank(userOne);
        voting.vote(false);

        vm.prank(userTwo);
        voting.vote(true);

        vm.warp(block.timestamp + 86400 + 1);

        bool result = voting.getResult();
        assertEq(result, true);
    }
    function testGetResultBeforeDeadline() public {
        // Try to get the result before the voting deadline
        vm.prank(userOne);
        voting.vote(true);

        vm.prank(userTwo);
        voting.vote(false);

        vm.expectRevert();
        voting.getResult();
    }
    function testVoteAfterDeadline() public {
        // Try to vote after the voting deadline
        vm.warp(block.timestamp + 86400 + 1);
        vm.prank(userOne);
        vm.expectRevert();
        voting.vote(true);
    }

}
