pragma solidity ^0.6.0;

/************
@title IFeeProvider interface
@notice Interface for the Delio fee provider.
*/

interface IFeeProvider {
    function calculateLoanOriginationFee(address _user, uint256 _amount) external view returns (uint256);
    function getLoanOriginationFeePercentage() external view returns (uint256);
}
