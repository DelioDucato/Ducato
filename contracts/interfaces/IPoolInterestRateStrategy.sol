pragma solidity ^0.6.0;


/**
@title IPoolInterestRateStrategy interface
@notice Interface for the calculation of the interest rates.
*/

interface IPoolInterestRateStrategy {

    /**
    * @dev returns the base variable borrow rate, in rays
    */

    function getBaseVariableBorrowRate() external view returns (uint256);
    /**
    * @dev calculates the liquidity, and variable rates depending on the current utilization rate
    *      and the base parameters
    *
    */
    function calculateInterestRates(
        address _reserve,
        uint256 _utilizationRate,
        uint256 _totalBorrowsVariable
    )
    external
    view
    returns (uint256 liquidityRate, uint256 variableBorrowRate);
}