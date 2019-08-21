pragma solidity >=0.5.1 <0.6.0;

import "../../GRSystem.sol";
import "../../common.sol";
import "../../drivers/DriverStandard.sol";
import "../constructors.sol";

/*
/// @title `PreCompany` contract should be created first to set up construction data
/// of `Company` contract. After regisration of this contract:
/// 1. If number of owners more than one, each owner will send sign to ownersSigns, to 
/// confirm defined ownership value.
/// 2. msg.sender should register `Company` contract through `CreateCompanyContract` `Method`.
/// Such type of contract is a handshake of owners in multiple owners case.
*/
contract PreCompany is CompanyConstructor {

    /* Creator of `PreCompany` contract to compare on the side of `CreateCompanyContract` method */
    address public creator;
    /* Mapping contains signs of owners */
    mapping (address => bool) public ownersSigns;

    constructor (
            address _grs,
            address _cb,
            bytes32 _name,
            address[] memory _owners,      
            uint256[] memory _ownership,
            address _realEstate,
            bytes32 _city,
            bytes32 _street,
            uint256 _postalCode,
            bytes32 _homeNumber
        ) public
    {
        assert(construction(
            _grs, _cb, _name, _owners, _ownership, _realEstate, _city,
            _street, _postalCode, _homeNumber
            ));
        creator = msg.sender;
    }
    
    /*
    /// @notice First step before `Company` creation to register sign by each owner to
    /// confirm defined ownership value which had been set for him.
    /// @param _owner (or one of owners) of the `Company`
    /// @return Whether the transfer was successful or not
    */
    function setOwnerSign(address _owner)
        onlyByActiveMethod
        external returns (bool)
    {
        assert(owners.length > 0);
        assert(ownership[_owner] > 0);
        assert(!ownersSigns[_owner]);
        ownersSigns[_owner] = true;
        return true;
    }
}

contract EmployeeProjectDiary {
    
    /* address of Ethereum account of `Project` manager  */
    address creatorOwner;
    /* The address of `Employee` contract of `Project` manager (see roles in `Project`) */
    address creator;
    /* Address of `Entity` contract */
    address entity;
    /* address of Ethereum account of `Employee` */
    address owner;
    /* Address of `Employee` contract */
    address employee;
    /* Address of `Project` contract */
    address project;
    
    /* Is approvable units by `Project` manager which has been done by `Employee` or not */
    bool approvableUnitsByManager;
    
    /* Accounting of hours per day in week */
    mapping (uint256 => mapping (uint8 => uint256)) hoursDonePerDay;
    /* Accounting done units per day in week (units described in `Employee.SalaryRatePer` enum) */
    mapping (uint256 => mapping (uint8 => uint256)) unitsDonePerDay;
    /* Approved units and hours by `Project` manager or not */
    mapping (uint256 => mapping (uint8 => bool)) approvedByManager;
    /* Registered units in `Project` or not */
    mapping (uint256 => mapping (uint8 => bool)) registeredInProject;
    
    /* To interact easier will be modifieble by Ethereum account of `Employee` */
    modifier onlyByEmployee() {
        require(owner == msg.sender);
            _;
    }
    
    /* To interact easier will be modifieble by Ethereum account of `Project` or `Company` manager */
    modifier onlyByManager() {
        require(
            owner == msg.sender 
            );
            _;
    }
    
    constructor (
            address _creatorOwner,
            address _creator,
            address _entity,
            address _owner,
            address _employee,
            address _project
        ) public
    {
        require(_creatorOwner > address(0));
        require(_creator > address(0));
        require(_entity > address(0));
        require(_owner > address(0));
        require(_employee > address(0));
        require(_project > address(0));
        creatorOwner = _creatorOwner;
        creator = _creator;
        entity = _entity;
        owner = _owner;
        employee = _employee;
        project = _project;
    }
}
