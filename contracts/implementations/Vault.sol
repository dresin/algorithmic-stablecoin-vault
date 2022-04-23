// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/IVault.sol";
import "hardhat/console.sol";
import "../interfaces/ICoin.sol";

contract Vault is IVault {

    ICoin public immutable token;

    uint256 public priceAudEth;
    uint256 numberOfUsers;
    mapping (address => uint256) userId;
    mapping (address => Vault) vaults;
    
    constructor(address tokenAddress){
        token = ICoin(tokenAddress);
        priceAudEth = 4000 * 10**18;
        numberOfUsers = 0;
    }

    function deposit(uint256 amountToDeposit) external payable override {
        require(msg.value == amountToDeposit, "Sent amount does not match declared amount to deposit.");
        uint256 estimatedTokenAmount = _estimateTokenAmount(amountToDeposit);
        if (userId[msg.sender] != 0) {
            vaults[msg.sender].collateralAmount += amountToDeposit;
            vaults[msg.sender].debtAmount += estimatedTokenAmount;
        } else {
            numberOfUsers++;
            userId[msg.sender] = numberOfUsers;
            vaults[msg.sender] = Vault({collateralAmount:amountToDeposit, debtAmount:estimatedTokenAmount});
        }
        _mint(msg.sender, estimatedTokenAmount);
        emit Deposit(amountToDeposit, estimatedTokenAmount);
    }
    
    function withdraw(uint256 repaymentAmount) external override {
        require(userId[msg.sender] != 0, "User does not exist.");
        uint256 estimatedCollateralAmount = _estimateCollateralAmount(msg.sender, repaymentAmount);
        require(estimatedCollateralAmount <= vaults[msg.sender].collateralAmount, "Not enough collateral.");
        vaults[msg.sender].collateralAmount -= estimatedCollateralAmount;
        vaults[msg.sender].debtAmount -= repaymentAmount;
        _burn(msg.sender, repaymentAmount);
        payable(msg.sender).transfer(estimatedCollateralAmount);
        emit Withdraw(estimatedCollateralAmount, repaymentAmount);
    }

    function _getVault(address userAddress) internal view returns(Vault memory vault) {
        return vaults[userAddress];
    }

    function getVault(address userAddress) external view override returns(Vault memory vault) {
        return _getVault(userAddress);
    }

    function _estimateCollateralAmount(address userAddress, uint256 repaymentAmount) internal view returns(uint256 collateralAmount) {
        uint256 collateralRatio = 10000 * vaults[userAddress].debtAmount / priceAudEth; // 100 is 1%, 10000 is 100%, 1 is 0.01%, so the precision is with 2 decimals
        uint256 maxCollateral = vaults[userAddress].collateralAmount;
        uint256 maxRepaymentAmount = repaymentAmount;
        if (repaymentAmount > vaults[userAddress].debtAmount) {
            maxRepaymentAmount = vaults[userAddress].debtAmount;
        }
        if (collateralRatio < 10000) {
            maxCollateral = maxCollateral * collateralRatio / 10000;
        }
        return maxCollateral * maxRepaymentAmount / vaults[userAddress].debtAmount;
    }

    function estimateCollateralAmount(uint256 repaymentAmount) external view override returns(uint256 collateralAmount) {
        require(userId[msg.sender] != 0, "User does not exist.");
        return _estimateCollateralAmount(msg.sender, repaymentAmount);
    }

    function _estimateTokenAmount(uint256 depositAmount) internal view returns(uint256 tokenAmount) {
        return depositAmount * priceAudEth / 10**18;
    }

    function estimateTokenAmount(uint256 depositAmount) external view override returns(uint256 tokenAmount) {
        return _estimateTokenAmount(depositAmount);
    }

    function setPriceAudEth(uint256 newPrice) external {
        priceAudEth = newPrice;
    }

    function getBalance() external view returns(uint256) {
        return address(this).balance;
    }

    function _mint(address account, uint256 amount) internal returns(bool) {
        token.mint(account, amount);
        return true;
    }

    function _burn(address account, uint256 amount) internal returns(bool) {
        token.burn(account, amount);
        return true;
    }
}
