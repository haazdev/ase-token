// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {AseToken} from "../contracts/AseToken.sol";

/**
 * @title Deploy Asé Token Script
 * @notice Deployment script for the enhanced ASÉ community token
 */
contract DeployAseScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        vm.startBroadcast(deployerPrivateKey);
        
        // Deploy ASÉ Token with all security features
        AseToken ase = new AseToken();
        
        console.log("==============================================");
        console.log(unicode"🌿 ASÉ Token Deployed Successfully! 🌿");
        console.log("==============================================");
        console.log("Contract Address:", address(ase));
        console.log("Name:", ase.name());
        console.log("Symbol:", ase.symbol());
        console.log("Total Supply:", ase.totalSupply());
        console.log("Deployer (Treasury):", msg.sender);
        console.log("==============================================");
        console.log("Security Features Enabled:");
        console.log("   - ReentrancyGuard Protection");
        console.log("   - AccessControl Roles");
        console.log("   - Pausable Emergency Stop");
        console.log("   - Custom Error Messages");
        console.log("   - Gas Optimized Storage");
        console.log("==============================================");
        
        vm.stopBroadcast();
    }
}