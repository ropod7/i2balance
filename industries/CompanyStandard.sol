pragma solidity >=0.5.1 <0.6.0;

import "../GRSystem.sol";
import "../common.sol";
import "./constructors.sol";
import "./objects/operationalObjects.sol";
import "./objects/serviceObjects.sol";
import "../drivers/DriverStandard.sol";
import "../cb/CBStandard.sol";

/*
/// @title I2Balance Standard of `Company` Contract. 
/// `Company` in common case at this moment.
*/
contract Company is CompanyConstructor {
    /* version of `Company` contract */
    uint256 public contractVersion;

    /*
    ///
    ////// Part of General data of `Company`. See `CompanyConstructor`
    ///
    */
    /* timestamp of `Company` registration in Unix format */
    uint256 public registrationTimestamp;
    /* Struct of `Driver` photo */
    struct Logo {
        bytes image;
    }
    Logo public logo;

    /*
    /// List of possible States of `Company` Activities.
    /// If company once deactivated will be no way to activate it back, and in this case
    /// assignation of `Company` name in global names list will be removed:
    /// see `CMS.globalCompanyNames` and `CB.localCompanyNames;`
    */
    enum CompanyActivity {deactivated, active, underSanctions, freezed}
    /* Current `Company` state of activity */
    CompanyActivity public companyActivity;
    
    /*
    ///
    ////// Employment accounting of `Company`
    ///
    */
    /* List of all employees */
    address[] employees;
    /* Total amount of Employees */
    uint256 public totalEmployees;
    /* Timestamp of registartion of candidates */
    mapping (address => uint256) candidateFrom;
    /* Timestamp of registartion of employees */
    mapping (address => bool) isEmployee;
    /* `Employee` contract addresses for each employee */
    mapping (address => CompanyEmployee) employee;
    
    /* 
    /// Signs of Authorization of Employee in `Company`. 
    /// Each authority has own permission in `Company`.
    */
    enum Authorization {restricted, inOwnership, bookkeeping, manager, inDismissal} // extendable enum list
    /* Sign of current Employee activity */
    mapping (address => Authorization) public employersAuthorization;
    
    /*
    ///
    ////// `Project`s accounting of `Company`
    ///
    */
    /* List of all `Project` once been started */
    address[] projects;
    /* `Project`s in process of realization */
    mapping (address => bool) projectsInProcess;
    /* List of finished `Project`s */
    address[] finishedProjects;
    /* Sign of `Project` accomplishment */
    mapping (address => bool) projectDone;
    
    /*
    ///
    ////// `Company` safety statistics
    ///
    */
    /* Annual accounting of sick leaves (in days) of `Company` */
    mapping (uint256 => uint256) public annualAccountingOfSickLeaves;
    
    /* Weekly accounting of accidents (in the number of cases per human) of `Company` */
    mapping (uint256 => uint256) public weeklyAccountingOfAccidents;
    /* Annual accounting of accidents (in the number of cases per human) of `Company` */
    mapping (uint256 => uint256) public annualAccountingOfAccidents;
    
    /* Annual accounting of mortal accidents (in the number of cases per human) of `Company` */
    mapping (uint256 => uint256) public annualAccountingOfMortalAccidents;
    /* Accounting of total mortal accidents (in the number of cases per human) of `Company` */
    uint256 public totalMortalAccidents;
    
    /*
    ///
    ////// `Company`s property listing and accounting
    ///
    */
    /* Listing of `Company` subsidary undertakings */
    address[] public subsidaries;
    /* Checker of common `Company` subsidary undertakings. */
    mapping (address => bool) public subsidaryChecker;
    /* Listing of all properties of `Company`. Real estates, vehicles, etc. */
    address[] commonPropertyListing;
    /* Checker of common `Company` property. Real estates, vehicles, etc. */
    mapping (address => bool) propertyChecker;
    
    /*
    ///
    ////// `Company` custumers accpunting
    ///
    */
    /* Available roles of `Company` customer */
    enum CustomerRole {unknown, customer, regular}
    /* Role for each customer per address */
    mapping (address => CustomerRole) customers;
    
    /*
    ///
    ////// Accounting of Products and Services of `Company`
    ///
    */
    mapping (bytes8 => address) public products;

    mapping (address => bool) createdInvoices;
    mapping (address => bool) approvedInvoices;
    mapping (address => bool) paidInvoices;
    
    /* Only if `Company` is Active */
    modifier onlyAtActiveCompany() {
        assert(companyActivity == CompanyActivity.active);
            _;
    }
    
    /* Check that `Company` is not under sanctions or deactivated */
    modifier notAtDeactivatedCompany() {
        assert(
            CMS(_grsExtension(bytes4("CMS"))).companySanctionsExpires(address(this)) <= now ||
            companyActivity != CompanyActivity.deactivated
            );
                _;
    }
    
    /* Only if owner of `Company` */
    modifier onlyForOwner(address _owner) {
        require(ownership[_owner] > 0);
            _;
    }
    
    /* Allowance to call only for active drivers */
    modifier onlyForActiveDriver(address _driver) {
        require(DMS(_grsExtension(bytes4("DMS"))).activeDrivers(_driver));
            _;
    }
    
    /* Check that employee not at given state */
    modifier checkEmployeeActivity(address _employee, CompanyEmployee.EmployeeActivity _activity) {
        assert(isEmployee[_employee]);
        assert(employee[_employee].getEmployeeActivity() != _activity);
            _;
    }
    
    /* Allow access to data just for trusted employees */
    modifier getByTrusted(address _employee) {
        require(
            msg.sender == _employee                                         ||
            employersAuthorization[msg.sender] != Authorization.restricted  &&
            employersAuthorization[msg.sender] != Authorization.inDismissal 
            );
                _;
    }
    
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
            bytes32 _homeNumber,
            uint256 _version
        ) public 
    {
        assert(construction(
            _grs, _cb, _name, _owners, _ownership, _realEstate, _city,
            _street, _postalCode, _homeNumber
            ));
        registrationTimestamp = now;
        /* Activate `Company` on contract creation */
        companyActivity = CompanyActivity.active;
        /* Set each owner also to employee list */
        for (uint i=0; i<_owners.length; i++) {
            /* Will be set to employee only if active `Driver` */
            if (DMS(_grsExtension(bytes4("DMS"))).activeDrivers(_owners[i]))
                _addToEmployee(_owners[i]);
        }
        require(_version > 0);
        contractVersion = _version;
    }
    
    /* Returns the current year number */
    function _year() internal view returns (uint256) {
        return grSystem.year();
    }
    
    /* Returns the current week number */
    function _week() internal view returns (uint256) {
        return grSystem.week();
    }
    
    /*
    /// @notice The base executive `make` function communicates with `GRS.execMake`.
    /// `Company` should be active.
    /// @param _name Name of `GRS` `ExecMethod` (executive method).
    /// @param _object address of service, or operational object, or just any uint.
    /// @return Whether the transfer was successful or not
    */
    function execMake(bytes32 _name, address _object)
        onlyAtActiveCompany
        onlyByTrustedAdmins
        external payable returns (bool) 
    {
        return grSystem.execMake(_name, _object, msg.sender, msg.value);
    }
    
    /*
    /// @notice The base executive `get` function communicates with `GRS.execGet`.
    /// `Company` should be active.
    /// @param _name Name of `GRS` `ExecMethod` (executive method).
    /// @param _object address of service, or operational object, or just any uint.
    /// @return Any requested uint256 from global data.
    */
    function execGet(bytes32 _name, address _object)
        onlyAtActiveCompany
        onlyByTrustedAdmins
        external view returns (uint256) 
    {
        return grSystem.execGet(_name, _object, msg.sender);
    }
    
    /*
    /// @notice Add new owner of `Company` to the owners array.
    /// `Company` should be active.
    /// @param _owner (new, or one of owners) of the `Company`
    /// @return Whether the transfer was successful or not
    */
    function addOwner(address _owner)
        onlyAtActiveCompany
        onlyByActiveMethod
        external returns (bool)
    {
        require(_owner > address(0));
        require(!_operator().inAddressArray(owners, _owner));
        owners.push(_owner);
        return true;
    }
    
    /*
    /// @notice Remove owner from owners list. Before deletion owner should totally 
    /// give own percentage of ownersip to other (or new) owners. This method will be
    /// called from the same `Method` and after the `giveOwnership` function. 
    /// `Company` should be active.
    /// @param _owner (new, or one of owners) of the `Company`
    /// @return Whether the transfer was successful or not
    */
    function removeOwner(address _owner)
    /* Before deletion check that owner is in owners array */
        onlyForOwner(_owner)
        onlyAtActiveCompany
        onlyByActiveMethod
        external returns (bool)
    {
        /* Before deletion check also that owner has not any shares */
        assert(ownership[_owner] == 0);
        owners = _operator().removeFromAddressArray(owners, _owner);
        return true;
    }    
    
    /*
    /// @notice Assign share to new owner from public share if exists.
    /// Before assignment owner will be added to owners array. 
    /// This method will be called from the same `Method` and after 
    /// the `addOwner` function. 
    /// `Company` should be active.
    /// @param _owner (new, or one of owners) of the `Company`
    /// @param _share percentage of share.
    /// @return Whether the transfer was successful or not
    */
    function assignPercentageFromPublicShare(address _owner, uint256 _share)
    /* Before assignment check that new owner is in owners array */
        onlyForOwner(_owner)
        onlyAtActiveCompany
        onlyByActiveMethod
        external returns (bool)
    {
        assert(publicNotInUseShare > 0);
        require(_share <= publicNotInUseShare);
        ownership[_owner] += _share;
        /* Set new owner as an Employee if he is active `Driver` and not in list */
        if (!isEmployee[_owner] && DMS(_grsExtension(bytes4("DMS"))).activeDrivers(_owner))
            assert(_addToEmployee(_owner));
        return true;
    }
    
    /*
    /// @notice Assign share from one holder to another.
    /// Before assignment receiver will be added to owners array. 
    /// This method will be called from the same `Method` and after 
    /// the `addOwner` function in case of receiver had not any shares and
    /// he is new in the `Company` ownership.
    /// `Company` should be active.
    /// @param _owner sender of shares of his ownersip.
    /// @param _receiver receiver of share.
    /// @return Whether the transfer was successful or not
    */
    function giveOwnership(address _owner, address _receiver, uint256 _percentage)
    /* Before assignment check that new owner (_receiver) is already in owners array */
        onlyForOwner(_receiver)
        onlyAtActiveCompany
        onlyByActiveMethod
        external returns (bool)
    {
        require(_percentage <= ownership[_owner]);
        ownership[_owner] -= _percentage;
        ownership[_receiver] += _percentage;
        /* Set receiver as an Employee if he is active `Driver` and not in list */
        if (!isEmployee[_receiver] && DMS(_grsExtension(bytes4("DMS"))).activeDrivers(_receiver))
            assert(_addToEmployee(_receiver));
        return true;
    }
    
    /*
    /// @notice Set `Company`s postal address by contract of real estate.
    /// Can be set only by active GRS `Method`.
    /// @param _realEstate address of real estate contract.
    /// @return Whether the transfer was successful or not
    */
    function changePostalAddressByContract (address _realEstate)
        onlyAtActiveCompany
        onlyByActiveMethod
        external returns (bool) 
    {
        this.changePostalAddressByData(0x0, 0x0, 0, 0x0);
        postalAddress.realEstate = _realEstate;
        return true;
    }
    
    /*
    /// @notice Set `Company`s postal address by data of real estate.
    /// Can be set only by active GRS `Method`.
    /// @param _city bytes32 of city name in `Compnay`s `CB` contour.
    /// @param _street bytes32 of street.
    /// @param _code uint of postal code.
    /// @param _homeNumber bytes32 of home number.
    /// @return Whether the transfer was successful or not
    */
    function changePostalAddressByData (
            bytes32 _city,
            bytes32 _street,
            uint256 _code,
            bytes32 _homeNumber
        )
        onlyAtActiveCompany
        onlyByActiveMethod
        external returns (bool) 
    {
        /* Reset real estate address */
        postalAddress.realEstate = address(0);
        /* And set address by data */
        postalAddress.city = _city;
        postalAddress.street = _street;
        postalAddress.postalCode = _code;
        postalAddress.homeNumber = _homeNumber;
        return true;
    }
    
    /*
    /// @notice Set `Company`s logotype image.
    /// Can be set only by active GRS `Method`.
    /// @param _logo the bytearray of logotype.
    /// @return Whether the transfer was successful or not
    */
    function setLogotype(bytes calldata _logo)
        onlyAtActiveCompany
        onlyByActiveMethod
        external returns (bool) 
    {
        require(_logo.length > 0);
        logo.image = _logo;
        return true;
    }
    
    /*
    /// @notice `Company` activation. `Company` may be activated from state of
    /// freezed and under sanctions.
    /// Can be set only by active GRS `Method`.
    /// @return Whether the transfer was successful or not
    */
    function activateCompany()
        notAtDeactivatedCompany
        onlyByActiveMethod
        external returns (bool) 
    {
        assert(companyActivity != CompanyActivity.active);
        companyActivity = CompanyActivity.active;
        return true;
    }
    
    /*
    /// @notice impose sanctions to `Company`. `Company` may be imposed to sanctions
    /// at any "activity" except `deactivated` and only if expiration timestamp 
    /// registered on the `CMS` side.
    /// Can be set only by active GRS `Method`.
    /// @return Whether the transfer was successful or not
    */
    function imposeSanctionsToCompany()
        onlyByActiveMethod
        external returns (bool) 
    {
        assert(companyActivity != CompanyActivity.deactivated);
        /* Only if expiration timestamp registered on the `CMS` side */
        assert(CMS(_grsExtension(bytes4("CMS"))).companySanctionsExpires(address(this)) > now);
        companyActivity = CompanyActivity.underSanctions;
        return true;
    }
    
    /*
    /// @notice freeze `Company`. `Company` may be freezed only at active state
    /// Can be set only by active GRS `Method`.
    /// @return Whether the transfer was successful or not
    */
    function freezeCompany()
        onlyAtActiveCompany
        onlyByActiveMethod
        external returns (bool) 
    {
        companyActivity = CompanyActivity.freezed;
        return true;
    }
    
    /*
    /// @notice `Company` deactivation. `Company` may be deactivated at any
    /// "activity" except `deactivated`;
    /// Can be set only by active GRS `Method`.
    /// @return Whether the transfer was successful or not
    */
    function deactivateCompany()
        onlyByActiveMethod
        external returns (bool) 
    {
        assert(companyActivity != CompanyActivity.deactivated);
        companyActivity = CompanyActivity.deactivated;
        return true;
    }
    
    /*
    /// @notice Adding candidate to `Company`. Any employment except owners will 
    /// be the candidate at the beginning see `addCandidateToEmployee`
    /// Can be set only by active GRS `Method`.
    /// @param _candidate Address of `Driver` contract
    /// @return Whether the transfer was successful or not
    */
    function addCandidate(address _candidate)
        onlyAtActiveCompany
        onlyByActiveMethod
        external returns (bool) 
    {
        assert(candidateFrom[_candidate] == 0);
        assert(!isEmployee[_candidate]);
        candidateFrom[_candidate] = now;
        return true;
    }
    
    /*
    /// @notice Internal function aimed to set owners of `Company` to employments list.
    /// At second it's working as body of `addCandidateToEmployee` function.
    /// Can be set only by active GRS `Method`.
    /// @param _employee Address of `Driver` contract
    /// @return Whether the transfer was successful or not
    */
    function _addToEmployee(address _employee)
    /* Only active `Driver` may be an employee in list */
        onlyForActiveDriver(_employee)
        onlyAtActiveCompany
        internal returns (bool) 
    {
        employees.push(_employee);
        isEmployee[_employee] = true;
        /* Check that `EmployeeEvents` contract not yet created */
        if (address(employee[_employee]) == address(0))
            employee[_employee] = new CompanyEmployee(grsAddr, _employee);
        return true;
    }
    
    /*
    /// @notice Function aimed to set candidate to `Company` employments list.
    /// Can be set only by active GRS `Method`.
    /// @param _employee Address of `Driver` contract.
    /// @return Whether the transfer was successful or not
    */
    function addCandidateToEmployee(address _employee)
        onlyAtActiveCompany
        onlyByActiveMethod
        external returns (bool) 
    {
        /* Employee will be in candidates, if not in ownership */
        if (ownership[_employee] == 0) {
            assert(candidateFrom[_employee] > 0);
            candidateFrom[_employee] = 0;
        }
        assert(_addToEmployee(_employee));
        return true;
    }
    
    /*
    /// @notice Get employee of `Company` list of all event timestamps.
    /// @param _employee Address of `Driver` contract.
    /// @return The list of timestamps.
    */
    function getEmployeeEventsList(address _employee)
        getByTrusted(_employee)
        onlyByActiveMethod
        external view returns (uint256[] memory) 
    {
        return employee[_employee].getEventsList();
    }
    
    /*
    /// @notice Get the indexed timestamp from events list.
    /// @param _employee Address of `Driver` contract.
    /// @param _index Index in list of timestamps.
    /// @return Timestamp in index
    */
    function getTimestampFromEmployeeEventsList(address _employee, int256 _index)
        getByTrusted(_employee)
        onlyByActiveMethod
        external view returns (uint256) 
    {
        return employee[_employee].getTimestampFromEventsList(_index);
    }
    
    /*
    /// @notice Get the event of employee activity by given timestamp.
    /// @param _employee Address of `Driver` contract.
    /// @param _timestamp Timestamp when requested activity begins.
    /// @return Sign of activity from EmployeesActivity
    */
    function getEmployeeEvent(address _employee, uint256 _timestamp)
        getByTrusted(_employee)
        onlyByActiveMethod
        external view returns (CompanyEmployee.EmployeeActivity)
    {
        return employee[_employee].getEvent(_timestamp);
    }
    
    function createEmptyProject(bytes8 _productCode)
        onlyAtActiveCompany
        onlyByActiveMethod
        external returns (bool)
    {
        address product = products[_productCode];
        assert(product > address(0));
        Project proj = new Project(product);
        projects.push(address(proj));
        projectsInProcess[address(proj)] = true;
    }
    
    /*
    /// SALARY PER PROJECT
    ///
    */
    function setEmployeeSalary(
            address _employee, address _project,
            CompanyEmployee.SalaryRatePer _ratePer, uint256 _salary
        )
        onlyAtActiveCompany
        onlyByActiveMethod
        external returns (bool) 
    {
        assert(isEmployee[_employee]);
        require(_salary > 0);
        assert(projectsInProcess[_project]);
        CompanyEmployee(employee[_employee]).setSalary(_project, _ratePer, _salary);
        return true;
    }
    
    function setInvoiceCreated() external returns (bool) {
        require(Invoice(msg.sender).getSeller() == address(this));
        require(Invoice(msg.sender).centralBank() == centralBank);
        createdInvoices[msg.sender] = true;
        return true;
    }
    
    function setInvoiceApproved() external returns (bool) {
        require(createdInvoices[msg.sender]);
        approvedInvoices[msg.sender] = true;
        return true;
    }
    
    function setInvoicePaid() external returns (bool) {
        require(approvedInvoices[msg.sender]);
        paidInvoices[msg.sender] = true;
        return true;
    }
}
