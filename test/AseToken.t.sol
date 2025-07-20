// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {AseToken} from "../contracts/AseToken.sol";

contract AseTokenTest is Test {
    AseToken public ase;
    address public treasury = address(1);
    address public healer = address(2);
    address public organizer = address(3);
    
    bytes32 constant HEALING_WORK = keccak256("Healing Ceremony");
    bytes32 constant CURANDERA_ROLE = keccak256("Curandera");
    bytes32 constant GUIDANCE_PURPOSE = keccak256("For Ancestral Guidance");
    
    function setUp() public {
        vm.prank(treasury);
        ase = new AseToken();
    }
    
    function test_InitialSetup() public view {
        assertEq(ase.name(), unicode"Asé Community Token");
        assertEq(ase.symbol(), unicode"ASÉ");
        assertEq(ase.decimals(), 18);
        assertEq(ase.totalSupply(), 1000000 * 10**18);
        assertEq(ase.balanceOf(treasury), 1000000 * 10**18);
        assertTrue(ase.hasRole(ase.SPIRITUAL_TREASURY_ROLE(), treasury));
    }
    
    function test_OfferPrayer() public {
        vm.prank(treasury);
        ase.transfer(healer, 1000 * 10**18);
        
        vm.prank(healer);
        ase.offerPrayer(organizer, 100 * 10**18, "For healing and strength");
        
        assertEq(ase.balanceOf(organizer), 100 * 10**18);
        assertEq(ase.balanceOf(healer), 900 * 10**18);
        
        (,,,, uint256 prayersOffered, uint256 prayersReceived) = ase.getUserProfile(healer);
        assertEq(prayersOffered, 1);
        
        (,,,, prayersOffered, prayersReceived) = ase.getUserProfile(organizer);
        assertEq(prayersReceived, 1);
    }
    
    function test_RevertWhen_PrayerWithoutIntention() public {
        vm.prank(treasury);
        ase.transfer(healer, 1000 * 10**18);
        
        vm.prank(healer);
        vm.expectRevert(AseToken.EmptyIntention.selector);
        ase.offerPrayer(organizer, 100 * 10**18, "");
    }
    
    function test_RevertWhen_InsufficientBalance() public {
        vm.prank(healer);
        vm.expectRevert(AseToken.InsufficientBalance.selector);
        ase.offerPrayer(organizer, 100 * 10**18, "For healing");
    }
    
    function test_RecognizeSpiritualLabor() public {
        vm.prank(treasury);
        ase.recognizeSpiritualLabor(healer, HEALING_WORK, 500);
        
        assertEq(ase.balanceOf(healer), 500);
        (, uint256 contributions,,,,) = ase.getUserProfile(healer);
        assertEq(contributions, 500);
    }
    
    function test_RevertWhen_UnauthorizedSpiritualLabor() public {
        vm.prank(healer);
        vm.expectRevert();
        ase.recognizeSpiritualLabor(organizer, HEALING_WORK, 500);
    }
    
    function test_BurnForAncestors() public {
        vm.prank(treasury);
        ase.transfer(healer, 1000 * 10**18);
        
        uint256 initialSupply = ase.totalSupply();
        
        vm.prank(healer);
        ase.burnForAncestors(100 * 10**18, GUIDANCE_PURPOSE);
        
        assertEq(ase.balanceOf(healer), 900 * 10**18);
        assertEq(ase.totalSupply(), initialSupply - 100 * 10**18);
        assertEq(ase.totalAncestralOfferings(), 100 * 10**18);
    }
    
    function test_BatchPrayerOffering() public {
        vm.prank(treasury);
        ase.transfer(healer, 1000 * 10**18);
        
        address[] memory recipients = new address[](2);
        recipients[0] = organizer;
        recipients[1] = address(4);
        
        uint256[] memory amounts = new uint256[](2);
        amounts[0] = 100 * 10**18;
        amounts[1] = 50 * 10**18;
        
        string[] memory intentions = new string[](2);
        intentions[0] = "For healing";
        intentions[1] = "For strength";
        
        vm.prank(healer);
        ase.batchPrayerOffering(recipients, amounts, intentions);
        
        assertEq(ase.balanceOf(organizer), 100 * 10**18);
        assertEq(ase.balanceOf(address(4)), 50 * 10**18);
        
        (,,,, uint256 prayersOffered,) = ase.getUserProfile(healer);
        assertEq(prayersOffered, 2);
    }
    
    function test_RevertWhen_BatchArrayMismatch() public {
        address[] memory recipients = new address[](2);
        uint256[] memory amounts = new uint256[](1); // Wrong length
        string[] memory intentions = new string[](2);
        
        vm.prank(healer);
        vm.expectRevert(AseToken.ArrayLengthMismatch.selector);
        ase.batchPrayerOffering(recipients, amounts, intentions);
    }
    
    function test_RevertWhen_TooManyRecipients() public {
        address[] memory recipients = new address[](21); // Too many
        uint256[] memory amounts = new uint256[](21);
        string[] memory intentions = new string[](21);
        
        vm.prank(healer);
        vm.expectRevert(AseToken.TooManyRecipients.selector);
        ase.batchPrayerOffering(recipients, amounts, intentions);
    }
    
    function test_ContributionLevels() public {
        vm.startPrank(treasury);
        
        // Test progression through levels
        ase.recognizeSpiritualLabor(healer, HEALING_WORK, 50);
        assertEq(ase.getContributionLevel(healer), "Community Member");
        
        ase.recognizeSpiritualLabor(healer, HEALING_WORK, 100);
        assertEq(ase.getContributionLevel(healer), "Circle Holder");
        
        ase.recognizeSpiritualLabor(healer, HEALING_WORK, 1000);
        assertEq(ase.getContributionLevel(healer), "Ritual Facilitator");
        
        vm.stopPrank();
    }
    
    function test_OrganizeGathering() public {
        vm.startPrank(treasury);
        ase.recognizeSpiritualLabor(healer, HEALING_WORK, 150);
        vm.stopPrank();
        
        bytes32 gatheringId = keccak256("Full Moon Ceremony");
        bytes32 location = keccak256("Sacred Grove");
        
        vm.prank(healer);
        ase.organizeGathering(gatheringId, location);
        
        assertEq(ase.gatheringOrganizers(gatheringId), healer);
    }
    
    function test_RevertWhen_InsufficientContributionsForGathering() public {
        bytes32 gatheringId = keccak256("Full Moon Ceremony");
        bytes32 location = keccak256("Sacred Grove");
        
        vm.prank(healer);
        vm.expectRevert(AseToken.InsufficientContributions.selector);
        ase.organizeGathering(gatheringId, location);
    }
    
    function test_ContributeToRitual() public {
        vm.prank(treasury);
        ase.transfer(healer, 1000 * 10**18);
        
        bytes32 ritualId = keccak256("New Moon Ceremony");
        
        vm.prank(healer);
        ase.contributeToRitual(ritualId, 100 * 10**18);
        
        assertEq(ase.ritualOfferings(ritualId), 100 * 10**18);
        assertEq(ase.balanceOf(address(ase)), 100 * 10**18);
    }
    
    function test_MutualAidSupport() public {
        vm.prank(treasury);
        ase.transfer(organizer, 1000 * 10**18);
        
        vm.prank(organizer);
        ase.mutualAidSupport(healer, 200 * 10**18);
        
        assertEq(ase.balanceOf(healer), 200 * 10**18);
        assertEq(ase.balanceOf(organizer), 800 * 10**18);
    }
    
    function test_SetCommunityRole() public {
        vm.prank(treasury);
        ase.setCommunityRole(healer, CURANDERA_ROLE);
        
        assertEq(ase.communityRoles(healer), CURANDERA_ROLE);
    }
    
    function test_GetUserProfile() public {
        vm.startPrank(treasury);
        ase.transfer(healer, 500 * 10**18);
        ase.recognizeSpiritualLabor(healer, HEALING_WORK, 200);
        ase.setCommunityRole(healer, CURANDERA_ROLE);
        vm.stopPrank();
        
        (uint256 balance, uint256 contributions, string memory level, 
         bytes32 role,,) = ase.getUserProfile(healer);
         
        assertEq(balance, 500 * 10**18 + 200);
        assertEq(contributions, 200);
        assertEq(keccak256(bytes(level)), keccak256(bytes("Circle Holder")));
        assertEq(role, CURANDERA_ROLE);
    }
    
    function test_GetCommunityStats() public {
        vm.prank(treasury);
        ase.transfer(healer, 1000 * 10**18);
        
        vm.prank(healer);
        ase.burnForAncestors(100 * 10**18, GUIDANCE_PURPOSE);
        
        (uint256 supply, uint256 ancestralOfferings, uint256 contractBalance) = ase.getCommunityStats();
        
        assertEq(supply, 1000000 * 10**18 - 100 * 10**18);
        assertEq(ancestralOfferings, 100 * 10**18);
        assertEq(contractBalance, 0);
    }
    
    function test_PauseUnpause() public {
        vm.prank(treasury);
        ase.pause();
        
        assertTrue(ase.paused());
        
        // Test that transfers fail when paused
        vm.prank(treasury);
        vm.expectRevert();
        ase.transfer(healer, 100 * 10**18);
        
        vm.prank(treasury);
        ase.unpause();
        
        assertFalse(ase.paused());
        
        // Test that transfers work after unpause
        vm.prank(treasury);
        ase.transfer(healer, 100 * 10**18);
        assertEq(ase.balanceOf(healer), 100 * 10**18);
    }
    
    function test_WithdrawRitualOfferings() public {
        vm.prank(treasury);
        ase.transfer(healer, 1000 * 10**18);
        
        bytes32 ritualId = keccak256("Ritual");
        vm.prank(healer);
        ase.contributeToRitual(ritualId, 100 * 10**18);
        
        vm.prank(treasury);
        ase.withdrawRitualOfferings(100 * 10**18, organizer);
        
        assertEq(ase.balanceOf(organizer), 100 * 10**18);
        assertEq(ase.balanceOf(address(ase)), 0);
    }
}