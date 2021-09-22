// SPDX-License-Identifier: MIT TODO change license if we want
pragma solidity 0.8.5;

import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract MyUpgradeableContract is ERC20BurnableUpgradeable, OwnableUpgradeable
{
    uint8 private constant _decimalsImpl = 18;

    function decimals() public view virtual override returns (uint8) {
        return _decimalsImpl;
    }

    address private _minter;
    uint256 private _lastMintTime;
    uint256 private constant _mintIntervalSeconds = 604800; // one week
    uint256 private constant _oneYearSeconds = 31536000; // one year
    uint256 private constant _numIntervalsPerYear = _oneYearSeconds / _mintIntervalSeconds; // 52
    uint256 private constant _interestMultiplierPerYear = (10**_decimalsImpl) + (10**(_decimalsImpl-1)); // 1.1x interest per year;
    uint256 private constant _interestDivisorPerYear = 10; // 1/10 additional interest per year
    uint256 private constant _interestDivisorPerInterval = _interestDivisorPerYear * _numIntervalsPerYear;

    uint256 private constant _burnDivisor = 20; // 1/20 total burn amount (5% to LP, 5% gonezo)
    uint256 private constant _liquidateDivisor = 20; // 1/20 total liquidate amount (5% to LP, 5% gonezo)

    mapping (address => bool) private _existingUsers;
    address[] private _orderedUsers; // ordered by creation of user address

    address private _liquidityPoolAddress;

    // Upgradeable contracts cannot have constructors, so an initializer method must be written to "construct" the contract
    function initialize() public initializer
    {
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

        _liquidityPoolAddress = _minter;
    }

    function getSecondsSinceLastMint() private view returns (uint256)
    {
        return nowSeconds() - _lastMintTime;
    }

    // This function returns the multiplier taking into account the decimals
    function getInterestMultiplierSinceLastMint() private view returns (uint256)
    {
        return _interestMultiplierPerYear * getSecondsSinceLastMint() / _oneYearSeconds;
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

    function getRemovalAmount(uint256 amount) private pure returns (uint256, uint256)
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
        // TODO these requirements are from the base class, but i need them to be called before burining
        require(_msgSender() != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(balanceOf(_msgSender()) >= amount);

        (uint256 burnAmount, uint256 liquidateAmount) = getRemovalAmount(amount);
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
        // TODO these requirements are from the base class, but i need them to be called before burining
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(balanceOf(sender) >= amount);
        require(allowance(sender, _msgSender()) >= amount, "ERC20: transfer amount exceeds allowance");

        (uint256 burnAmount, uint256 liquidateAmount) = getRemovalAmount(amount);
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
