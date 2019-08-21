pragma solidity >=0.5.1 <0.6.0;

import "../common.sol";
import "../GRSystem.sol";
import "../cb/CBStandard.sol";

/*
/// @title Common construction data handler of `PreDriver` and `Driver` contracts.
*/
contract DriverConstructor {
    /*
    /// GRS system address. In real life should look like:
    /// address public constant grsAddr = "0x1234...";
    */
    address public grsAddr;
    /*
    /// And then this definition Also should:
    /// GRS public grSystem = GRS("0x1234...");
    */
    GRS public grSystem;
    /*
    ///
    ////// `Drivers` personal data
    ///
    */
    struct Name {
        bytes32 firstName;
        bytes32 lastName;
    }
    Name public name;
    /* Persons Gender. eg. XX - female, XY - male */
    bytes2 public gender;
    /* Week of birth from new Epoch */
    uint256 public birthWeek;
    /* timestamp of person birth in Unix format */
    uint256 birthTimestamp;
    /* Desc. seconds from 01.01.1970 if person older */
    uint256 olderTimestamp;
    /*
    /// Coordinates of birth. eg. 59°26′14″N 24°44′43″E
    /// Should looks like [59, 26, 14, 0N, 24, 44, 43, 0E], or:
    /// [0x3539,0x3236,0x3134,0x304e,0x3234,0x3434,0x3433,0x3045] in bytes2[8]
    */
    bytes2[8] birthCoordinates;
    
    function construction (
            address _grs,
            bytes32 _firstName,
            bytes32 _lastName,
            bytes2 _gender,
            uint256 _dt,
            uint256 _older,
            bytes2[8] memory _bc,
            /* Week may be zero if person was born before start of new Epoch */
            uint256 _weekn
        )
        internal returns (bool)
    {
        /* Just "one-off function"  */
        assert(grsAddr == address(0));
        require(_grs > address(0));
        require(_firstName.length > 2);
        require(_lastName.length > 2);
        /* XX || XY */
        require(_gender == 0x5858 || _gender == 0x5859);
        require(_dt > 0 && _dt < now);
        /* 0S || 0N - (North or South) */
        require(_bc[3] == 0x0053 || _bc[3] == 0x004e);
        /* 0E || 0W - (East or West) */
        require(_bc[7] == 0x0045 || _bc[7] == 0x0057);
        grsAddr = _grs;
        grSystem = GRS(_grs);
        name.firstName = _firstName;
        name.lastName  = _lastName;
        gender = _gender;
        if (_dt == 1 && _older > 0) {
            olderTimestamp = _older;
        } else if (_dt > 0) {
            birthTimestamp = _dt;
        } else {
            revert();
        }

        if (_weekn > 0)
            birthWeek = _weekn;
        return true;
    }
}
