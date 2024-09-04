// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./ERC20ABC.sol";
import "./interfaces/ISunCoin.sol";
import {ISunCoin} from "./interfaces/ISunCoin.sol";

/**
 * @title Sun
 * @notice Token contract implementing a linear sDAI-backed bonding curve where the solpe is 25 basis points (0.0025).
 * @dev Adheres to ERC-20 token standard and uses the ERC-4626 tokenized vault interface.
 */
contract SunCoin is ERC20ABC, ISunCoin {
    uint16 buffer = 1;
    uint256 totalAssetsHold;

    ERC20 public constant USDT = ERC20(0x05D032ac25d322df992303dCa074EE7392C117b9);

    /**
     * @dev Constructs the SunCoin contract, checks the USDT token address.
     */
    constructor() ERC20("SunCoin", "SNC") ERC20Permit("SunCoin") {
        if (address(USDT) == address(0)) revert CannotBeZero();
    }

    /**
     * @dev See {IERC4626-deposit}.
     */
    function deposit(uint256 assets, address receiver) external returns (uint256 shares) {
        shares = computeDeposit(assets, totalSupply());
        _deposit(receiver, assets, shares);
    }

    /**
     * @dev See {IERC4626-mint}.
     */
    function mint(uint256 shares, address receiver) external returns (uint256 assets) {
        assets = computeMint(shares, totalSupply());
        _deposit(receiver, assets, shares);
    }

    function currentPrice() external returns (uint256 price) {
        uint256 supply = totalSupply() + buffer;
        price = supply / totalAssetsHold;
    }

    function totalAssets() external view returns (uint256 totalManagedAssets) {
        totalManagedAssets = totalAssetsHold;
    }

    function safeDeposit(uint256 assets, address receiver, uint256 minSharesOut) external returns (uint256 shares) {
        shares = computeDeposit(assets, totalSupply());
        if (shares < minSharesOut) revert SlippageError();
        _deposit(receiver, assets, shares);
    }

    /**
     * @dev Implements {IERC4626-withdraw} and protects againts slippage by specifying a maximum number of shares to burn.
     * @param maxSharesIn The maximum number of shares the sender is willing to burn.
     */
    function safeWithdraw(uint256 assets, address receiver, address owner, uint256 maxSharesIn)
    external
    returns (uint256 shares)
    {
        revert();
    }

    /**
     * @dev Implements {IERC4626-deposit} and protects againts slippage by specifying a maximum amount of assets to deposit.
     * @param maxAssetsIn The maximum amount of assets the sender is willing to deposit.
     */
    function safeMint(uint256 shares, address receiver, uint256 maxAssetsIn) external returns (uint256 assets) {
        assets = computeMint(shares, totalSupply());
        if (assets > maxAssetsIn) revert SlippageError();
        _deposit(receiver, assets, shares);
    }

    /**
     * @dev Implements {IERC4626-redeem} and protects againts slippage by specifying a minimum amount of assets to receive.
     * @param minAssetsOut The minimum amount of assets the sender expects to receive.
     */
    function safeRedeem(uint256 shares, address receiver, address owner, uint256 minAssetsOut)
    external
    returns (uint256 assets)
    {
        revert();
    }

    /**
    * @dev See {IERC4626-previewDeposit}.
     */
    function previewDeposit(uint256 assets) external view returns (uint256 shares) {
        revert();
    }

    /**
     * @dev See {IERC4626-previewWithdraw}.
     */
    function previewWithdraw(uint256 assets) external view returns (uint256 shares) {
        revert();
    }

    /**
     * @dev See {IERC4626-previewMint}.
     */
    function previewMint(uint256 shares) external view returns (uint256 assets) {
        revert();
    }

    /**
     * @dev See {IERC4626-previewRedeem}.
     */
    function previewRedeem(uint256 shares) external view returns (uint256 assets) {
        revert();
    }

    /**
     * @dev See {IERC4626-maxDeposit}.
     */
    function maxDeposit(address) external pure returns (uint256 maxAssets) {
        return type(uint256).max;
    }

    /**
     * @dev See {IERC4626-maxMint}.
     */
    function maxMint(address) external pure returns (uint256 maxShares) {
        return type(uint256).max;
    }

    /**
     * @dev See {IERC4626-maxWithdraw}.
     */
    function maxWithdraw(address owner) external view returns (uint256 maxAssets) {
        revert();
    }

    /**
     * @dev See {IERC4626-maxRedeem}.
     */
    function maxRedeem(address owner) external view returns (uint256 maxShares) {
        return balanceOf(owner);
    }

    /**
     * @dev See {IERC4626-asset}.
     */
    function asset() external pure returns (address assetTokenAddress) {
        return address(USDT);
    }

    /**
    * @dev See {IERC4626-convertToAssets}.
     */
    function convertToAssets(uint256 shares) external view returns (uint256 assets) {
        if (totalSupply() < shares) revert Undersupply();
        uint256 ratio = totalSupply() / totalAssetsHold;
        assets = shares * ratio;
    }

    /**
      * @dev See {IERC4626-convertToShares}.
     */
    function convertToShares(uint256 assets) external view returns (uint256 shares) {
        if (totalAssetsHold < assets) revert Undersupply();

        uint256 ratio = totalAssetsHold / totalSupply();
        shares = assets * ratio;
    }

    function computeDeposit(uint256 assets, uint256 totalSupply) public returns (uint256 shares) {
        totalAssetsHold = totalAssetsHold + assets;
        uint256 totalDistribution = totalSupply + assets;
        uint256 ratio = totalDistribution / totalAssetsHold;
        return assets * ratio;
    }

    function computeMint(uint256 shares, uint256 totalSupply) public returns (uint256 assets) {
        totalAssetsHold = totalAssetsHold + shares;
        uint256 totalDistribution = totalSupply + shares;
        uint256 ratio =  totalAssetsHold / totalDistribution;
        return assets * ratio;
    }

    function burnTokens(address owner, uint256 tokens) public {
        _burn(owner, tokens);
    }

    function withdraw(uint256 assets, address receiver, address owner) external returns (uint256 shares) {
        revert();
    }

    function redeem(uint256 shares, address receiver, address owner) external returns (uint256 assets) {
        revert();
    }

    /**
     * @dev Deposit/mint common workflow.
     */
    function _deposit(address receiver, uint256 assets, uint256 shares) internal {
        if (assets == 0) revert CannotBeZero();
        if (shares == 0) revert CannotBeZero();
        if (!USDT.transferFrom(msg.sender, address(this), assets)) {
            revert TransferError();
        }
        emit Deposit(msg.sender, receiver, assets, shares);
        _mint(receiver, shares);
    }

}
