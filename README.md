# Asé Community Token

A professional-grade ERC-20 token for recognizing spiritual labor, mutual aid, and regenerative community practices.

## 🌿 Contract Overview

The Asé (ASÉ) token implements advanced tokenomics for community organizing with Afro-Caribbean spiritual traditions and enterprise-level security.

**Contract Address**: Deploy using `forge script script/DeployAse.s.sol`  
**Author**: haaz.eth  
**Network**: Base Mainnet Ready

## ✨ Features

### Spiritual & Community Functions
- **Prayer Offerings**: Send ASÉ with spiritual intentions
- **Spiritual Labor Recognition**: Mint new tokens for community contributions  
- **Ancestral Ceremonies**: Burn tokens for deflationary offerings
- **Batch Operations**: Efficient multi-recipient transactions
- **Community Gatherings**: Organize events with location tracking
- **Mutual Aid Support**: Direct peer-to-peer assistance

### Security & Best Practices
- ✅ **OpenZeppelin Standards**: AccessControl, ReentrancyGuard, Pausable
- ✅ **Custom Errors**: Gas-efficient error handling
- ✅ **NatSpec Documentation**: Complete function documentation
- ✅ **Storage Optimization**: Packed structs for gas efficiency
- ✅ **Role-Based Access**: Multi-tier permission system
- ✅ **Emergency Controls**: Pausable functionality
- ✅ **Comprehensive Tests**: 20/20 tests passing

## 🔧 Development

### Prerequisites
- [Foundry](https://getfoundry.sh/) for smart contract development
- Node.js for additional tooling

### Setup
```bash
# Clone and install dependencies
forge install

# Run tests
forge test --match-contract AseTokenTest -vv

# Deploy to Base mainnet
cp .env.example .env
# Add your credentials to .env
forge script script/DeployAse.s.sol --rpc-url base_mainnet --broadcast --verify
```

### Testing
```bash
# Run all tests
forge test

# Run with gas reports
forge test --gas-report

# Run specific test
forge test --match-test test_OfferPrayer -vv
```

## 📊 Tokenomics

- **Total Supply**: 1,000,000 ASÉ (1M tokens)
- **Decimals**: 18
- **Inflation**: Controlled minting for spiritual labor recognition
- **Deflation**: Token burning for ancestral ceremonies
- **Roles**: Spiritual Treasury, Community Organizer, Default Admin

## 🎯 Community Levels

Based on contribution points earned through spiritual labor:

1. **Community Member** (0-99 points)
2. **Circle Holder** (100-999 points) - Can organize gatherings
3. **Ritual Facilitator** (1,000-4,999 points)
4. **Community Healer** (5,000-9,999 points)  
5. **Elder/Ancestral Wisdom Keeper** (10,000+ points)

## 🛡️ Security

- **Reentrancy Protection**: All state-changing functions protected
- **Access Control**: Role-based permissions with OpenZeppelin
- **Emergency Pause**: Admin can pause all transfers
- **Input Validation**: Custom errors for gas-efficient reverts
- **Comprehensive Testing**: Edge cases and error conditions covered

## 📱 dApp Integration

### Key View Functions
- `getUserProfile(address)`: Complete user stats and role
- `getCommunityStats()`: Global community metrics
- `getContributionLevel(address)`: User's community level

### Events for Frontend
All events use indexed parameters for efficient filtering:
- `PrayerOffered` - Prayer transactions with intentions
- `SpiritualLabor` - Work recognition events
- `CommunityGathering` - Event organization
- `AncestralOffering` - Token burn ceremonies

## 🌐 Farcaster Integration Ready

The contract includes features designed for Farcaster frames:
- Batch prayer operations for social tipping
- Community gathering organization
- Event emission for real-time updates
- Gas-optimized batch operations

## 📄 License

MIT License - Built for community empowerment and cultural authenticity.

---

*Built with 🌿 for regenerative communities by haaz.eth*