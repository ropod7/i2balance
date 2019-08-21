pragma solidity ^0.5.0;

import "../GRSystem.sol";
import "./method.sol";
import "../cb/CBStandard.sol";

contract CBMSMethod is Method {
    
    address public cbmsAddr;
    CBMS public cbmSystem;
    
    function construction(address _grs, bytes32 _name)
        internal returns (bool)
    {
        assert(baseConstructor(_grs, _name));
        assert(cbmsAddr == address(0));
        cbmsAddr = grSystem.extensions(bytes4("CBMS"));
        require(cbmsAddr > address(0));
        cbmSystem = CBMS(cbmsAddr);
        return true;
    }
}

contract CBMSMethodMaker is CBMSMethod {
    function make(address _object, address _sender, uint256 _value) external returns (bool);
}

contract CBMSMethodGetter is CBMSMethod {
    function get(address _object, address _sender) external view returns (uint256);
}

contract GetCommonCentralBanks is CBMSMethodGetter {

    constructor (address _grs) public {
        assert(baseConstructor(_grs, bytes32("GetCommonCentralBanks")));
    }
    
    function get(address _object, address _sender)
        onlyByGRS
        zeroObject(_object)
        external view returns (uint256) 
    {
        return uint256(cbmSystem.commonCentralBanks(_sender));
    }
}

contract GetDriversCentralBanks is CBMSMethodGetter {

    constructor (address _grs) public {
        assert(baseConstructor(_grs, bytes32("GetDriversCentralBanks")));
    }
    
    function get(address _object, address _sender)
        onlyByGRS
        zeroObject(_object)
        external view returns (uint256) 
    {
        return uint256(cbmSystem.getDriversCentralBank(_sender));
    }
}

contract GetMedicalCentralBanks is CBMSMethodGetter {

    constructor (address _grs) public {
        assert(baseConstructor(_grs, bytes32("GetMedicalCentralBanks")));
    }
    
    function get(address _object, address _sender)
        onlyByGRS
        zeroObject(_object)
        external view returns (uint256) 
    {
        return uint256(cbmSystem.medicalCentralBanks(_sender));
    }
}


