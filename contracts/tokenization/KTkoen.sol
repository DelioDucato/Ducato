pragma solidity ^0.6.0;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "../libraries/WadRayMath.sol";



contract KToken is ERC20 {
   // using SafeMath for uint256;
    using WadRayMath for uint256;

    uint256 public constant UINT_MAX_VALUE = uint256(-1);

    
    event Redeem(
        address indexed _from,
        uint256 _value,
        uint256 _fromBalanceIncrease,
        uint256 _fromIndex
    );

    
    event BurnOnLiquidation(
        address indexed _from,
        uint256 _value,
        uint256 _fromBalanceIncrease,
        uint256 _fromIndex
    );

    event BalanceTransfer(
        address indexed _from,
        address indexed _to,
        uint256 _value,
        uint256 _fromBalanceIncrease,
        uint256 _toBalanceIncrease,
        uint256 _fromIndex,
        uint256 _toIndex
    );

    address public underlyingAssetAddress;

    mapping (address => uint256) private userIndexes;
    mapping (address => address) private interestRedirectionAddresses;
    mapping (address => uint256) private redirectedBalances;
    mapping (address => address) private interestRedirectionAllowances;

    modifier whenTransferAllowed(address _from, uint256 _amount) {
        require(isTransferAllowed(_from, _amount), "Transfer cannot be allowed.");
        _;
    }

    constructor(
        address _underlyingAsset,
        string memory _name,
        string memory _symbol
    ) public ERC20(_name, _symbol) {

      underlyingAssetAddress = _underlyingAsset;
    }

    function name() public virtual override view returns(string memory) {
        return super.name();
    }

    function symbol() public virtual override view returns(string memory) {
        return super.symbol();
    }

    function decimals() public virtual override view returns(uint8) {
        return super.decimals();
    }

    function _transfer(address _from, address _to, uint256 _amount) internal virtual override whenTransferAllowed(_from, _amount) {

        executeTransferInternal(_from, _to, _amount);
    }

    function redeem(uint256 _amount) external {
    }

    function burnOnLiquidation(address _account, uint256 _value) external  {
    }

    function transferOnLiquidation(address _from, address _to, uint256 _value) external  {
    }

    function balanceOf(address _user) public virtual override view returns(uint256) {
    }

    function principalBalanceOf(address _user) external view returns(uint256) {
        return super.balanceOf(_user);
    }
    
    /**
    * @dev calculates the total supply of the specific kToken
    * since the balance of every single user increases over time, the total supply
    * does that too.
    * @return the current total supply
    **/
    function totalSupply() public virtual override view returns(uint256) {
    }

    /**
     * @dev Used to validate transfers before actually executing them.
     * @param _user address of the user to check
     * @param _amount the amount to check
     * @return true if the _user can transfer _amount, false otherwise
     **/
    function isTransferAllowed(address _user, uint256 _amount) public view returns (bool) {
    }

    function getUserIndex(address _user) external view returns(uint256) {
    }

    function cumulateBalanceInternal(address _user)
        internal
        returns(uint256, uint256, uint256, uint256) {
    }

    function calculateCumulatedBalanceInternal(
        address _user,
        uint256 _balance
    ) internal view returns (uint256) {
    }

    function executeTransferInternal(
        address _from,
        address _to,
        uint256 _value
    ) internal {
    }

    function resetDataOnZeroBalanceInternal(address _user) internal returns(bool) {
    }
}
