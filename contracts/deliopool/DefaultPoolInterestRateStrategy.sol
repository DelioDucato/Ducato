pragma solidity ^0.6.0;

import "../interfaces/IPoolInterestRateStrategy.sol";
import "../libraries/WadRayMath.sol";
import "../configuration/DelioPoolAddressesProvider.sol";
//import "./LendingPoolCore.sol";
//import "../interfaces/ILendingRateOracle.sol";

import "openzeppelin-solidity/contracts/math/SafeMath.sol";

contract DefaultPoolInterestRateStrategy is IPoolInterestRateStrategy {
    using WadRayMath for uint256;
    using SafeMath for uint256;

    /**
    * @dev this constant represents the utilization rate at which the pool aims to obtain most competitive borrow rates
    * expressed in ray
    **/
    uint256 public constant OPTIMAL_UTILIZATION_RATE = 0.8 * 1e27;

   /**
    * @dev this constant represents the excess utilization rate above the optimal. It's always equal to
    * 1-optimal utilization rate. Added as a constant here for gas optimizations
    * expressed in ray
    **/

    uint256 public constant EXCESS_UTILIZATION_RATE = 0.2 * 1e27;

    DelioPoolAddressesProvider public addressesProvider;


    //base variable borrow rate when Utilization rate = 0. Expressed in ray
    uint256 public baseVariableBorrowRate;

    //slope of the variable interest curve when utilization rate > 0 and <= OPTIMAL_UTILIZATION_RATE. Expressed in ray
    uint256 public variableRateSlope1;

    //slope of the variable interest curve when utilization rate > OPTIMAL_UTILIZATION_RATE. Expressed in ray
    uint256 public variableRateSlope2;

    constructor(
        DelioPoolAddressesProvider _provider,
        uint256 _baseVariableBorrowRate,
        uint256 _variableRateSlope1,
        uint256 _variableRateSlope2
    ) public {
        addressesProvider = _provider;
        baseVariableBorrowRate = _baseVariableBorrowRate;
        variableRateSlope1 = _variableRateSlope1;
        variableRateSlope2 = _variableRateSlope2;
    }

    /**
    @dev accessors
     */

    function getBaseVariableBorrowRate() external virtual override view returns (uint256) {
        return baseVariableBorrowRate;
    }

    function getVariableRateSlope1() external view returns (uint256) {
        return variableRateSlope1;
    }

    function getVariableRateSlope2() external view returns (uint256) {
        return variableRateSlope2;
    }

    /**
    * @dev calculates the interest rates depending on the available liquidity and the total borrowed.
    * @param _availableLiquidity the liquidity available in the reserve
    * @param _totalBorrowsVariable the total borrowed from the reserve at a variable rate
    **/
    function calculateInterestRates(
        uint256 _availableLiquidity,
        uint256 _totalBorrowsVariable
    )
        external virtual override
        view
        returns (
            uint256 currentLiquidityRate,
            uint256 currentVariableBorrowRate
        )
    {
        uint256 totalBorrows = _totalBorrowsVariable;

        uint256 utilizationRate = (totalBorrows == 0 && _availableLiquidity == 0)
            ? 0
            : totalBorrows.rayDiv(_availableLiquidity.add(totalBorrows));

        
        if (utilizationRate > OPTIMAL_UTILIZATION_RATE) {
            uint256 excessUtilizationRateRatio = utilizationRate
                .sub(OPTIMAL_UTILIZATION_RATE)
                .rayDiv(EXCESS_UTILIZATION_RATE);

           currentVariableBorrowRate = baseVariableBorrowRate.add(variableRateSlope1).add(
                variableRateSlope2.rayMul(excessUtilizationRateRatio)
            );
        } else {
            currentVariableBorrowRate = baseVariableBorrowRate.add(
                utilizationRate.rayDiv(OPTIMAL_UTILIZATION_RATE).rayMul(variableRateSlope1)
            );
        }

        currentLiquidityRate = getOverallBorrowRateInternal(
            _totalBorrowsVariable,
            currentVariableBorrowRate
        )
            .rayMul(utilizationRate);

    }

    /**
    * @dev calculates the overall borrow rate as the weighted average between the total variable borrows and total stable borrows.
    * @param _totalBorrowsVariable the total borrowed from the reserve at a variable rate
    * @param _currentVariableBorrowRate the current variable borrow rate
    **/
    function getOverallBorrowRateInternal(
        uint256 _totalBorrowsVariable,
        uint256 _currentVariableBorrowRate
    ) internal pure returns (uint256) {
        uint256 totalBorrows = _totalBorrowsVariable;

        if (totalBorrows == 0) return 0;

        uint256 weightedVariableRate = _totalBorrowsVariable.wadToRay().rayMul(
            _currentVariableBorrowRate
        );

        uint256 overallBorrowRate = weightedVariableRate.rayDiv(
            totalBorrows.wadToRay()
        );

        return overallBorrowRate;
    }
}