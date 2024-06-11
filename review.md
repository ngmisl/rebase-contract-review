## Security Report for Rebase Contract

### Note

I was not able to exploit a potential reentrancy attack, but this doesn't mean it's impossible. Better follow OpenZeppelin best practice here.

### Summary

This report outlines the findings from the security analysis of the Rebase smart contract using Slither. The issues found include reentrancy vulnerabilities, unchecked return values, usage of literals with too many digits, and the presence of low-level calls. Below is a detailed table of the issues, their severity, and recommendations for fixes.

### Issues

| Issue                                                                 | Severity | Description                                                                                                                                                         | Recommendation                                                                                                                                                                   |
|----------------------------------------------------------------------|----------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Reentrancy in `stakeETH(address[])`                                   | High     | External calls and state changes are performed without proper reentrancy protection, which can allow reentrancy attacks.                                            | Use the [ReentrancyGuard](https://docs.openzeppelin.com/contracts/4.x/api/security#ReentrancyGuard) module from OpenZeppelin to prevent reentrancy.                             |
| Reentrancy in `unstake(address,uint256)`                              | High     | External calls and state changes are performed without proper reentrancy protection, which can allow reentrancy attacks.                                            | Use the [ReentrancyGuard](https://docs.openzeppelin.com/contracts/4.x/api/security#ReentrancyGuard) module from OpenZeppelin to prevent reentrancy.                             |
| Reentrancy in `restake(address[],address[])`                          | High     | External calls and state changes are performed without proper reentrancy protection, which can allow reentrancy attacks.                                            | Use the [ReentrancyGuard](https://docs.openzeppelin.com/contracts/4.x/api/security#ReentrancyGuard) module from OpenZeppelin to prevent reentrancy.                             |
| Reentrancy in `_restake(address,address,uint256)`                     | High     | External calls and state changes are performed without proper reentrancy protection, which can allow reentrancy attacks.                                            | Use the [ReentrancyGuard](https://docs.openzeppelin.com/contracts/4.x/api/security#ReentrancyGuard) module from OpenZeppelin to prevent reentrancy.                             |
| Reentrancy in `_unrestake(address,address,uint256)`                   | High     | External calls and state changes are performed without proper reentrancy protection, which can allow reentrancy attacks.                                            | Use the [ReentrancyGuard](https://docs.openzeppelin.com/contracts/4.x/api/security#ReentrancyGuard) module from OpenZeppelin to prevent reentrancy.                             |
| Unchecked return values                                               | Medium   | Return values of several external calls (e.g., ERC20 `transferFrom`, `transfer`, `mint`, `burn`, etc.) are not checked, which can lead to unexpected behavior.       | Always check the return values of external calls to ensure they executed successfully.                                                                                           |
| Incorrect exponentiation                                              | Low      | Uses bitwise XOR operator `^` instead of the exponentiation operator `**`.                                                                                          | Replace `^` with `**` for correct exponentiation.                                                                                                                               |
| Low level call in `unstake(address,uint256)`                          | Low      | Use of low-level call to transfer Ether which might lead to unexpected behavior if the call fails.                                                                  | Use OpenZeppelin's `Address.sendValue` or `Address.functionCall` to handle Ether transfers safely.                                                                               |
| Usage of literals with too many digits                                | Low      | Using literals with too many digits can be hard to read and maintain.                                                                                               | Consider using smaller literals or break them into smaller parts for readability.                                                                                                |
| Different pragma directives are used                                  | Low      | Multiple Solidity version pragmas are used in the contract, which can cause compatibility issues.                                                                   | Standardize to a single Solidity version pragma across all files.                                                                                                                |
| Dead code                                                             | Low      | Unused functions and variables increase the contract size and complexity.                                                                                           | Remove unused functions and variables to reduce contract size and complexity.                                                                                                    |

### Detailed Recommendations

#### Reentrancy Issues

**Affected Functions:**

- `stakeETH(address[])`
- `unstake(address,uint256)`
- `restake(address[],address[])`
- `_restake(address,address,uint256)`
- `_unrestake(address,address,uint256)`

**Fix:**

- Integrate the `ReentrancyGuard` module from OpenZeppelin by inheriting from `ReentrancyGuard` and using the `nonReentrant` modifier to protect the functions.

**Example:**

```solidity
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Rebase is ReentrancyGuard {
    function stakeETH(address[] memory apps) external payable nonReentrant {
        // function body
    }

    function unstake(address token, uint256 quantity) external nonReentrant {
        // function body
    }

    // Other functions with nonReentrant modifier
}
```

#### Unchecked Return Values

**Affected Functions:**

- `stake(address,uint256,address[])`
- `unstake(address,uint256)`
- `_getReToken(address)`
- `restake(address[],address[])`
- `_updateAppStakes(Rebase.User,address,uint256,address[])`

**Fix:**

- Always check the return values of external calls, especially ERC20 transfers and mints.

**Example:**

```solidity
require(ERC20(token).transferFrom(msg.sender, address(this), quantity), "Transfer failed");
require(_getReToken(token).mint(msg.sender, quantity), "Mint failed");
```

#### Incorrect Exponentiation

**Fix:**

- Replace `^` with `**` for exponentiation.

**Example:**

```solidity
uint result = (3 * denominator) ** 2;
```

#### Low-Level Calls

**Affected Functions:**

- `unstake(address,uint256)`
- `_restake(address,address,uint256)`
- `_unrestake(address,address,uint256)`

**Fix:**

- Use OpenZeppelin's `Address` library for low-level calls to ensure safe and secure Ether transfers.

**Example:**

```solidity
import "@openzeppelin/contracts/utils/Address.sol";

Address.sendValue(payable(msg.sender), quantity);
```

#### Usage of Literals with Too Many Digits

**Fix:**

- Break down large literals into smaller, more readable parts.

**Example:**

```solidity
uint constant LARGE_VALUE = 1_000_000_000 * 1e18;
```

#### Different Pragma Directives

**Fix:**

- Use a single Solidity version pragma across all files for consistency.

**Example:**

```solidity
pragma solidity ^0.8.20;
```

#### Dead Code

**Fix:**

- Remove unused functions and variables to improve readability and reduce contract size.

**Example:**

```solidity
// Remove this unused function
// function _contextSuffixLength() internal pure returns (uint256) { return 0; }
```

### Conclusion

Implementing the above recommendations will enhance the security, readability, and maintainability of the Rebase contract. Ensuring reentrancy protection, checking return values, and standardizing code practices are crucial for deploying secure smart contracts.
