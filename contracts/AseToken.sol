// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

/**
 * @title Asé Community Token
 * @notice A community token for recognizing spiritual labor, mutual aid, and Afro-Caribbean regenerative practices
 * @dev Implements ERC-20 with enhanced community features and security best practices
 * @author haaz.eth
 */
contract AseToken is ERC20, AccessControl, ReentrancyGuard, Pausable {
    
    // =============================================================
    //                        CUSTOM ERRORS
    // =============================================================
    
    error InsufficientBalance();
    error InsufficientAse();
    error EmptyIntention();
    error EmptyWorkType();
    error EmptyPurpose();
    error ArrayLengthMismatch();
    error TooManyRecipients();
    error GatheringExists();
    error InsufficientContributions();
    error InvalidAmount();
    
    // =============================================================
    //                        ROLES
    // =============================================================
    
    bytes32 public constant SPIRITUAL_TREASURY_ROLE = keccak256("SPIRITUAL_TREASURY_ROLE");
    bytes32 public constant COMMUNITY_ORGANIZER_ROLE = keccak256("COMMUNITY_ORGANIZER_ROLE");
    
    // =============================================================
    //                        STORAGE
    // =============================================================
    
    /// @notice Efficient packed struct for user community data
    struct CommunityProfile {
        uint128 contributionPoints;
        uint64 prayersOffered;
        uint64 prayersReceived;
    }
    
    /// @notice Community profiles mapped by address
    mapping(address => CommunityProfile) public profiles;
    
    /// @notice Community roles using bytes32 for gas efficiency
    mapping(address => bytes32) public communityRoles;
    
    /// @notice Ritual offerings by ritual ID
    mapping(bytes32 => uint256) public ritualOfferings;
    
    /// @notice Gathering organizers by gathering ID
    mapping(bytes32 => address) public gatheringOrganizers;
    
    /// @notice Total ASÉ burned for ancestral offerings
    uint256 public totalAncestralOfferings;
    
    // =============================================================
    //                        EVENTS
    // =============================================================
    
    /// @dev Indexed parameters for efficient filtering
    event PrayerOffered(
        address indexed from, 
        address indexed to, 
        uint256 indexed amount, 
        string intention
    );
    
    event SpiritualLabor(
        address indexed contributor, 
        bytes32 indexed workType, 
        uint256 indexed aseEarned
    );
    
    event CommunityBlessing(
        bytes32 indexed ritualId, 
        uint256 indexed totalOfferings
    );
    
    event MutualAidSupport(
        address indexed supporter, 
        address indexed recipient, 
        uint256 indexed amount
    );
    
    event AncestralOffering(
        address indexed offerer, 
        uint256 indexed amount, 
        bytes32 indexed purpose
    );
    
    event BatchPrayersOffered(
        address indexed from, 
        uint256 indexed totalAmount, 
        uint256 recipientCount
    );
    
    event CommunityGathering(
        address indexed organizer, 
        bytes32 indexed gatheringId, 
        bytes32 indexed location
    );
    
    // =============================================================
    //                        CONSTRUCTOR
    // =============================================================
    
    constructor() ERC20(unicode"Asé Community Token", unicode"ASÉ") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(SPIRITUAL_TREASURY_ROLE, msg.sender);
        _grantRole(COMMUNITY_ORGANIZER_ROLE, msg.sender);
        
        _mint(msg.sender, 1_000_000 * 10**decimals());
    }
    
    // =============================================================
    //                        SPIRITUAL FUNCTIONS
    // =============================================================
    
    /**
     * @notice Offer prayer with ASÉ to another community member
     * @param recipient Address receiving the prayer offering
     * @param amount Amount of ASÉ to send with prayer
     * @param intention Prayer intention (required for spiritual authenticity)
     */
    function offerPrayer(
        address recipient, 
        uint256 amount, 
        string calldata intention
    ) external nonReentrant whenNotPaused {
        if (balanceOf(msg.sender) < amount) revert InsufficientBalance();
        if (bytes(intention).length == 0) revert EmptyIntention();
        
        // Update prayer counters efficiently
        profiles[msg.sender].prayersOffered++;
        profiles[recipient].prayersReceived++;
        
        _transfer(msg.sender, recipient, amount);
        emit PrayerOffered(msg.sender, recipient, amount, intention);
    }
    
    /**
     * @notice Recognize spiritual labor and mint new ASÉ
     * @param contributor Address of the spiritual worker
     * @param workType Type of spiritual work (bytes32 for efficiency)
     * @param aseAmount Amount of ASÉ to mint as recognition
     */
    function recognizeSpiritualLabor(
        address contributor,
        bytes32 workType,
        uint256 aseAmount
    ) external onlyRole(SPIRITUAL_TREASURY_ROLE) whenNotPaused {
        if (workType == bytes32(0)) revert EmptyWorkType();
        
        profiles[contributor].contributionPoints += uint128(aseAmount);
        _mint(contributor, aseAmount);
        
        emit SpiritualLabor(contributor, workType, aseAmount);
    }
    
    /**
     * @notice Burn ASÉ for ancestral offerings (deflationary ceremony)
     * @param amount Amount to burn
     * @param purpose Purpose of the offering (bytes32 for efficiency)
     */
    function burnForAncestors(
        uint256 amount, 
        bytes32 purpose
    ) external nonReentrant whenNotPaused {
        if (balanceOf(msg.sender) < amount) revert InsufficientAse();
        if (purpose == bytes32(0)) revert EmptyPurpose();
        
        totalAncestralOfferings += amount;
        _burn(msg.sender, amount);
        
        emit AncestralOffering(msg.sender, amount, purpose);
    }
    
    // =============================================================
    //                        BATCH OPERATIONS
    // =============================================================
    
    /**
     * @notice Efficiently send prayers to multiple recipients
     * @param recipients Array of recipient addresses
     * @param amounts Array of ASÉ amounts
     * @param intentions Array of prayer intentions
     */
    function batchPrayerOffering(
        address[] calldata recipients,
        uint256[] calldata amounts,
        string[] calldata intentions
    ) external nonReentrant whenNotPaused {
        uint256 length = recipients.length;
        if (length != amounts.length || length != intentions.length) {
            revert ArrayLengthMismatch();
        }
        if (length > 20) revert TooManyRecipients();
        
        uint256 totalAmount;
        
        // Calculate total and validate
        for (uint256 i = 0; i < length;) {
            totalAmount += amounts[i];
            if (bytes(intentions[i]).length == 0) revert EmptyIntention();
            unchecked { ++i; }
        }
        
        if (balanceOf(msg.sender) < totalAmount) revert InsufficientBalance();
        
        // Execute transfers
        for (uint256 i = 0; i < length;) {
            profiles[recipients[i]].prayersReceived++;
            _transfer(msg.sender, recipients[i], amounts[i]);
            emit PrayerOffered(msg.sender, recipients[i], amounts[i], intentions[i]);
            unchecked { ++i; }
        }
        
        profiles[msg.sender].prayersOffered += uint64(length);
        emit BatchPrayersOffered(msg.sender, totalAmount, length);
    }
    
    // =============================================================
    //                        COMMUNITY FUNCTIONS
    // =============================================================
    
    /**
     * @notice Organize a community gathering
     * @param gatheringId Unique identifier for the gathering
     * @param location Location of gathering (bytes32 for efficiency)
     */
    function organizeGathering(
        bytes32 gatheringId, 
        bytes32 location
    ) external whenNotPaused {
        if (profiles[msg.sender].contributionPoints < 100) {
            revert InsufficientContributions();
        }
        if (gatheringOrganizers[gatheringId] != address(0)) {
            revert GatheringExists();
        }
        
        gatheringOrganizers[gatheringId] = msg.sender;
        emit CommunityGathering(msg.sender, gatheringId, location);
    }
    
    /**
     * @notice Contribute to a community ritual
     * @param ritualId Unique identifier for the ritual
     * @param amount Amount of ASÉ to contribute
     */
    function contributeToRitual(
        bytes32 ritualId, 
        uint256 amount
    ) external nonReentrant whenNotPaused {
        if (balanceOf(msg.sender) < amount) revert InsufficientAse();
        if (amount == 0) revert InvalidAmount();
        
        ritualOfferings[ritualId] += amount;
        _transfer(msg.sender, address(this), amount);
        
        emit CommunityBlessing(ritualId, ritualOfferings[ritualId]);
    }
    
    /**
     * @notice Send mutual aid support
     * @param recipient Address to support
     * @param amount Amount of ASÉ to send
     */
    function mutualAidSupport(
        address recipient, 
        uint256 amount
    ) external nonReentrant whenNotPaused {
        if (balanceOf(msg.sender) < amount) revert InsufficientAse();
        
        _transfer(msg.sender, recipient, amount);
        emit MutualAidSupport(msg.sender, recipient, amount);
    }
    
    // =============================================================
    //                        VIEW FUNCTIONS
    // =============================================================
    
    /**
     * @notice Get user's complete community profile
     * @param user Address to query
     * @return balance Current ASÉ balance
     * @return contributions Total contribution points
     * @return level Community level string
     * @return role Community role (bytes32)
     * @return prayersOffered Total prayers offered
     * @return prayersReceived Total prayers received
     */
    function getUserProfile(address user) external view returns (
        uint256 balance,
        uint256 contributions,
        string memory level,
        bytes32 role,
        uint256 prayersOffered,
        uint256 prayersReceived
    ) {
        CommunityProfile memory profile = profiles[user];
        return (
            balanceOf(user),
            profile.contributionPoints,
            getContributionLevel(user),
            communityRoles[user],
            profile.prayersOffered,
            profile.prayersReceived
        );
    }
    
    /**
     * @notice Get contribution level based on points
     * @param member Address to check
     * @return Level string based on contribution points
     */
    function getContributionLevel(address member) public view returns (string memory) {
        uint256 points = profiles[member].contributionPoints;
        if (points >= 10000) return "Elder/Ancestral Wisdom Keeper";
        if (points >= 5000) return "Community Healer";
        if (points >= 1000) return "Ritual Facilitator";
        if (points >= 100) return "Circle Holder";
        return "Community Member";
    }
    
    /**
     * @notice Get community statistics
     * @return _totalSupply Current total supply
     * @return _totalAncestralOfferings Total burned for ancestors
     * @return _contractBalance ASÉ held by contract (ritual contributions)
     */
    function getCommunityStats() external view returns (
        uint256 _totalSupply,
        uint256 _totalAncestralOfferings,
        uint256 _contractBalance
    ) {
        return (totalSupply(), totalAncestralOfferings, balanceOf(address(this)));
    }
    
    // =============================================================
    //                        ADMIN FUNCTIONS
    // =============================================================
    
    /**
     * @notice Set community role for a member
     * @param member Address of community member
     * @param role Role to assign (bytes32 for efficiency)
     */
    function setCommunityRole(
        address member, 
        bytes32 role
    ) external onlyRole(SPIRITUAL_TREASURY_ROLE) {
        communityRoles[member] = role;
    }
    
    /**
     * @notice Pause contract in emergency
     */
    function pause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    }
    
    /**
     * @notice Unpause contract
     */
    function unpause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }
    
    /**
     * @notice Withdraw ritual contributions for community use
     * @param amount Amount to withdraw
     * @param recipient Address to receive funds
     */
    function withdrawRitualOfferings(
        uint256 amount,
        address recipient
    ) external onlyRole(SPIRITUAL_TREASURY_ROLE) nonReentrant {
        if (balanceOf(address(this)) < amount) revert InsufficientBalance();
        _transfer(address(this), recipient, amount);
    }
    
    // =============================================================
    //                        OVERRIDES
    // =============================================================
    
    /**
     * @dev Override to add pause functionality to transfers
     */
    function _update(
        address from,
        address to,
        uint256 value
    ) internal override whenNotPaused {
        super._update(from, to, value);
    }
}