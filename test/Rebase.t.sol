// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Rebase.sol"; // Adjust the import path as needed

contract MockERC20 is ERC20 {
    constructor() ERC20("Mock Token", "MOCK") {}

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}

contract RebaseTest is Test {
    Rebase rebase;
    MockERC20 token;
    address user;

    function setUp() public {
        // Deploy the Rebase contract
        rebase = new Rebase();

        // Deploy a mock ERC20 token contract
        token = new MockERC20();

        // Assign a user address
        user = address(0xBEEF);

        // Mint tokens to the user address
        token.mint(user, 100 ether);

        // Label addresses for better readability in the test output
        vm.label(address(rebase), "Rebase");
        vm.label(address(token), "Token");
        vm.label(user, "User");
    }

    function testStakeAndUnstake() public {
        // Start the prank for the user
        vm.startPrank(user);

        // Approve the Rebase contract to spend user's tokens
        token.approve(address(rebase), 100 ether);

        // Create an empty address array for the apps parameter
        address[] memory apps = new address[](0);

        // Call the stake function to stake tokens
        rebase.stake(address(token), 50 ether, apps);

        // Check the staked balance
        uint256 stakedBalance = rebase.getUserTokenStake(user, address(token));
        assertEq(stakedBalance, 50 ether, "Staked balance should be 50 ether");

        // Call the unstake function to unstake tokens
        rebase.unstake(address(token), 50 ether);

        // Check the staked balance after unstaking
        stakedBalance = rebase.getUserTokenStake(user, address(token));
        assertEq(
            stakedBalance,
            0,
            "Staked balance should be 0 ether after unstaking"
        );

        vm.stopPrank();
    }

    function testRestake() public {
        // Start the prank for the user
        vm.startPrank(user);

        // Approve the Rebase contract to spend user's tokens
        token.approve(address(rebase), 100 ether);

        // Create an empty address array for the apps parameter
        address[] memory apps = new address[](0);

        // Call the stake function to stake tokens
        rebase.stake(address(token), 50 ether, apps);

        // Verify the staked balance
        uint256 stakedBalance = rebase.getUserTokenStake(user, address(token));
        assertEq(stakedBalance, 50 ether, "Staked balance should be 50 ether");

        // Add a new app to restake to
        address newApp = address(0xDEAD);
        address[] memory newApps = new address[](1);
        newApps[0] = newApp;

        // Call the restake function to restake tokens to the new app
        address[] memory tokens = new address[](1);
        tokens[0] = address(token);
        rebase.restake(newApps, tokens);

        // Verify the restaked balance remains the same
        stakedBalance = rebase.getUserTokenStake(user, address(token));
        assertEq(
            stakedBalance,
            50 ether,
            "Staked balance should remain 50 ether after restaking"
        );

        // Verify the app is added to the user's token apps
        address[] memory userTokenApps = rebase.getUserTokenApps(
            user,
            address(token)
        );
        assertEq(
            userTokenApps.length,
            1,
            "User should have one app associated with the token"
        );
        assertEq(
            userTokenApps[0],
            newApp,
            "The new app should be associated with the token"
        );

        vm.stopPrank();
    }
}
