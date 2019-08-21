pragma solidity >=0.5.1 <0.6.0;

import "../common.sol";
import "../industries/CompanyStandard.sol";
import "../industries/objects/serviceObjects.sol";
import "../industries/objects/operationalObjects.sol";
import "../GRSystem.sol";
import "../cb/CBStandard.sol";
import "./constructors.sol";

/*
/// @title I2Balance Standard of `Driver`s Contract.
*/
contract Driver is DriverConstructor {
    /* version of `Driver` contract */
    uint256 public contractVersion;
    /*
    ///
    ////// Administrative tools of `Driver`
    ///
    */
    /* `Driver`s Central Bank */
    CB public centralBank;
    /* `Driver`s Central Bank address */
    address public cbAddress;
    
    /* Signs of `Driver` activity */
    enum Activity {underage, active, disabled, inactive}
    /* Sign of current `Driver` activity */
    Activity public activity;
    
    /* Annual accounting of accidents (in the number of cases) at work */
    mapping (uint256 => uint256) public annualAccountingOfAccidentsAtWork;
    /* Annual accounting of accidents (in the number of cases) */
    mapping (uint256 => uint256) public annualAccountingOfAccidents;
    
    /* Timestamp of `Driver` mortality, by reason of death */
    uint256 public deactivatedAt;
    
    /* Signs of deactivation by case */
    enum CasesOfDeactivation {alive, quietly, sick, accidentAtWork, accident}
    /* Sign of case of deactivation if not alive */
    CasesOfDeactivation public caseOfDeactivation;
    
    /* Address of `Driver`s Ethereum Account, or owner */
    address public ethereumAccount;
    
    /* Addresses of All trusted admin contracts */
    mapping (address => bool) trustedAdmins;
    /* Addresses of All trusted callers contracts */
    mapping (address => bool) trustedCallers;
    
    
    /* Struct of `Driver` photo */
    struct Photo {
        bytes image;
        uint8 expires; // image expires every 8 years
    }
    Photo photo;
    
    /* Regional address of person */
    struct PostalAddress {
        /* Address of property contract */
        address realEstate;
        /* Or postal address */
        bytes32 city;
        bytes32 street;
        uint256 postalCode;
        bytes32 homeNumber;
    }
    PostalAddress postalAddress;
    
    /*
    ///
    ////// `Driver`s relationships
    ///
    */
    /* Struct of parents and guardians */
    struct Parents {
        /* List of parents */
        address[2] parents;
        /* allowed parent to set as Second parent */
        address allowedParent;
        /* Index of allowed parent */
        uint8 indexOfAllowedParent;
        /* Address of guardian  */
        address guardian;
        /* Guardians allowed to be as admins */
        bool guardianAsAdmin;
        /* allowed guardian to set */
        address allowedGuardian;
    }
    Parents parents;
    /* List of person's Children */
    address[] children;
    /* List of person's wifes / husbands */
    address[] spouses;
    /* Signs of mariage for each spouse in `spouses` list */
    mapping (address => bool) married;
    /* List of all family union contracts (and if not dissolved - last current) */
    address[] familyUnions;
    /* Contract of current spouses family union (Zero if dissolved) */
    address currentFamilyUnion;
    
    /*
    ///
    ////// `Driver`s property listing and accounting
    ///
    */
    /* Listing of all `Driver` property. Real estates, vehicles, etc. */
    address[] commonPropertyListing;
    /* Checker of common `Driver` property. Real estates, vehicles, etc. */
    mapping (address => bool) propertyChecker;
    
    /*
    ///
    ////// `Driver`s employment
    ///
    */
    /* 
    /// `Driver` employee contracts where: 
    /// 1. `Company` address corresponds to `CompanyEmployee` 
    */
    mapping (address => address) employeeContracts;
    
    /*
    ///
    ////// `Driver`s business data (Not in use yet)
    ///
    */
    /* Products offering by person in Economic System */
    mapping (bytes8 => address) public products;
    /* List of all created invoices */
    mapping (address => bool) createdInvoices;
    /* List of all approved invoices */
    mapping (address => bool) approvedInvoices;
    /* List of all paid invoices */
    mapping (address => bool) paidInvoices;

    /* Allowance only for active `GRS` `Method` */
    modifier onlyByActiveMethod() {
        require(grSystem.activeMethods(msg.sender));
            _;
    }
    
    /* Allowance only for trusted admins */
    modifier onlyByTrustedAdmins() {
        require(
            grSystem.activeMethods(msg.sender)  ||
            trustedAdmins[msg.sender]
            );
            _;
    }
    
    /* Allowance only for trusted callers */
    modifier onlyByTrustedCallers() {
        require(
            grSystem.activeMethods(msg.sender)  ||
            trustedAdmins[msg.sender]           ||
            trustedCallers[msg.sender]
            );
            _;
    }
    
    /* to check out `CB` activity */
    modifier onlyForActiveCB(address _cb) {
        require(grSystem.activeCentralBank(_cb));
            _;
    }
    
    /* Only if `Driver` alive */
    modifier onlyAtActiveDriver() {
        assert(activity != Activity.inactive);
            _;
    }
    
    /* Only after `Driver` death */
    modifier onlyAfterMortality() {
        assert(activity == Activity.inactive);
        assert(deactivatedAt > 0);
            _;
    }
    
    /* Only if `Driver` is underage or disabled in case of administration needed */
    modifier onlyAtUnderageOrDisabled() {
        assert(
            activity == Activity.underage ||
            activity == Activity.disabled
        );
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
            uint256 _weekn,
            uint256 _version
        ) public
    {
        assert(construction(_grs, _firstName, _lastName, _gender, _dt, _older, _bc, _weekn));
        /* 
        /// Activation performing by `updateOfDriverActivity` function through the
        /// Mediacal Structure. Activity defines on the basis of `Driver` age and
        /// minimal adult age of region.
        */
        activity = Activity.inactive;
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
    
    /* Returns the `GRS` extension address */
    function _grsExtension(bytes4 _name) internal view returns (address) {
        address ext = grSystem.extensions(_name);
        assert(ext > address(0));
        return ext;
    }
    
    /* Returns the `Operator` contract */
    function _operator() internal view returns (Operator) {
        return grSystem.operator();
    }
    
    /* Timestamp of `Driver` age */
    function _ageTimestamp() internal view returns (uint256) {
        /* If `Driver` is active */
        if (activity != Activity.inactive)
            return now + olderTimestamp - birthTimestamp;
        else
            return deactivatedAt + olderTimestamp - birthTimestamp;
    }
    
    function make(bytes32 _name, address _object)
        onlyAtActiveDriver
        onlyByTrustedAdmins
        external returns (bool) 
    {
        return grSystem.make(_name, _object);
    }
    
    function execMake(bytes32 _name, address _entity, address _object)
        onlyAtActiveDriver
        onlyByTrustedAdmins
        external returns (bool) 
    {
        return Entity(_entity).execMake(_name, _object);
    }
    
    function get(bytes32 _name, address _object)
        onlyByTrustedAdmins
        external view returns (uint256) 
    {
        return grSystem.get(_name, _object);
    }
    
    function execGet(bytes32 _name, address _entity, address _object)
        onlyByTrustedAdmins
        external view returns (uint256) 
    {
        return Entity(_entity).execGet(_name, _object);
    }
    
    /*
    /// @notice Set `CB` of `Driver`.
    /// Can only be set by active GRS `Method`.
    /// Allowed to set only at active `Driver`
    /// @param _cb Central Bank to register in.
    /// @return Whether the transfer was successful or not
    */
    function setCentralBank(address _cb)
        onlyAtActiveDriver
        onlyByActiveMethod
        onlyForActiveCB(_cb)
        external returns (bool)
    {
        require(_cb > address(0));
        centralBank = CB(_cb);
        cbAddress = _cb;
        /* Reset location of `Driver` */
        this.setPostalAddressByData(0x0, 0x0, 0, 0x0);
        this.setPostalAddressByContract(address(0));
        return true;
    }
    
    /*
    /// @notice Update `Driver` activity by Medical structure.
    /// Activities are: (underage, active) depends on `Driver` age
    /// and regional adult age minimal limit.
    /// Can be activated only by active GRS `Method`.
    /// @return Whether the transfer was successful or not
    */
    function updateOfDriverActivity()
        onlyByActiveMethod
        external returns (bool)
    {
        uint adultAge = uint256(centralBank.adultAge());
        (uint age, ) = _operator().getNumberOfCiclesLeft(_ageTimestamp(), 365 days);
        activity = age >= adultAge ? Activity.active : Activity.underage;
        return true;
    }
    
    /*
    /// @notice Set `Driver` as disabled by Medical structure.
    /// Can be set only by active GRS `Method`.
    /// Allowed to set only at active or underage `Driver`.
    /// @return Whether the transfer was successful or not
    */
    function setDriverAsDisabled()
        onlyAtActiveDriver
        onlyByActiveMethod
        external returns (bool)
    {
        activity = Activity.disabled;
        return true;
    }

    /*
    /// @notice Dectivate `Driver` by Medical structure.
    /// Can be deactivated only by active GRS `Method`.
    /// @param _deactivatedAt Timestamp of person death.
    /// @return Whether the transfer was successful or not
    */
    function deactivateDriver(uint256 _deactivatedAt)
        onlyAtActiveDriver
        onlyByActiveMethod
        external returns (bool)
    {
        assert(deactivatedAt == 0);
        activity = Activity.inactive;
        deactivatedAt = _deactivatedAt;
        return true;
    }
    
    /*
    /// @notice The basis of increment Accident happened with `Driver` at work.
    /// Allowed to call just from active GRS `Method`.
    /// @return Whether the transfer was successful or not
    */
    function addToAccidentsAtWork()
        onlyAtActiveDriver
        onlyByActiveMethod
        external returns (bool)
    {
        annualAccountingOfAccidentsAtWork[_year()] += 1;
        return true;
    }
    
    /*
    /// @notice The basis of increment Accident happened with `Driver`.
    /// Allowed to call just from active GRS `Method`.
    /// @return Whether the transfer was successful or not
    */
    function addToAccidents()
        onlyAtActiveDriver
        onlyByActiveMethod
        external returns (bool)
    {
        annualAccountingOfAccidents[_year()] += 1;
        return true;
    }
    
    /*
    /// @notice The basis of set of `quietly` case of deactivation of `Driver`.
    /// Can be set just after `Driver` mortality.
    /// Allowed to call just from active GRS `Method`.
    /// @return Whether the transfer was successful or not
    */
    function setDriverDeactivatedQuietly()
        onlyAfterMortality
        onlyByActiveMethod
        external returns (bool)
    {
        assert(caseOfDeactivation == CasesOfDeactivation.alive);
        caseOfDeactivation = CasesOfDeactivation.quietly;
        return true;
    }
    
    /*
    /// @notice The basis of setting of case of deactivation of `Driver` by sick.
    /// Can be set just after `Driver` mortality.
    /// Allowed to call just from active GRS `Method`.
    /// @return Whether the transfer was successful or not
    */
    function setDriverDeactivatedBySick()
        onlyAfterMortality
        onlyByActiveMethod
        external returns (bool)
    {
        assert(caseOfDeactivation == CasesOfDeactivation.alive);
        caseOfDeactivation = CasesOfDeactivation.sick;
        return true;
    }
    
    /*
    /// @notice The basis of setting of case of deactivation of `Driver` by accident at work.
    /// Can be set just after `Driver` mortality.
    /// Allowed to call just from active GRS `Method`.
    /// @return Whether the transfer was successful or not
    */
    function setDriverDeactivatedByAccidentAtWork()
        onlyAfterMortality
        onlyByActiveMethod
        external returns (bool)
    {
        assert(caseOfDeactivation == CasesOfDeactivation.alive);
        caseOfDeactivation = CasesOfDeactivation.accidentAtWork;
        return true;
    }
    
    /*
    /// @notice The basis of setting of case of deactivation of `Driver` by accident.
    /// Can be set just after `Driver` mortality.
    /// Allowed to call just from active GRS `Method`.
    /// @return Whether the transfer was successful or not
    */
    function setDriverDeactivatedByAccident()
        onlyAfterMortality
        onlyByActiveMethod
        external returns (bool)
    {
        assert(caseOfDeactivation == CasesOfDeactivation.alive);
        caseOfDeactivation = CasesOfDeactivation.accident;
        return true;
    }
    
    /*
    /// @notice set `Driver` owners Ethereum account.
    /// Can be set only by active GRS `Method`.
    /// @param _owner address of Ethereum owners account.
    /// @return Whether the transfer was successful or not
    */
    function setOwner(address _owner)
        onlyAtActiveDriver
        onlyByActiveMethod
        external returns (bool) 
    {
        require(_owner > address(0));
        assert(!trustedAdmins[_owner]);
        trustedAdmins[_owner] = true;
        ethereumAccount = _owner;
        return true;
    }
    
    /*
    /// @notice set trusted admin for `Driver` contract.
    /// Can be set only by active GRS `Method`.
    /// @param _trusted address of trusted contract.
    /// @return Whether the transfer was successful or not
    */
    function setTrustedAdmin(address _trusted)
        onlyAtActiveDriver
        onlyByActiveMethod
        external returns (bool) 
    {
        require(_trusted > address(0));
        assert(!trustedAdmins[_trusted]);
        trustedAdmins[_trusted] = true;
        return true;
    }
    
    /*
    /// @notice unset trusted admin for `Driver` contract.
    /// Or set as untrusted.
    /// Can be unset only by active GRS `Method`.
    /// @param _untrusted address of untrusted contract.
    /// @return Whether the transfer was successful or not
    */
    function unsetTrustedAdmin(address _untrusted)
        onlyAtActiveDriver
        onlyByActiveMethod
        external returns (bool) 
    {
        assert(trustedAdmins[_untrusted]);
        trustedAdmins[_untrusted] = false;
        return true;
    }
    
    /*
    /// @notice check the `Driver`s trusted admin.
    /// Can be checked only by trusted admin.
    /// @param _trusted address of Ethereum owners account.
    /// @return Is address trusted or not
    */
    function checkTrustedAdminsContract(address _trusted)
        onlyByTrustedAdmins
        external view returns (bool)
    {
        return trustedAdmins[_trusted];
    }
    
    /*
    /// @notice set trusted caller for `Driver` contract.
    /// Can be set only by active GRS `Method`.
    /// @param _trusted address of trusted contract.
    /// @return Whether the transfer was successful or not
    */
    function setTrustedCaller(address _trusted)
        onlyAtActiveDriver
        onlyByActiveMethod
        external returns (bool) 
    {
        require(_trusted > address(0));
        assert(!trustedCallers[_trusted]);
        trustedCallers[_trusted] = true;
        return true;
    }
    
    /*
    /// @notice unset trusted caller for `Driver` contract.
    /// Can be unset only by active GRS `Method`.
    /// @param _untrusted address of untrusted contract.
    /// @return Whether the transfer was successful or not
    */
    function unsetTrustedCaller(address _untrusted)
        onlyAtActiveDriver
        onlyByActiveMethod
        external returns (bool) 
    {
        assert(trustedCallers[_untrusted]);
        trustedCallers[_untrusted] = false;
        return true;
    }
    
    /*
    /// @notice check the `Driver`s trusted caller.
    /// Can be checked only by trusted caller.
    /// @param _trusted address of Ethereum owners account.
    /// @return Is address trusted or not
    */
    function checkTrustedCallersContract(address _trusted)
        onlyByTrustedCallers
        external view returns (bool)
    {
        return trustedCallers[_trusted];
    }
    
    /*
    /// @notice Set `Driver`s first name.
    /// Can be set only by active GRS `Method`.
    /// @param _firstName bytes of `Driver` first name.
    /// @return Whether the transfer was successful or not
    */
    function setFirstName(bytes32 _firstName)
        onlyAtActiveDriver
        onlyByActiveMethod
        external returns (bool) 
    {
        require(_firstName.length > 0);
        name.firstName = _firstName;
        return true;
    }
    
    /*
    /// @notice Set `Driver`s last name.
    /// Can be set only by active GRS `Method`.
    /// @param _lastName bytes of `Driver` last name.
    /// @return Whether the transfer was successful or not
    */
    function setLastName(bytes32 _lastName)
        onlyAtActiveDriver
        onlyByActiveMethod
        external returns (bool) 
    {
        require(_lastName.length > 0);
        name.lastName = _lastName;
        return true;
    }
    
    /*
    /// @notice Set `Driver`s photo.
    /// Can be set only by active GRS `Method`.
    /// @param _image bytes of `Driver` photo image.
    /// @return Whether the transfer was successful or not
    */
    function setPhoto(bytes calldata _image)
        onlyAtActiveDriver
        onlyByActiveMethod
        external returns (bool) 
    {
        require(_image.length > 0);
        photo.image = _image;
        /* Get current border of limit in case of multiple expiration cicles */
        uint8 limit = DMS(_grsExtension(bytes4("DMS"))).imageExpirationLimits();
        (uint ageOfLimit, ) = _operator().getNumberOfCiclesLeft(_ageTimestamp(), 365 days * limit);
        /* Set next expiration */
        photo.expires = uint8(ageOfLimit) + limit;
        return true;
    }
    
    /*
    /// @notice Gets `Driver`s birth timestamp in array of seconds.
    /// Can be get only by trusted callers.
    /// @return array of birth timestamp from UNIX epoch and seconds in case 
    /// of `Driver` was born before 1970 year. 
    */
    function getBirthTimestamp()
        onlyByTrustedCallers
        external view returns (uint256[2] memory) 
    {
        return [birthTimestamp, olderTimestamp];
    }
    
    /*
    /// @notice Gets `Driver`s age timestamp in seconds.
    /// Can be get only by trusted callers.
    /// @return figure of age in seconds.
    */
    function getAgeTimestamp()
        onlyByTrustedCallers
        external view returns (uint256) 
    {
        return _ageTimestamp();
    }
    
    /*
    /// @notice Gets `Driver`s birth coordinates.
    /// Can be get only by trusted callers.
    /// @return array of coords.
    */
    function getBirthCoordinates()
        onlyByTrustedCallers
        external view returns (bytes2[8] memory)
    {
        return birthCoordinates;
    }
    
    /*
    /// @notice Set `Driver`s postal address by contract of real estate.
    /// Can be set only by active GRS `Method`.
    /// @param _realEstate address of real estate contract.
    /// @return Whether the transfer was successful or not
    */
    function setPostalAddressByContract (address _realEstate)
        onlyAtActiveDriver
        onlyByActiveMethod
        external returns (bool) 
    {
        this.setPostalAddressByData(0x0, 0x0, 0, 0x0);
        postalAddress.realEstate = _realEstate;
        return true;
    }
    
    /*
    /// @notice Set `Driver`s postal address by data of real estate.
    /// Can be set only by active GRS `Method`.
    /// @param _city bytes32 of city name in `Driver`s current `CB` contour.
    /// @param _street bytes32 of street.
    /// @param _code uint of postal code.
    /// @param _homeNumber bytes32 of home number.
    /// @return Whether the transfer was successful or not
    */
    function setPostalAddressByData (
            bytes32 _city, 
            bytes32 _street,
            uint256 _code,
            bytes32 _homeNumber
        )
        onlyAtActiveDriver
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
    /// @notice Gets `Driver`s postal address.
    /// Depends on type of postal address registered.
    /// Can be get only by trusted callers.
    /// @return address of real estate contract, or data of postal address.
    */
    function getPostalAddress()
        onlyByTrustedCallers
        external view returns (address, bytes32, bytes32, uint256, bytes32)
    {
        if (postalAddress.realEstate > address(0))
            return (postalAddress.realEstate, 0x0, 0x0, 0, 0x0);
        return (
            address(0),
            postalAddress.city,
            postalAddress.street,
            postalAddress.postalCode,
            postalAddress.homeNumber
        );
    }

    /*
    /// @notice Allow one parent by another, or by medical structure.
    /// First time, before activation of this `Driver` contract should be called
    /// by medical structure only and set parent directly.
    /// Would be set multiple times.
    /// @param _parent The address secont parent `Driver` contract
    /// @param _parentIndex The index of secont parent `Driver` contract
    /// @return Whether the transfer was successful or not
    */
    function parentAllowance(address _parent, uint8 _parentIndex)
        onlyByActiveMethod
        external returns (bool) 
    {
        require(_parent > address(0));
        /*
        /// Check that it's a first call of parent allowance
        /// In case of medical structure calling.
        */
        if (parents.parents[0] == address(0) && parents.parents[1] == address(0)) {
            /* And set parent directly */
            parents.parents[0] = _parent;
            trustedAdmins[_parent] = true;
        } else {
            /* Only at the lack of activity */
            assert(
                activity == Activity.underage ||
                activity == Activity.disabled
                );
            require(_parentIndex < 2);
            assert(parents.parents[_parentIndex] != _parent);
            parents.allowedParent = _parent;
            parents.indexOfAllowedParent = _parentIndex;
        }
        return true;
    }
    
    /*
    /// @notice Gets `Driver`s allowed parent and them index in list.
    /// Can be get only by trusted callers.
    /// @return address of allowed parent and index.
    */
    function getAllowedParentAndIndex()
        onlyAtActiveDriver
        onlyByTrustedCallers
        external view returns (address, uint8)
    {
        return (parents.allowedParent, parents.indexOfAllowedParent);
    }
    
    /*
    /// @notice Set contract as `Driver` parent if approved by other side.
    /// Should be called by allowed parent from `GRS` `Method`.
    /// Can be approved only at the lack of activity of `Driver`.
    /// @return Whether the transfer was successful or not.
    */
    function setParent()
        onlyAtUnderageOrDisabled
        onlyByActiveMethod
        external returns (bool) 
    {
        assert(parents.allowedParent > address(0));
        /* unset previous parent from trusted admins */
        if (parents.parents[parents.indexOfAllowedParent] > address(0))
            trustedAdmins[parents.parents[parents.indexOfAllowedParent]] = false;
        parents.parents[parents.indexOfAllowedParent] = parents.allowedParent;
        trustedAdmins[parents.allowedParent] = true;
        /* reset temporary allowance data */
        parents.allowedParent = address(0);
        parents.indexOfAllowedParent = 0;
        return true;
    }
    
    /*
    /// @notice Gets `Driver`s registered parents list.
    /// Can be get only by trusted callers.
    /// @return Address of registered parent.
    */
    function getParents()
        onlyByTrustedCallers
        external view returns (address[2] memory)
    {
        return parents.parents;
    }
    
    /*
    /// @notice Allow guardian by any trusted side.
    /// Would be set multiple times.
    /// @param _guardian The address guardian contract (may be family union).
    /// @return Whether the transfer was successful or not
    */
    function guardianAllowance(address _guardian)
        onlyAtUnderageOrDisabled
        onlyByActiveMethod
        external returns (bool) 
    {
        require(_guardian > address(0));
        assert(parents.guardian != _guardian);
        parents.allowedGuardian = _guardian;
        return true;
    }
    
    /*
    /// @notice Gets `Driver`s allowed guardian.
    /// Can be get only by trusted callers.
    /// @return address of allowed gurdian.
    */
    function getAllowedGuardian()
        onlyAtActiveDriver
        onlyByTrustedCallers
        external view returns (address)
    {
        return parents.allowedGuardian;
    }
    
    /*
    /// @notice Set contract as `Driver` guardian if approved by any trusted side.
    /// Should be called by allowed Guardian parent from `GRS` `Method`.
    /// Can be approved only at the lack of activity of `Driver`.
    /// @return Whether the transfer was successful or not.
    */
    function setGuardian()
        onlyAtUnderageOrDisabled
        onlyByActiveMethod
        external returns (bool) 
    {
        assert(parents.allowedGuardian > address(0));
         /* unset previous parent from trusted admins if guardians as admins */
        if (parents.guardianAsAdmin) {
            trustedAdmins[parents.guardian] = false;
            trustedAdmins[parents.allowedGuardian] = true;
        }
        parents.guardian = parents.allowedGuardian;
        /* reset temporary allowance data */
        parents.allowedGuardian = address(0);
        return true;
    }
    
    /*
    /// @notice Gets `Driver`s registered guardian.
    /// Can be get only by trusted callers.
    /// @return Address of registered guardian.
    */
    function getGuardian()
        onlyByTrustedCallers
        external view returns (address)
    {
        return parents.guardian;
    }
    
    /*
    /// @notice Allow guardians contract to be the (this) `Driver` admin.
    /// Can be allowed only at the lack of activity of (this) `Driver`.
    /// @return Whether the transfer was successful or not.
    */
    function setGuardianAsAdmin()
        onlyAtUnderageOrDisabled
        onlyByActiveMethod
        external returns (bool) 
    {
        assert(!parents.guardianAsAdmin);
        parents.guardianAsAdmin = true;
        if (parents.guardian > address(0))
            trustedAdmins[parents.guardian] = true;
        return true;
    }
    
    /*
    /// @notice disallow guardians contract to be the (this) `Driver` admin.
    /// Can be disallowed only at active (this) `Driver`.
    /// @return Whether the transfer was successful or not.
    */
    function unsetGuardianFromAdmin()
        onlyAtActiveDriver
        onlyByActiveMethod
        external returns (bool) 
    {
        assert(parents.guardianAsAdmin);
        parents.guardianAsAdmin = false;
        if (parents.guardian > address(0))
            trustedAdmins[parents.guardian] = false;
        return true;
    }
    
    /*
    /// @notice Gets `Driver`s registered allowance to be as admin for guardian.
    /// Can be get only by trusted callers.
    /// @return guardian is Admin or not.
    */
    function guardianIsAdmin()
        onlyAtActiveDriver
        onlyByTrustedCallers
        external view returns (bool)
    {
        return parents.guardianAsAdmin;
    }
    
    /*
    /// @notice Set new child of `Driver`.
    /// Can be set only at active `Driver`.
    /// @param _child Address of child `Driver` contract.
    /// @return Whether the transfer was successful or not.
    */
    function setChild(address _child)
        onlyAtActiveDriver
        onlyByActiveMethod
        external returns (bool) 
    {
        require(_child > address(0));
        children.push(_child);
        return true;
    }
    
    /*
    /// @notice Gets the list of `Driver` children.
    /// Can be get only by trusted callers.
    /// @return List of `Driver` children.
    */
    function getChildren()
        onlyByTrustedCallers
        external view returns (address[] memory)
    {
        return children;
    }
    
    /*
    /// @notice Gets the number of `Driver`s children.
    /// Can be get only by trusted callers.
    /// @return Number of `Driver` children.
    */
    function getChildrenNumber()
        onlyByTrustedCallers
        external view returns (uint256)
    {
        return children.length;
    }
    
    /*
    /// @notice Gets the indexed child of `Driver` in list.
    /// Can be get only by trusted callers.
    /// @param _index Index of child in `children` list.
    /// @return `Driver` child in list.
    */
    function getChild(uint256 _index)
        onlyByTrustedCallers
        external view returns (address)
    {
        assert(children.length > _index);
        return children[_index];
    }
    
    /*
    /// @notice Set new spouse of `Driver`.
    /// Can be set only at active `Driver`.
    /// @param _spouse Address of spouse `Driver` contract.
    /// @return Whether the transfer was successful or not.
    */
    function setSpouse(address _spouse)
        onlyAtActiveDriver
        onlyByActiveMethod
        external returns (bool) 
    {
        require(_spouse > address(0));
        assert(!married[_spouse]);
        spouses.push(_spouse);
        married[_spouse] = true;
        return true;
    }
    
    /*
    /// @notice Dissolve marriage with spouse of `Driver`.
    /// Can be dissolved only at active `Driver`.
    /// @param _spouse Address of spouse `Driver` contract.
    /// @return Whether the transfer was successful or not.
    */
    function dissolveMarriage(address _spouse)
        onlyAtActiveDriver
        onlyByActiveMethod
        external returns (bool) 
    {
        assert(married[_spouse]);
        married[_spouse] = false;
        return true;
    }
    
    /*
    /// @notice Gets the list of `Driver` spuouses.
    /// Can be get only by trusted callers.
    /// @return List of `Driver` spuouses.
    */
    function getSpouses()
        onlyByTrustedAdmins
        external view returns (address[] memory)
    {
        return spouses;
    }
    
    /*
    /// @notice Gets the list of active `Driver` spuouses.
    /// Can be get only by trusted callers.
    /// @return List of active `Driver` spuouses.
    */
    function getActiveSpouses()
        onlyByTrustedCallers
        external view returns (address[] memory)
    {
        uint numberOfActive = this.getActiveSpousesNumber();
        address[] memory activeSpouses = new address[](numberOfActive);
        if (numberOfActive > 0) {
            for (uint i=0; i<spouses.length; i++) {
                if (married[spouses[i]])
                    activeSpouses[i] = spouses[i];
            }
        }
        return activeSpouses;
    }
    
    /*
    /// @notice Gets the number of `Driver`s spouses (active and inactive).
    /// Can be get only by trusted callers.
    /// @return Number of `Driver` spouses.
    */
    function getSpousesNumber()
        onlyByTrustedCallers
        external view returns (uint256)
    {
        return spouses.length;
    }
    
    /*
    /// @notice Gets the number of active `Driver`s spouses.
    /// Can be get only by trusted callers.
    /// @return Number of active `Driver` spouses.
    */
    function getActiveSpousesNumber()
        onlyByTrustedCallers
        external view returns (uint256)
    {
        if (spouses.length == 0)
            return 0;
        uint numberOfActive;
        
        for (uint i=0; i<spouses.length; i++) {
            if (married[spouses[i]])
                numberOfActive++;
        }
        return numberOfActive;
    }
    
    /*
    /// @notice Gets the indexed spouse of `Driver` in list.
    /// Can be get only by trusted callers.
    /// @param _index Index of spouse in `spouses` list.
    /// @return `Driver`s spouse in list.
    */
    function getSpouse(uint256 _index)
        onlyByTrustedAdmins
        external view returns (address)
    {
        assert(spouses.length > _index);
        return spouses[_index];
    }
    
    /*
    /// @notice Set family union contract of spouses.
    /// Family Union (FU) contract should be updatable for many reasons:
    /// 1. Before dissolving at the `Driver`s side it should be dissolved at FU contract;
    /// 2. Possibility to add/remove spouses in case of multiple wifes opportunity in any culture;
    /// 3. Possibility to add children;
    /// 4. Possibility to be as business entity or budget organization;
    /// 5. etc.
    /// Can be set only at active `Driver`.
    /// @param _contract Address of contract of union.
    /// @return Whether the transfer was successful or not.
    */
    function setFamilyUnion(address _contract)
        onlyAtActiveDriver
        onlyByActiveMethod
        external returns (bool) 
    {
        /* Check none active unions */
        assert(currentFamilyUnion == address(0));
        require(_contract > address(0));
        familyUnions.push(_contract);
        currentFamilyUnion = _contract;
        return true;
    }
    
    /*
    /// @notice Dissolve family union contract of spouses.
    /// Can be set only at active `Driver`.
    /// @return Whether the transfer was successful or not.
    */
    function dissolveCurrentFamilyUnion()
        onlyAtActiveDriver
        onlyByActiveMethod
        external returns (bool)
    {
        assert(currentFamilyUnion > address(0));
        currentFamilyUnion = address(0);
        return true;
    }
    
    /*
    /// @notice Gets the list of all unions beeing created.
    /// Can be get only by trusted admins.
    /// @return `Driver`s family unions.
    */
    function getFamilyUnions()
        onlyByTrustedAdmins
        external view returns (address[] memory)
    {
        return familyUnions;
    }
    
    /*
    /// @notice Gets the current and active family union of `Driver`.
    /// Can be get only by trusted Admins.
    /// @return current and active `Driver`s family union.
    */
    function getCurrentFamilyUnion()
        onlyByTrustedAdmins
        external view returns (address)
    {
        return currentFamilyUnion;
    }
    
    /*
    /// @notice Add new property of `Driver`.
    /// Can be set only at active `Driver`.
    /// @param _property Address of property contract.
    /// @return Whether the transfer was successful or not.
    */
    function addProperty(address _property)
        onlyAtActiveDriver
        onlyByActiveMethod
        external returns (bool)
    {
        require(_property > address(0));
        assert(!propertyChecker[_property]);
        commonPropertyListing.push(_property);
        propertyChecker[_property] = true;
        return true;
    }
    
    /*
    /// @notice remove property of `Driver`.
    /// Can be set only at active `Driver`.
    /// @param _property Address of property contract.
    /// @return Whether the transfer was successful or not.
    */
    function removeProperty(address _property)
        onlyAtActiveDriver
        onlyByActiveMethod
        external returns (bool)
    {
        assert(propertyChecker[_property]);
        commonPropertyListing = _operator().removeFromAddressArray(commonPropertyListing, _property);
        propertyChecker[_property] = false;
        return true;
    }
    
    /*
    /// @notice set the address of `Employee` contract of `Driver` for current employment. 
    /// Can be set only at active `Driver`.
    /// @param _entity Address of Entity contract.
    /// @param _contract Address of `Employee` contract.
    /// @return Whether the transfer was successful or not.
    */
    function setEmployeeContract(address _entity, address _contract)
        onlyAtActiveDriver
        onlyByActiveMethod
        external returns (bool)
    {   
        require(_entity > address(0));
        require(Employee(_contract).creator() == _entity);
        require(Employee(_contract).getEmployeeAddress() == address(this));
        employeeContracts[_entity] = _contract;
        return true;
    }
    
    /*
    /// @notice get the address of `Employee` contract.
    /// @param _entity Address of Entity contract.
    /// @return Whether the transfer was successful or not.
    */
    function getEmployeeContract(address _entity)
        onlyByTrustedAdmins
        external view returns (address)
    {
        return employeeContracts[_entity];
    }
}

