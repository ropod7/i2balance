pragma solidity >=0.5.1 <0.6.0;

import "../common.sol";
import "../GRSystem.sol";
import "../cb/CBStandard.sol";
import "./constructors.sol";

/*
/// @title `PreDriver` contract should be created first to set up construction data
/// of `Driver` contract. After regisration of this contract msg.sender should 
/// register `Driver` contract through `CreateDriverContract` `Method`.
*/
contract PreDriver is DriverConstructor {
    /* Creator of `PreDriver` contract to compare on the side of `CreateDriverContract` method */
    address public creator;
    
    /* Allowance only for active `GRS` `Method` */
    modifier onlyByActiveMethod() {
        require(grSystem.activeMethods(msg.sender));
            _;
    }
    
    constructor (
            address _grs,
            bytes32 _firstName,
            bytes32 _lastName,
            bytes2 _gender,
            uint256 _dt,
            uint256 _older,
            bytes2[8] memory _bc,
            /* Week may be zero if person was born before start of new Epoch */
            uint256 _weekn
        ) public 
    {
        assert(construction(_grs, _firstName, _lastName, _gender, _dt, _older, _bc, _weekn));
        creator = msg.sender;
    }
    
    /* First name getter */
    function getFirstName()
        onlyByActiveMethod
        external view returns (bytes32) 
    {
        return name.firstName;
    }
    
    /* Last name getter */
    function getLastName()
        onlyByActiveMethod
        external view returns (bytes32) 
    {
        return name.lastName;
    }
    
    /* Birth timestamp getter */
    function getBirthTimestamp()
        onlyByActiveMethod
        external view returns (uint256) 
    {
        return birthTimestamp;
    }
    
    /* Older than UNIX epoch timestamp getter */
    function getOlderTimestamp()
        onlyByActiveMethod
        external view returns (uint256) 
    {
        return olderTimestamp;
    }
    
    /* Birth coordinates getter */
    function getBirthCoordinates()
        onlyByActiveMethod
        external view returns (bytes2[8] memory) 
    {
        return birthCoordinates;
    }
}
