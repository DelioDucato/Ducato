pragma solidity ^0.6.0;

import "openzeppelin-solidity/contracts/access/Ownable.sol";
import "../libraries/openzeppelin-upgradeability/InitializableAdminUpgradeabilityProxy.sol";
import "./AddressStorage.sol";
import "../interfaces/IDelioLendingPoolAddressesProvider.sol";

/**
* @title DelioLendingPoolAddressesProvider contract
* @notice Is the main registry of the protocol. All the different components of the protocol are accessible
* through the addresses provider.
* @author Ducato
**/

contract DelioLendingPoolAddressesProvider is Ownable, IDelioLendingPoolAddressesProvider, AddressStorage{
         
      event LendingPoolUpdated(address indexed newAddress);
      event ProxyCreated(bytes32 id, address indexed newAddress);

      bytes32 private constant LENDING_POOL = "LENDING_POOL";
      bytes32 private constant LENDING_POOL_CORE = "LENDING_POOL_CORE";
      bytes32 private constant DATA_PROVIDER = "DATA_PROVIDER";
    
      /**
      * @dev returns the address of the DelioLendingPool proxy
      **/
      function getDelioLendingPool() public override view returns (address) {
         return getAddress(LENDING_POOL);
      }

      /**
      * @dev updates the implementation of the Delio lending pool
      * @param _pool the new Delio ending pool implementation
      **/
      function setDelioLendingPoolImpl(address _pool) public override onlyOwner {
      //  updateImplInternal(LENDING_POOL, _pool);
        emit LendingPoolUpdated(_pool);
      }

      /**
      * @dev returns the address of the DelioLendingPoolCore proxy
      */
      function getDelioLendingPoolCore() public override view returns (address payable) {
        address payable core = address(uint160(getAddress(LENDING_POOL_CORE)));
        return core;
      }

    
      /**
      * @dev returns the address of the DelioLendingPoolDataProvider proxy
      */
      function getDelioLendingPoolDataProvider() public override view returns (address) {
        return getAddress(DATA_PROVIDER);
      }

      /**
    * @dev internal function to update the implementation of a specific component of the protocol
    * @param _id the id of the contract to be updated
    * @param _newAddress the address of the new implementation
    **/
    function updateImplInternal(bytes32 _id, address _newAddress) internal {
           
        address payable proxyAddress = address(uint160(getAddress(_id)));

        InitializableAdminUpgradeabilityProxy proxy = InitializableAdminUpgradeabilityProxy(proxyAddress);
        bytes memory params = abi.encodeWithSignature("initialize(address)", address(this));

        if (proxyAddress == address(0)) {
            proxy = new InitializableAdminUpgradeabilityProxy();
            proxy.initialize(_newAddress, address(this), params);
            _setAddress(_id, address(proxy));
            emit ProxyCreated(_id, address(proxy));
        } else {
            proxy.upgradeToAndCall(_newAddress, params);
        }
          
    }

}