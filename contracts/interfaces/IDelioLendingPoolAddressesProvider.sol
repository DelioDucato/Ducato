pragma solidity ^0.6.0;


/**
@title ILendingPoolAddressesProvider interface
@notice provides the interface to fetch the LendingPoolCore address
 */

interface IDelioLendingPoolAddressesProvider {

   function getDelioLendingPool() external view returns (address);
   function setDelioLendingPoolImpl(address _pool) external;
   function getDelioLendingPoolCore() external view returns (address payable);
   function getDelioLendingPoolDataProvider() external view returns (address);
}