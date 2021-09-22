// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;

import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

/**
 * This class provides an example upgradeable smart contract with the following features:
 *     - adheres to the ERC20 token standard
 *     - applies a 10% transaction fee: 5% gone forever (burned) and 5% transferred to a liquidity pool
 *     - applies 10% annual interest for holders, compounded annualy
 *     - is upgradeable using OpenZeppelin's upgradeable contract model
 *
 * There will be comments throughout this file explaining the logic/reasoning behind each design choice
 * to help guide you in learning about smart contracts.
 *
 * You can see the source code for the base contracts at https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable.
 **/
contract MyUpgradeableContract is ERC20BurnableUpgradeable, OwnableUpgradeable
{
    /**
     * Indicates the precision of quantity traded for this token. 18 is standard.
     *
     * Let's say this number were 2. Whenever you see '1025' being traded, minted,
     * an so on within this file, that really means that 10.25 tokens are minted.
     *
     * That is why in the initializer of this contract, we are initializing 1 trillion * 10^18 tokens.
     **/
    uint8 private constant _decimalsImpl = 18;

    // Your contract should override this function to adhere to ERC20 standard.
    function decimals() public view virtual override returns (uint8) {
        return _decimalsImpl;
    }

    address private _minter; // save the address of the person who created this contract to allow for minter-only actions
    uint256 private _lastMintTime;
    uint256 private constant _mintIntervalSeconds = 604800; // one week
    uint256 private constant _oneYearSeconds = 31536000; // one year
    uint256 private constant _numIntervalsPerYear = _oneYearSeconds / _mintIntervalSeconds; // 52
    uint256 private constant _interestMultiplierPerYear = (10**_decimalsImpl) + (10**(_decimalsImpl-1)); // 1.1x interest per year;
    uint256 private constant _interestDivisorPerYear = 10; // 1/10 additional interest per year
    uint256 private constant _interestDivisorPerInterval = _interestDivisorPerYear * _numIntervalsPerYear;

    uint256 private constant _burnDivisor = 20; // 1/20 total burn amount (5% gone forever)
    uint256 private constant _liquidateDivisor = 20; // 1/20 total liquidate amount (5% to LP)

    mapping (address => bool) private _existingUsers;
    address[] private _orderedUsers; // ordered by creation of user address to allow for interest over all users

    address private _liquidityPoolAddress; // once liquidity pool address is known, should be set via SetLiquidityPoolAddresss()

    // Upgradeable contracts cannot have constructors, so an initializer method must be written to "construct" the contract
    function initialize() public initializer
    {
        // Call all of the base classes initializers of this contract, starting with the most base class first
        __Context_init_unchained();
        __ERC20_init_unchained("MyContract", "MyC"); // contract name and ticker
        __ERC20Burnable_init_unchained();
        __Ownable_init_unchained();

        uint256 startingSupply = (10**12) * (10**decimals()); // 1 trillion
        _minter = _msgSender();
        _orderedUsers.push(_minter);
        _existingUsers[_minter] = true;
        _mint(_minter, startingSupply);
        _lastMintTime = nowSeconds();

        // should be changed after contract deployment to the true liquidity pool address
        _liquidityPoolAddress = _minter;
    }

    function getSecondsSinceLastMint() private view returns (uint256)
    {
        return nowSeconds() - _lastMintTime;
    }

    function shouldMint() private view returns (bool)
    {
        return getSecondsSinceLastMint() > _mintIntervalSeconds;
    }

    function interest(address account) private
    {
        uint256 amountToMint = balanceOf(account) / _interestDivisorPerInterval;
        _mint(account, amountToMint);
    }

    function interestAll() private
    {
        for (uint i = 0; i < _orderedUsers.length; i++)
        {
            address temp = _orderedUsers[i];
            require(_existingUsers[temp]);
            assert(_existingUsers[temp]);
            interest(temp);
        }
        _lastMintTime = nowSeconds();
    }

    function forceInterestAll() public
    {
        require(_msgSender() == _minter);
        interestAll();
    }

    function getBurnAmount(uint256 amount) private pure returns (uint256)
    {
        uint256 burnAmount = amount / _burnDivisor;
        assert(burnAmount <= amount);
        return burnAmount;
    }

    function getLiquidateAmount(uint256 amount) private pure returns (uint256)
    {
        uint256 liquidateAmount = amount / _liquidateDivisor;
        assert(liquidateAmount <= amount);
        return liquidateAmount;
    }

    function getFeeAmount(uint256 amount) private pure returns (uint256, uint256)
    {
        uint256 burnAmount = getBurnAmount(amount);
        uint256 liquidateAmount = getLiquidateAmount(amount);
        uint256 removalAmount = burnAmount + liquidateAmount;
        assert(removalAmount <= amount);
        return (burnAmount, liquidateAmount);
    }

    function setLiquidityPoolAddress(address liquidityPoolAddress) public
    {
        require(_msgSender() == _minter);
        _liquidityPoolAddress = liquidityPoolAddress;
    }

    function transfer(address recipient, uint256 amount) public override returns (bool)
    {
        require(_msgSender() != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(balanceOf(_msgSender()) >= amount);

        // apply fees for the transaction
        (uint256 burnAmount, uint256 liquidateAmount) = getFeeAmount(amount);
        uint256 removalAmount = burnAmount + liquidateAmount;
        amount -= removalAmount;
        burn(burnAmount);
        super.transfer(_liquidityPoolAddress, liquidateAmount);
        super.transfer(recipient, amount);

        require(_existingUsers[_msgSender()]);
        handleMintOnTransfer(_msgSender(), recipient);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool)
    {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(balanceOf(sender) >= amount);
        require(allowance(sender, _msgSender()) >= amount, "ERC20: transfer amount exceeds allowance");

        // apply fees for the transaction
        (uint256 burnAmount, uint256 liquidateAmount) = getFeeAmount(amount);
        uint256 removalAmount = burnAmount + liquidateAmount;
        amount -= removalAmount;
        burnFrom(sender, burnAmount);
        super.transferFrom(sender, _liquidityPoolAddress, liquidateAmount);
        super.transferFrom(sender, recipient, amount);

        require(_existingUsers[_msgSender()]);
        require(_existingUsers[sender]);
        handleMintOnTransfer(sender, recipient);
        return true;
    }

    // The hook before all transfers allows us to keep track of which addresses exist for users
    function handleMintOnTransfer(address from, address to) private
    {
        bool fromAddressExists = _existingUsers[from];
        bool toAddressExists = _existingUsers[to];
        require(fromAddressExists);
        if (toAddressExists == false)
        {
            _existingUsers[to] = true;
            _orderedUsers.push(to);
        }
        
        if (shouldMint())
        {
            interestAll();
        }
    }

    function getNumUsers() external view returns (uint256) { return _orderedUsers.length; }
    function nowSeconds() private view returns (uint256) { return block.timestamp; }
    function getMinter() external view returns (address) { return _minter; }
    function getLiquidityPoolAddress() external view returns (address) { return _liquidityPoolAddress; }
}
