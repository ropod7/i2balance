pragma solidity >=0.5.1 <0.6.0;

import "../GRSystem.sol";
import "../common.sol";

/*
/// @title Method Interface contains just one, universal `make` funtcion.
*/
contract Method {
    
    /*
    /// GRS system address. In real life should look like:
    /// address public constant grsAddr = "0x1234...";
    */
    address public grsAddr;
    /*
    /// And then this definition Also:
    /// GRS public grSystem = GRS("0x1234...");
    */
    GRS public grSystem;
    
    /* Version of `Method` in `GRS` with the same name */
    uint256 public version;
    /* The name of method */
    bytes32 public methodName;
    /* Minimal value of any product and service in economy system */
    uint256 public constant cent = 1000;
    /* Allowance to call only from `GRS` contract */
    modifier onlyByGRS() {
        require(msg.sender == grsAddr);
            _;
    }
    
    /* Only zero value */
    modifier zeroValue(uint256 _value) {
        require(_value == 0);
            _;
    }
    
    /* Rigid rules for financial management */
    modifier onlyRigidAmount(address _object) {
        require(uint(_object) % cent == 0);
            _;
    }
    
    /* Check that subject is as uint8 and less than or equals to max address */
    modifier subjectAsUint8(address _object) {
        require(uint(_object) <= 255);
        require(uint(_object) > 0);
            _;
    }
    
    /* Check that subject is as uint8 and less than or equals to max address */
    modifier subjectAsAddress(uint256 _subject) {
        require(address(_subject) <= 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF);
        require(_subject > 0);
            _;
    }
    
    /* Check that object is empty unit */
    modifier zeroObject(address _object) {
        require(_object == address(0));
            _;
    }
    
    function baseConstructor(address _grs, bytes32 _name)
        internal returns (bool)
    {
        require(_grs > address(0));
        /* baseConstructor is one time function */
        assert(grsAddr == address(0));
        grsAddr = _grs;
        grSystem = GRS(_grs);
        address previous = grSystem.methods(_name);
        /* Increase of `Method` version */
        version = (previous > address(0)) ? Method(previous).version() + 1 : 1;
        require(grSystem.setMethod(_name, address(this)));
        methodName = _name;
        return true;
    }
    
    function _year() internal view returns (uint256) {
        return grSystem.year();
    }
    
    function _week() internal view returns (uint256) {
        return grSystem.week();
    }
    
    function _extension(bytes4 _name) internal view returns (address) {
        address ext = grSystem.extensions(_name);
        assert(ext > address(0));
        return ext;
    }
    
    function _operator() internal view returns (Operator) {
        return grSystem.operator();
    }
}

contract MethodMaker is Method {
    function make(address _object, address payable _sender, uint256 _value) external returns (bool);
}

contract MethodGetter is Method {
    function get(address _object, address _sender) external view returns (uint256);
}

contract ExecMethod is Method {

    /*
    ///
    ////// Global enums for any `Entity`
    ///
    */

    /*
    /// List of possible States of any `Entity` Activities.
    /// If `Entity` once deactivated will be no way to activate it back, and in this case
    /// assignation of `Entity` name in global names list will be removed:
    /// see `CMS.globalCompanyNames` and `CB.localCompanyNames;`
    */
    enum EntityActivity {deactivated, active, underSanctions, freezed}
    /* Current `Entity` state of activity */
    EntityActivity entityActivity;
    
    /* 
    /// Signs of Authorization of Employee in `Entity`. 
    /// Each authority has own permission in `Entity`.
    */
    enum Authorization {restricted, inOwnership, bookkeeping, manager, inDismissal} // extendable enum list
    /* Sign of current Employee activity */
    Authorization employersAuthorization;
    
    /* All available salary rates per, or task-work */
     enum SalaryRatePer {hour, day, week, month, piecework}
    /* Projects Salary base */
    SalaryRatePer salaryRatePer;
    
    /* Available roles of `Entity` customer */
    enum CustomerRole {unknown, customer, regular}
    /* Role for each customer per address */
    CustomerRole customerRole;
}

contract ExecMethodMaker is ExecMethod {
    function execMake(address payable _driver, address _object, address _entity, uint256 _value) external returns (bool);
}

contract ExecMethodGetter is ExecMethod {
    function execGet(address _driver, address _object, address _entity) external view returns (uint256);
}
