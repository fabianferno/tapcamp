// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract TapCampERC20 is ERC20, ERC20Burnable, ERC20Permit, Ownable {
    address payable highestHolder;
    uint256 highestBalance;

    constructor() ERC20("TapCamp", "TPCP") ERC20Permit("TapCamp") {
        randomNumber();
    }

    function randomNumber() internal view returns (uint256) {
        return uint256(blockhash(block.number - 1));
    }

    function _randomNumberToAmount(
        uint256 rand
    ) internal pure returns (uint256) {
        uint256 rand5 = (rand % 5) + 1;
        uint256 rand7 = (rand % 5) + 1;
        uint256 rand29 = (rand % 5) + 1;
        return rand5 * rand7 * rand29;
    }

    function mint(address to) public onlyOwner {
        uint256 amount = _randomNumberToAmount(randomNumber());
        _internal_mint(to, amount);
    }

    function _internal_mint(address to, uint256 amount) internal {
        _mint(to, amount);
        uint256 tokenBalance = balanceOf(to);
        if (tokenBalance > highestBalance) {
            highestBalance = tokenBalance;
            highestHolder = payable(to);
        }
    }

    function getHighestHolder() external view returns (address payable) {
        return highestHolder;
    }

    function resetBalance(address holder) external onlyOwner {
        _burn(holder, balanceOf(holder));
    }

    // User zero decimals. Tokens not divisible.
    function decimals() public view virtual override returns (uint8) {
        return 0;
    }

    // disable token transfer
    function transfer(
        address to,
        uint256 value
    ) public override returns (bool) {
        require(false, "TPCP points are not transferable");
        return super.transfer(to, value);
    }
}
