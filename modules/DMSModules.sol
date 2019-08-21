pragma solidity ^0.5.0;

import "../GRSystem.sol";
import "./method.sol";

contract DMSMethod is Method {
    
    address public dmsAddr;
    DMS public dmSystem;
    
    function construction(address _grs, bytes32 _name)
        internal returns (bool)
    {
        assert(baseConstructor(_grs, _name));
        assert(dmsAddr == address(0));
        dmsAddr = grSystem.extensions(bytes4("DMS"));
        require(dmsAddr > address(0));
        dmSystem = DMS(dmsAddr);
        return true;
    }
} 

contract DMSMethodMaker is DMSMethod {
    function make(address _object, address _sender, uint256 _value) external returns (bool);
}

contract DMSMethodGetter is DMSMethod {
    function get(address _object, address _sender) external view returns (uint256);
}

contract GetEthereumAccount is DMSMethodGetter {

    constructor (address _grs) public {
        assert(baseConstructor(_grs, bytes32("GetEthereumAccount")));
    }
    
    function get(address _object, address _sender)
        onlyByGRS
        zeroObject(_object)
        external view returns (uint256) 
    {
        return uint256(dmSystem.getEthereumAccount(_sender));
    }
}

contract GetActivatedDriversBy is DMSMethodGetter {
    
    constructor (address _grs) public {
        assert(baseConstructor(_grs, bytes32("GetActivatedDriversBy")));
    }
    
    function get(address _object, address _sender)
        onlyByGRS
        zeroObject(_object)
        external view returns (uint256) 
    {
        return uint256(dmSystem.activatedDriversBy(_sender));
    }
}
