    pragma solidity ^0.6.0;

/**
 * @title Proxy
 * @dev Implements delegation of calls to other contracts, with proper
 * forwarding of return values and bubbling of failures.
 * It defines a fallback function that delegates all calls to the address
 * returned by the abstract _implementation() internal function.
 */
 
abstract contract Proxy {
    event Received(address, uint);
    fallback() external payable {
        _fallback();
    }

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    function _implementation() virtual internal view returns (address);

    function _delegate(address implementation) internal {
           assembly {
           calldatacopy(0, 0, calldatasize())

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            // Copy the returned data.
            returndatacopy(0, 0, returndatasize())

            switch result
                // delegatecall returns 0 on error.
                case 0 {
                    revert(0, returndatasize())
                }
                default {
                    return(0, returndatasize())
                }
        }
    }

    /**
   * @dev Function that is run as the first thing in the fallback function.
   * Can be redefined in derived contracts to add functionality.
   * Redefinitions must call super._willFallback().
   */
   
   // function _willFallback() virtual internal {}
    function _fallback() internal {
          _delegate(_implementation());
    }
}


    

    

