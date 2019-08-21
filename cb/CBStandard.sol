pragma solidity ^0.5.0;

import "../common.sol";
import "../GRSystem.sol";

/*
/// @title The reference contract of `CB` systems. Contains all data which should
/// be compared between `PreCentralBank` and `CB` creations.
*/
contract CBReferenceContract {

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
    ////// Population accounting system
    ///
    */
    /* Adult age of given region */
    uint8 public adultAge;
    /* Minimal allowed adult age in global economy */
    uint8 public constant minAllowedAdultAge = 16;
    /* The minamal allowed age of second parent */
    uint8 public allowedSecondParentAge;
    
    /*
    ///
    ////// Tax fees accounting system;
    ///
    */
    /* % of Income tax */
    uint8 public incomeTax;
    /* Minimal allowed Income Tax in global economy */
    uint8 public constant minAllowedIncomeTax = 100; /* 10% */
    /* % of General tax */
    uint8 public generalTax;
    /* Minimal allowed General Tax in global economy */
    uint8 public constant minAllowedGeneralTax = 20; /* 2% */
    /* % of Subsidy tax */
    uint8 public subsidyTax;
    /* Minimal allowed Subsidy Tax in global economy */
    uint8 public constant minAllowedSubsidyTax = 10; /* 1% */
    /* % of Upgrade tax */
    uint8 public upgradeTax;
    /* Minimal allowed Upgrade Tax in global economy */
    uint8 public constant minAllowedUpgradeTax = 10; /* 1% */
    /* % of Extra tax */
    uint8 public extraTax;
    /* Minimal allowed Extra Tax in global economy */
    uint8 public constant minAllowedExtraTax   = 40; /* 4% */
    /* % of Contour tax */
    uint8 public contourTax;
    /* Minimal allowed Contour Tax in global economy */
    uint8 public constant minAllowedContourTax = 100; /* 10% */
    
    /*
    ///
    ////// Turnover accounting system;
    ///
    */
    /* 
    /// How many weeks in one cicle.
    /// (for loan repayment amount computation mechanism)
    */
    uint8 public cicleInWeeksForLoanRepaymentAmount;
    /* 
    /// Minimal amount of cicles.
    /// (for loan repayment amount computation mechanism)
    */
    uint8 public numberOfCiclesForLoanRepaymentAmount;
    /* 
    /// Minimal Percentage from turnover allowed to set amount of ciclical repayments.
    /// (for loan repayment amount computation mechanism).
    */
    uint8 public percentageFromTurnoverForLoanRepaymentAmount;
    /* Minimal Percentage from turnover allowed to set amount of ciclical repayments */
    uint8 public constant minAllowedPercentageFromTurnoverForLoanRepaymentAmount = 100; /* 10% */
    
    /* Returns `GRS` extension address */
    function _grsExtension(bytes4 _name) internal view returns (address) {
        address ext = grSystem.extensions(_name);
        assert(ext > address(0));
        return ext;
    }
}

/* 
/// @title Common Contract contains common construction function of 
/// `PreCentralBank` and `CB`.
*/
contract CBConstructor is CBReferenceContract {
    
    
    /* One-off function on constructor of contracts */
    function construction (
            address _grs,
            uint8 _adultAge,
            uint8 _allowedSecondParentAge,
            uint8 _incomeTax,
            uint8 _generalTax,
            uint8 _subsidyTax,
            uint8 _upgradeTax,
            uint8 _extraTax,
            uint8 _contourTax,
            uint8 _cicleInWeeksForLoanRepaymentAmount,
            uint8 _numberOfCiclesForLoanRepaymentAmount,
            uint8 _percentageFromTurnoverForLoanRepaymentAmount
        ) internal returns (bool) 
    {
        /* /* Just "one-off function" in case of `grsAddr` will be equals to 0 */
        require(grsAddr == address(0) && _grs > address(0));
        grsAddr = _grs;
        grSystem = GRS(_grs);
        /* Check Social data */
        require(
            _adultAge >= minAllowedAdultAge && _allowedSecondParentAge >= minAllowedAdultAge
        );
        /* Check Taxation values */
        require(
            _incomeTax >= minAllowedIncomeTax && _generalTax >= minAllowedGeneralTax &&
            _generalTax <= CBMS(_grsExtension(bytes4("CBMS"))).generalTaxLimit()     &&       
            _subsidyTax >= minAllowedSubsidyTax && _subsidyTax < _generalTax         &&
            _upgradeTax >= minAllowedUpgradeTax && _upgradeTax >  _generalTax        &&
            _extraTax >= minAllowedExtraTax && _extraTax > _generalTax               &&
            _contourTax >= minAllowedContourTax
        );
        /* Check data for loans accounting */
        require(
            _cicleInWeeksForLoanRepaymentAmount > 1 && _numberOfCiclesForLoanRepaymentAmount > 0                    &&
            _percentageFromTurnoverForLoanRepaymentAmount >= minAllowedPercentageFromTurnoverForLoanRepaymentAmount &&
            _percentageFromTurnoverForLoanRepaymentAmount <= grSystem.maxPercFromTurnoverForLoanRepaymentAmount()
        );
        adultAge = _adultAge;
        allowedSecondParentAge = _allowedSecondParentAge;
        incomeTax  = _incomeTax; 
        generalTax = _generalTax;
        subsidyTax = _subsidyTax;
        upgradeTax = _upgradeTax;
        extraTax   = _extraTax;
        contourTax = _contourTax;
        cicleInWeeksForLoanRepaymentAmount = _cicleInWeeksForLoanRepaymentAmount;
        numberOfCiclesForLoanRepaymentAmount = _numberOfCiclesForLoanRepaymentAmount;
        percentageFromTurnoverForLoanRepaymentAmount = _percentageFromTurnoverForLoanRepaymentAmount;
        return true;
    }
}

/*
/// @title `PreCentralBank` contract should be created first to set up construction data
/// of `CB` contract. After regisration of this contract msg.sender should 
/// register `CB` contract through `CreateCentralBankContract` `Method`.
*/
contract PreCentralBank is CBConstructor {

    address public creator;
    
    constructor (
            address _grs,
            uint8 _adultAge,
            uint8 _allowedSecondParentAge,
            uint8 _incomeTax,
            uint8 _generalTax,
            uint8 _subsidyTax,
            uint8 _upgradeTax,
            uint8 _extraTax,
            uint8 _contourTax,
            uint8 _cicleInWeeksForLoanRepaymentAmount,
            uint8 _numberOfCiclesForLoanRepaymentAmount,
            uint8 _percentageFromTurnoverForLoanRepaymentAmount
        ) public
    {
        assert(
            construction(_grs, _adultAge, _allowedSecondParentAge,
                _incomeTax, _generalTax, _subsidyTax, _upgradeTax,
                _extraTax, _contourTax, _cicleInWeeksForLoanRepaymentAmount,
                _numberOfCiclesForLoanRepaymentAmount, _percentageFromTurnoverForLoanRepaymentAmount)
        );
        creator = msg.sender;
    }
}

/*
/// @title I2Balance Standard of Central Bank Contract
*/
contract CB is CBConstructor {
    /* version of `CB` contract */
    uint256 public contractVersion;
    /* Address of new CB if all functions delegates to */
    address public delegatedTo;
    /* Address of contour regional bureaucracy contract */
    address public contourContract;
    /* `CB` extensions created by participants of regional economy */
    mapping (bytes32 => address) public cbExtensions;
    
    /*
    ///
    ////// `CB` `Method` modules control system
    ///
    */
    /* Database of active `CB` methods */
    mapping (address => bool) public activeCBMethods;
    /*
    /// Database of methods created by participants of regional economy 
    /// `CB` `Methods` will interact with `CB` `Extension`s only (`cbExtensions`).
    */
    mapping (bytes32 => address) public cbMethods;
    
    /*
    ///
    ////// Population accounting system
    ///
    */
    /* Regional population of Economic System */
    uint256 public totalPopulation;
    
    /* Regional weekly accounting of human from previous paradigm registration */
    mapping (uint256 => uint256) public weeklyHumanRegistration;
    /* Regional annual accounting of human from previous paradigm registration */
    mapping (uint256 => uint256) public annualHumanRegistration;
    
    /* Regional accounting of birth per week */
    mapping (uint256 => uint256) public weeklyBirthAccounting;
    /* Regional accounting of birth per year */
    mapping (uint256 => uint256) public annualBirthAccounting;
    /* Regional annual biological mothers age accounting */
    mapping (uint256 => uint256[22]) public annualMothersAgeAccounting;
    /* Regional annual biological fathers age accounting */
    mapping (uint256 => uint256[22]) public annualFathersAgeAccounting;
    
    /* Regional accounting of mortality per week */
    mapping (uint256 => uint256) public weeklyMortralityAccounting;
    /* Regional accounting of mortality per year */
    mapping (uint256 => uint256) public annualMortralityAccounting;
    
    /* Regional accounting of mortality ages per year */
    mapping (uint256 => uint256[22]) public annualMortralityAgesAccounting;
    /* Regional annual age accounting */
    mapping (uint256 => uint256[22]) public annualDriversAgeAccounting;
    
    /* Regional annual accounting of sick leaves (in days) */
    mapping (uint256 => uint256) public annualAccountingOfSickLeaves;
    
    /* Regional weekly accounting of accidents (in the number of cases per human) at work */
    mapping (uint256 => uint256) public weeklyAccountingOfAccidentsAtWork;
    /* Regional annual accounting of accidents (in the number of cases byperhuman) at work */
    mapping (uint256 => uint256) public annualAccountingOfAccidentsAtWork;
    
    /* Regional weekly accounting of accidents (in the number of cases per human) */
    mapping (uint256 => uint256) public weeklyAccountingOfAccidents;
    /* Regional annual accounting of accidents (in the number of cases per human) */
    mapping (uint256 => uint256) public annualAccountingOfAccidents;
    
    /* Annual accounting of mortal accidents (in the number of cases per human) at work */
    mapping (uint256 => uint256) public annualAccountingOfMortalAccidentsAtWork;
    /* Annual accounting of mortal accidents (in the number of cases per human) */
    mapping (uint256 => uint256) public annualAccountingOfMortalAccidents;
    /* Accounting of total mortal accidents (in the number of cases per human) */
    uint256 public totalMortalAccidents;
    
    /* Regional annual accounting of average Life expectancy */
    mapping (uint256 => uint8) public averageLifeExpectancy;
    
    /* All active `Driver`s of region */
    mapping (address => bool) public activeDrivers;
    /* All active organizations of region */
    mapping (address => bool) public activeEntities;
    /* All activities of region */
    mapping (address => bool) public allActivities;
    /* All local company names register */
    mapping (bytes32 => bool) public localCompanyNames;
    /* All local company address register given by name */
    mapping (bytes32 => address) public companyAddressByName;
    
    /*
    ///
    ////// Tax fees accounting system;
    ///
    */
    /* Migration tax in Ether */
    uint256 public migrationTax;
    /* Emigration tax in Ether */
    uint256 public emigrationTax;
    /* 
    /// Taxes % from list of types for each `Company`.
    */
    mapping (address => uint8) public entitiesTaxes;
    /* Accounting of annual Income tax fees for each `Driver` */
    mapping (uint256 => mapping (address => uint256)) annualIncomeTax;
    /* Accounting of weekly Income tax fees for each `Driver` */
    mapping (uint256 => mapping (address => uint256)) weeklyIncomeTax;
    
    /* Accounting of annual General tax fees from each organization */
    mapping (uint256 => mapping (address => uint256)) annualGeneralTax;
    /* Accounting of weekly General tax fees from each organization */
    mapping (uint256 => mapping (address => uint256)) weeklyGeneralTax;
    
    /* Accounting of annual Subsidy tax fees from each organization */
    mapping (uint256 => mapping (address => uint256)) annualSubsidyTax;
    /* Accounting of weekly Subsidy tax fees from each organization */
    mapping (uint256 => mapping (address => uint256)) weeklySubsidyTax;
    
    /* Accounting of annual Upgrade tax fees from each organization */
    mapping (uint256 => mapping (address => uint256)) annualUpgradeTax;
    /* Accounting of weekly Upgrade tax fees from each organization */
    mapping (uint256 => mapping (address => uint256)) weeklyUpgradeTax;
    
    /* Accounting of annual Extra tax fees from each organization */
    mapping (uint256 => mapping (address => uint256)) annualExtraTax;
    /* Accounting of weekly Extra tax fees from each organization */
    mapping (uint256 => mapping (address => uint256)) weeklyExtraTax;
    
    /* The boolean of migration process of any `Driver`. If true, migration in process */
    mapping (address => bool) public migrationTaxPaid;
    
    /* The boolean of emigration process of any `Driver`. If true, emigration finished */
    mapping (address => bool) public emigrationTaxPaid;
    
    /*
    ///
    ////// Turnover accounting system;
    ///
    */
    /* Amounts of annual turnovers for each organization. */
    mapping (uint256 => mapping (address => uint256)) annualTurnovers;
    /* Amounts of weekly turnovers for each organization.*/
    mapping (uint256 => mapping (address => uint256)) weeklyTurnovers;
    /* Total annual turnover of all organizations */
    mapping (uint256 => uint256) public totalAnnualTurnovers;
    /* Total weekly turnover of all organizations */
    mapping (uint256 => uint256) public totalWeeklyTurnovers;
    
    /* Allowance to call only for active `GRS` `Method`s */
    modifier onlyByActiveMethod() {
        require(grSystem.activeMethods(msg.sender));
            _;
    }
    
    /* Allowance to GET only by trusted senders */
    modifier getByTrusted(address _sender) {
        require(grSystem.activeMethods(msg.sender) || msg.sender == _sender);
            _;
    }
    
    /* Allowance to call only by active entities */
    modifier onlyForEntities(address _entity) {
        require(activeEntities[_entity]);
            _;
    }
    
    /* Allowance to call only by active drivers */
    modifier onlyForActiveDriver(address _driver) {
        require(DMS(_grsExtension(bytes4("DMS"))).activeDrivers(_driver));
            _;
    }
    
    /* Allowance to execute inly if `CB` is active */
    modifier onlyAtActiveCB() {
        assert(delegatedTo == address(0));
            _;
    }
    
    /* Check given week number not more than current and more than zero */
    modifier checkWeek(uint256 _weekn) {
        require(_weekn <= _week() && _weekn > 0);
            _;
    }
    
    /* Check given year number not more than current and more than system registered at */
    modifier checkYear(uint256 _yearn) {
        require(_yearn <= _year() && _yearn >= grSystem.registrationYear());
            _;
    }
    
    constructor (
            address _grs,
            uint8 _adultAge,
            uint8 _allowedSecondParentAge,
            uint8 _incomeTax,
            uint8 _generalTax,
            uint8 _subsidyTax,
            uint8 _upgradeTax,
            uint8 _extraTax,
            uint8 _contourTax,
            uint8 _cicleInWeeksForLoanRepaymentAmount,
            uint8 _numberOfCiclesForLoanRepaymentAmount,
            uint8 _percentageFromTurnoverForLoanRepaymentAmount,
            uint256 _version
        ) public 
    {
        assert(
            construction(_grs, _adultAge, _allowedSecondParentAge, _incomeTax, _generalTax, 
                _subsidyTax, _upgradeTax, _extraTax, _contourTax, _cicleInWeeksForLoanRepaymentAmount,
                _numberOfCiclesForLoanRepaymentAmount, _percentageFromTurnoverForLoanRepaymentAmount)
        );
        require(_version > 0);
        contractVersion = _version;
    }
    
    /*
    ///
    ////// `CB` internal functions
    ///
    */
    /* Current global year */
    function _year() internal view returns (uint256) {
        return grSystem.year();
    }
    
    /* Current global week */
    function _week() internal view returns (uint256) {
        return grSystem.week();
    }
    
    /* Returns `Operator` contract */
    function _operator() internal view returns (Operator) {
        return grSystem.operator();
    }
    
    /*
    ///
    ////// `CB` external functions for use only by trusted subjects
    ///
    */
    /*
    /// @notice The universal "make" function of `CB`.
    /// Allowed to call just from active `GRS` `Method`.
    /// @param _name The name of `Method`.
    /// @param _subject The subject `Method` operates with.
    */
    function make(bytes32 _name, address _object)
        onlyAtActiveCB
        onlyByActiveMethod
        external returns (bool) 
    {
        return grSystem.make(_name, _object);
    }
    
    /*
    /// @notice The universal "get" function of `CB`.
    /// Allowed to call just from active `GRS` `Method`.
    /// @param _name The name of `Method`.
    /// @param _subject[] The subject(s) `Method` operates with.
    */
    function get(bytes32 _name, address _object)
        onlyAtActiveCB
        onlyByActiveMethod
        external view returns (uint256) 
    {
        return grSystem.get(_name, _object);
    }
    
    /*
    ///
    ////// `CB` external functions for use only by `GRS` `Method`s
    ///
    */
    
    /*
    /// @notice The basis of delegation `CB` functions to the new `CB` contract.
    /// Allowed to call just from active GRS `Method`.
    /// @param _cb Address of new `CB`.
    */
    function delegateToCB(address _cb)
    /*
    /// At this moment lets leave this functioning at deactivated `CB` to. 
    /// It gives an opportunity to delegate in unification processes of regions.
    */
        //onlyAtActiveCB
        onlyByActiveMethod
        external returns (bool)
    {
        require(CBMS(_grsExtension(bytes4("CBMS"))).allCentralBanks(_cb));
        delegatedTo = _cb;
        return true;
    }
    
    /*
    /// @notice The basis of definition of `Contour` contract address.
    /// Allowed to call just from active GRS `Method`.
    /// @param _contour Address of Regional `Contour` contract.
    */
    function setContourContract(address _contour)
        onlyByActiveMethod
        external returns (bool)
    {
        require(_contour > address(0));
        assert(contourContract == address(0));
        contourContract = _contour;
        return true;
    }
    
    /*
    /// @notice The basis of definition of `CB` `Extension` contract.
    /// Allowed to call just from active GRS `Method`.
    /// @param _name The name of `Extension`.
    /// @param _extension The address of `Extension`.
    */
    function setCBExtension(bytes32 _name, address _extension)
        onlyByActiveMethod
        external returns (bool)
    {
            require(cbExtensions[_name] == address(0));
            require(_extension > address(0));
            cbExtensions[_name] = _extension;
            return true;
    }
    
    /*
    /// @notice The basis of deactivation of `CB` `Method` contract.
    /// Allowed to call just from active GRS `Method`.
    /// @param _name The name of `Method`.
    */
    function deactivateCBMethod(bytes32 _name)
        onlyByActiveMethod
        external returns (bool)
    {
        require(cbExtensions[_name] > address(0));
        activeCBMethods[cbExtensions[_name]] = false;
        return true;
    }
    
    /*
    /// @notice The basis of activation of `CB` `Method` contract.
    /// Allowed to call just from active GRS `Method`.
    /// @param _name The name of `Method`.
    */
    function activateCBMethod(bytes32 _name)
        onlyByActiveMethod
        external returns (bool)
    {
        require(cbExtensions[_name] > address(0));
        activeCBMethods[cbExtensions[_name]] = true;
        return true;
    }
    
    /*
    /// @notice The basis of definition of `CB` `Method` contract.
    /// Allowed to call just from active GRS `Method`.
    /// @param _name The name of `Method`.
    /// @param _method The address of `Method`.
    */
    function setCBMethod(bytes32 _name, address _method)
        onlyByActiveMethod
        external returns (bool)
    {
        require(_name.length > 0);
        require(_method > address(0));
        activeCBMethods[cbMethods[_name]] = false;
        cbMethods[_name] = _method;
        activeCBMethods[cbMethods[_name]] = true;
        return true;
    }
    
    /*
    /// @notice The basis of definition of adult age of region.
    /// Allowed to call just from active GRS `Method`.
    /// Age should be more than 15 years old.
    /// @param _age Age when parson starts to be adult.
    */
    function setAdultAge(uint8 _age)
        onlyByActiveMethod
        external returns (bool)
    {
        assert(_age >= minAllowedAdultAge);
        adultAge = _age;
        return true;
    }
    
    /*
    /// @notice The basis of definition of allowed second parent age.
    /// To register at children `Driver` contract side to get 
    /// permissions to manage children contract.
    /// Allowed to call just from active GRS `Method`.
    /// @param _age Minimal age of parent.
    */
    function setAllowedSecondParentAge(uint8 _age)
        onlyAtActiveCB
        onlyByActiveMethod
        external returns (bool)
    {
        require(_age >= minAllowedAdultAge);
        require(_age <= 20);
        allowedSecondParentAge = _age;
        return true;
    }
    
    /*
    /// @notice The basis of increment of number of "citizen".
    /// In case of migration from other regions.
    /// Allowed to call just from active GRS `Method`.
    */
    function addToTotalPopulation()
        onlyAtActiveCB
        onlyByActiveMethod
        external returns (bool)
    {
        totalPopulation += 1;
        return true;
    }
    
    /*
    /// @notice The basis of decrement of number of "citizen".
    /// In case of emigration to other region.
    /// Allowed to call just from active GRS `Method`.
    */
    function decreaseFromTotalPopulation()
        onlyAtActiveCB
        onlyByActiveMethod
        external returns (bool)
    {
        totalPopulation -= 1;
        return true;
    }
    
    /*
    /// @notice The basis of increment annual, weekly human registration 
    /// and total population.
    /// In case of computation of Human registration accounting.
    /// Allowed to call just from active GRS `Method`.
    */
    function addToHumanRegistration()
        onlyAtActiveCB
        onlyByActiveMethod
        external returns (bool)
    {
        weeklyHumanRegistration[_week()] += 1;
        annualHumanRegistration[_year()] += 1;
        totalPopulation += 1;
        return true;
    }
    
    /*
    /// @notice The basis of increment annual, weekly births and total population.
    /// In case of computation of birth accounting.
    /// Allowed to call just from active GRS `Method`.
    */
    function addToBirthAccounting(uint8 _motherIndex, uint8 _fatherIndex)
        onlyAtActiveCB
        onlyByActiveMethod
        external returns (bool)
    {
        require(_motherIndex < 22 && _fatherIndex < 22);
        weeklyBirthAccounting[_week()] += 1;
        annualBirthAccounting[_year()] += 1;
        annualMothersAgeAccounting[_year()][_motherIndex] += 1;
        annualFathersAgeAccounting[_year()][_fatherIndex] += 1;
        totalPopulation += 1;
        return true;
    }
    
    /*
    /// @notice The basis of increment annual, weekly mortalities
    /// and decrement total population.
    /// In case of computation of mortality accounting.
    /// Allowed to call just from active GRS `Method`.
    */
    function addToMortalityAccounting(uint8 _index)
        onlyAtActiveCB
        onlyByActiveMethod
        external returns (bool)
    {
        require(_index < 22);
        weeklyMortralityAccounting[_week()] += 1;
        annualMortralityAccounting[_year()] += 1;
        annualMortralityAgesAccounting[_year()][_index] += 1;
        totalPopulation -= 1;
        return true;
    }
    
    /*
    /// @notice The basis of increment annual age accountings.
    /// Allowed to call just from active GRS `Method`.
    /// First need to be registrated at the `CB` contract and then at the 
    /// `GRS` `Extension` (!!!)
    /// @param _driver Address of active `Driver` contract.
    /// @param _cb Address of active `CB` contract.
    /// @param _index Index in list of 5 year groups.
    */
    function addToAgeAccounting(address _driver, uint8 _index)
        onlyByActiveMethod
        onlyForActiveDriver(_driver)
        external returns (bool)
    {
        if (DMS(_grsExtension("DMS")).annualAgeRegistration(_year(), _driver))
            return true;
        require(_index < 22);
        annualDriversAgeAccounting[_year()][_index] += 1;
        return true;
    }
    
    /*
    /// @notice The basis of increment annual sick leaves.
    /// Allowed to call just from active GRS `Method`.
    /// @param _days Number of days for each case.
    */
    function addToSickLeaves(uint256 _days)
        onlyByActiveMethod
        external returns (bool)
    {
        require(_days > 0);
        annualAccountingOfSickLeaves[_year()] += _days;
        return true;
    }
    
    /*
    /// @notice The basis of increment Accident.
    /// Allowed to call just from active GRS `Method`.
    */
    function addToAccidentsAtWork()
        onlyByActiveMethod
        external returns (bool)
    {
        weeklyAccountingOfAccidentsAtWork[_week()] += 1;
        annualAccountingOfAccidentsAtWork[_year()] += 1;
        return true;
    }
    
    /*
    /// @notice The basis of increment Accident.
    /// Allowed to call just from active GRS `Method`.
    */
    function addToAccidents()
        onlyByActiveMethod
        external returns (bool)
    {
        weeklyAccountingOfAccidents[_week()] += 1;
        annualAccountingOfAccidents[_year()] += 1;
        return true;
    }
    
    /*
    /// @notice The basis of increment mortal Accident at work.
    /// Allowed to call just from active GRS `Method`.
    */
    function addToMortalAccidentsAtWork()
        onlyByActiveMethod
        external returns (bool)
    {
        annualAccountingOfMortalAccidentsAtWork[_year()] += 1;
        totalMortalAccidents += 1;
        return true;
    }
    
    /*
    /// @notice The basis of increment mortal Accident.
    /// Allowed to call just from active GRS `Method`.
    */
    function addToMortalAccidents()
        onlyByActiveMethod
        external returns (bool)
    {
        annualAccountingOfMortalAccidents[_year()] += 1;
        totalMortalAccidents += 1;
        return true;
    }
    
    /*
    /// @notice The basis of definition of average life expectancy.
    /// In case of computation of birth and mortality accounting.
    /// Allowed to call just from active GRS `Method`.
    /// @param _avLExp The average life expectancy.
    */
    function setAverageLifeExpectancy(uint8 _expectancy)
        onlyAtActiveCB
        onlyByActiveMethod
        external returns (bool)
    {
        require(_expectancy > 0);
        averageLifeExpectancy[_year()] = _expectancy;
        return true;
    }
    
    /*
    /// @notice The basis of `Driver` activation by medical structure,
    /// or in case of migration process.
    /// Allowed to call just from active GRS `Method`.
    /// @param _driver Address of `Driver` contract.
    */
    function activateDriver(address _driver)
        onlyAtActiveCB
        onlyByActiveMethod
        external returns (bool)
    {
        require(DMS(_grsExtension(bytes4("DMS"))).allDrivers(_driver));
        activeDrivers[_driver] = true;
        allActivities[_driver] = true;
        return true;
    }
    
    /*
    /// @notice The basis of `Driver` deactivation by medical structure,
    /// or in case of emigration process.
    /// Allowed to call just from active GRS `Method`.
    /// @param _driver Address of `Driver` contract.
    */
    function deactivateDriver(address _driver)
        onlyAtActiveCB
        onlyByActiveMethod
        external returns (bool)
    {
        require(DMS(_grsExtension(bytes4("DMS"))).allDrivers(_driver));
        activeDrivers[_driver] = false;
        allActivities[_driver] = false;
        return true;
    }
    
    /*
    /// @notice The basis of any entity activation.
    /// (also `Driver` as business entity).
    /// Allowed to call just from active GRS `Method`.
    /// @param _entity Address of any entity contract.
    */
    function activateEntity(address _entity)
        onlyAtActiveCB
        onlyByActiveMethod
        external returns (bool)
    {  
        require(
            CMS(_grsExtension(bytes4("CMS"))).allCompanies(_entity) ||
            BOMS(_grsExtension(bytes4("BOMS"))).allBudgetOrgs(_entity)
        );
        activeEntities[_entity] = true;
        allActivities[_entity] = true;
        return true;
    }
    
    /*
    /// @notice The basis of any entity deactivation.
    /// (also `Driver` as business entity).
    /// Allowed to call just from active GRS `Method`.
    /// @param _entity Address of any entity contract.
    */
    function deactivateEntity(address _entity)
        onlyAtActiveCB
        onlyByActiveMethod
        external returns (bool)
    {  
        require(
            CMS(_grsExtension(bytes4("CMS"))).allCompanies(_entity) ||
            BOMS(_grsExtension(bytes4("BOMS"))).allBudgetOrgs(_entity)
        );
        activeEntities[_entity] = false;
        allActivities[_entity] = false;
        return true;
    }
    
    /*
    /// @notice The basis of any `Company` assignation to the names register.
    /// Allowed to call just from active GRS `Method`.
    /// @param _name Unique Name of any entity contract.
    /// @param _entity Address of entity contract.
    */
    function addToLocalCompanyNames(bytes32 _name, address _entity)
        onlyAtActiveCB
        onlyForEntities(_entity)
        onlyByActiveMethod
        external returns (bool)
    {
        assert(!localCompanyNames[_name]);
        localCompanyNames[_name] = true;
        companyAddressByName[_name] = _entity;
        return true;
    }
    
    /*
    /// @notice The basis of any `Company` deassignation on the names register.
    /// Allowed to call just from active GRS `Method`.
    /// @param _name Unique Name of any entity contract.
    */
    function removeFromLocalCompanyNames(bytes32 _name)
        onlyAtActiveCB
        onlyByActiveMethod
        external returns (bool)
    {
        assert(localCompanyNames[_name]);
        localCompanyNames[_name] = false;
        companyAddressByName[_name] = address(0);
        return true;
    }
    
    /*
    /// @notice The basis of definition of Income Tax amount.
    /// Allowed to call just from active GRS `Method`.
    /// @param _tax Percentage of Income Tax.
    */
    function setIncomeTax(uint8 _tax)
        onlyAtActiveCB
        onlyByActiveMethod
        external returns (bool)
    {
        require(_tax > 0);
        incomeTax = _tax;
        return true;
    }
    
    /*
    /// @notice The basis of definition of General Tax amount.
    /// Allowed to call just from active GRS `Method`.
    /// @param _tax Percentage of General Tax.
    */
    function setGeneralTax(uint8 _tax)
        onlyAtActiveCB
        onlyByActiveMethod
        external returns (bool)
    {
        require(_tax > 0);
        generalTax = _tax;
        return true;
    }
    
    /*
    /// @notice The basis of definition of Subsidy Tax amount.
    /// Allowed to call just from active GRS `Method`.
    /// @param _tax Percentage of Subsidy Tax.
    */
    function setSubsidyTax(uint8 _tax)
        onlyAtActiveCB
        onlyByActiveMethod
        external returns (bool)
    {
        require(_tax > 0);
        require(_tax < generalTax);
        subsidyTax = _tax;
        return true;
    }
    
    /*
    /// @notice The basis of definition of Upgrade Tax amount.
    /// Allowed to call just from active GRS `Method`.
    /// @param _tax Percentage of Upgrade Tax.
    */
    function setUpgradeTax(uint8 _tax)
        onlyAtActiveCB
        onlyByActiveMethod
        external returns (bool)
    {
        require(_tax > 0);
        require(_tax < generalTax);
        upgradeTax = _tax;
        return true;
    }
    
    /*
    /// @notice The basis of definition of Extra Tax amount.
    /// Allowed to call just from active GRS `Method`.
    /// @param _tax Percentage of Extra Tax.
    */
    function setExtraTax(uint8 _tax)
        onlyAtActiveCB
        onlyByActiveMethod
        external returns (bool)
    {
        require(_tax > 0);
        require(_tax > generalTax);
        extraTax = _tax;
        return true;
    }
    
    /*
    /// @notice The basis of definition of Contour Tax amount.
    /// Allowed to call just from active GRS `Method`.
    /// @param _tax Percentage of Contour Tax.
    */
    function setContourTax(uint8 _tax)
        onlyAtActiveCB
        onlyByActiveMethod
        external returns (bool)
    {
        require(_tax > 0);
        contourTax = _tax;
        return true;
    }
    
    /*
    /// @notice The basis of definition of Migration Tax amount.
    /// Allowed to call just from active GRS `Method`.
    /// @param _tax Amount of Migration Tax.
    */
    function setMigrationTax(uint256 _tax)
        onlyAtActiveCB
        onlyByActiveMethod
        external returns (bool)
    {
        require(_tax > 0);
        migrationTax = _tax;
        return true;
    }
    
    /*
    /// @notice The basis of definition of Emigration Tax amount.
    /// Allowed to call just from active GRS `Method`.
    /// @param _tax Amount of Emigration Tax.
    */
    function setEmigrationTax(uint256 _tax)
        onlyAtActiveCB
        onlyByActiveMethod
        external returns (bool)
    {
        require(_tax > 0);
        emigrationTax = _tax;
        return true;
    }
    
    /*
    /// @notice The basis of definition of Tax amount for any entity.
    /// Allowed to call just from active GRS `Method`.
    /// @param _entity Address of any entity.
    /// @param _tax Amount of Tax.
    */
    function setEntityTax(address _entity, uint8 _tax)
        onlyAtActiveCB
        onlyByActiveMethod
        onlyForEntities(_entity)
        external returns (bool)
    {
        require(_tax > 0);
        entitiesTaxes[_entity] = _tax;
        return true;
    }
    
    /*
    /// @notice The basis of addition of Income Tax payment of any `Driver`.
    /// Addition is fixing at all levels of database needed.
    /// Allowed to call just from active GRS `Method`.
    /// Allowed to add only for `Driver` contract.
    /// @param _driver Address of any `Driver`.
    /// @param _amount Amount of Tax.
    */
    function addPaymentOfIncomeTax(address _driver, uint256 _amount)
        onlyAtActiveCB
        onlyByActiveMethod
        onlyForActiveDriver(_driver)
        external returns (bool)
    {
        require(_amount > 0);
        uint year = _year();
        uint week = _week();
        annualIncomeTax[year][_driver] += _amount;
        weeklyIncomeTax[week][_driver] += _amount;
        return true;
    }
    
    /*
    /// @notice Gets the total amount of annual Income Tax payments of any `Driver`.
    /// Allowed to call just from active GRS `Method` or `Driver` contract owner.
    /// @param _yearn Year number.
    /// @param _driver Address of any `Driver`.
    /// @return Annual amount of Income tax payd by `Driver`
    */
    function getAnnualPaymentsOfIncomeTax(uint256 _yearn, address _driver)
        getByTrusted(_driver)
        checkYear(_yearn)
        external view returns (uint256)
    {
        return annualIncomeTax[_yearn][_driver];
    }
    
    /*
    /// @notice Gets the total amount of weekly Income Tax payments of any `Driver`.
    /// Allowed to call just from active GRS `Method` or `Driver` contract owner.
    /// @param _weekn Week number.
    /// @param _driver Address of any `Driver`.
    /// @return Weekly amount of Income tax payd by `Driver`
    */
    function getWeeklyPaymentsOfIncomeTax(uint256 _weekn, address _driver)
        getByTrusted(_driver)
        checkWeek(_weekn)
        external view returns (uint256)
    {
        return weeklyIncomeTax[_weekn][_driver];
    }
    
    /*
    /// @notice The basis of addition of General Tax payment of any entity.
    /// Addition is fixing at all levels of database needed.
    /// Allowed to call just from active GRS `Method`.
    /// Allowed to add only for active business entity.
    /// @param _entity Address of any active entity.
    /// @param _amount Amount of Tax.
    */
    function addPaymentOfGeneralTax(address _entity, uint256 _amount)
        onlyAtActiveCB
        onlyByActiveMethod
        onlyForEntities(_entity)
        external returns (bool)
    {
        require(_amount > 0);
        uint year = _year();
        uint week = _week();
        annualGeneralTax[year][_entity] += _amount;
        weeklyGeneralTax[week][_entity] += _amount;
        return true;
    }
    
    /*
    /// @notice Gets the total amount of annual General Tax payments of any entity.
    /// Allowed to call just from active GRS `Method` or entity contract owner.
    /// @param _yearn Year number.
    /// @param _driver Address of any active entity.
    /// @return Annual amount of General tax payd by entity
    */
    function getAnnualPaymentsOfGeneralTax(uint256 _yearn, address _entity)
        getByTrusted(_entity)
        onlyForEntities(_entity)
        checkYear(_yearn)
        external view returns (uint256)
    {
        return annualGeneralTax[_yearn][_entity];
    }
    
    /*
    /// @notice Gets the total amount of weekly General Tax payments of any entity.
    /// Allowed to call just from active GRS `Method` or entity contract owner.
    /// @param _weekn Week number.
    /// @param _driver Address of any active entity.
    /// @return Weekly amount of General tax payd by entity
    */
    function getWeeklyPaymentsOfGeneralTax(uint256 _weekn, address _entity)
        getByTrusted(_entity)
        onlyForEntities(_entity)
        checkWeek(_weekn)
        external view returns (uint256)
    {
        return weeklyGeneralTax[_weekn][_entity];
    }
    
    /*
    /// @notice The basis of addition of Subsidy Tax payment of any entity.
    /// Addition is fixing at all levels of database needed.
    /// Allowed to call just from active GRS `Method`.
    /// Allowed to add only for active business entity.
    /// @param _entity Address of any active entity.
    /// @param _amount Amount of Tax.
    */
    function addPaymentOfSubsidyTax(address _entity, uint256 _amount)
        onlyAtActiveCB
        onlyByActiveMethod
        onlyForEntities(_entity)
        external returns (bool)
    {
        require(_amount > 0);
        uint year = _year();
        uint week = _week();
        annualSubsidyTax[year][_entity] += _amount;
        weeklySubsidyTax[week][_entity] += _amount;
        return true;
    }
    
    /*
    /// @notice Gets the total amount of annual Subsidy Tax payments of any entity.
    /// Allowed to call just from active GRS `Method` or entity contract owner.
    /// @param _yearn Year number.
    /// @param _driver Address of any active entity.
    /// @return Annual amount of Subsidy tax payd by entity
    */
    function getAnnualPaymentsOfSubsidyTax(uint256 _yearn, address _entity)
        getByTrusted(_entity)
        onlyForEntities(_entity)
        checkYear(_yearn)
        external view returns (uint256)
    {
        return annualSubsidyTax[_yearn][_entity];
    }
    
    /*
    /// @notice Gets the total amount of weekly Subsidy Tax payments of any entity.
    /// Allowed to call just from active GRS `Method` or entity contract owner.
    /// @param _weekn Week number.
    /// @param _driver Address of any active entity.
    /// @return Weekly amount of Subsidy tax payd by entity
    */
    function getWeeklyPaymentsOfSubsidyTax(uint256 _weekn, address _entity)
        getByTrusted(_entity)
        onlyForEntities(_entity)
        checkWeek(_weekn)
        external view returns (uint256)
    {
        return weeklySubsidyTax[_weekn][_entity];
    }
    
    /*
    /// @notice The basis of addition of Upgrade Tax payment of any entity.
    /// Addition is fixing at all levels of database needed.
    /// Allowed to call just from active GRS `Method`.
    /// Allowed to add only for active business entity.
    /// @param _entity Address of any active entity.
    /// @param _amount Amount of Tax.
    */
    function addPaymentOfUpgradeTax(address _entity, uint256 _amount)
        onlyAtActiveCB
        onlyByActiveMethod
        onlyForEntities(_entity)
        external returns (bool)
    {
        require(_amount > 0);
        uint year = _year();
        uint week = _week();
        annualUpgradeTax[year][_entity] += _amount;
        weeklyUpgradeTax[week][_entity] += _amount;
        return true;
    }
    
    /*
    /// @notice Gets the total amount of annual Upgrade Tax payments of any entity.
    /// Allowed to call just from active GRS `Method` or entity contract owner.
    /// @param _yearn Year number.
    /// @param _driver Address of any active entity.
    /// @return Annual amount of Upgrade tax payd by entity
    */
    function getAnnualPaymentsOfUpgradeTax(uint256 _yearn, address _entity)
        getByTrusted(_entity)
        onlyForEntities(_entity)
        checkYear(_yearn)
        external view returns (uint256)
    {
        return annualUpgradeTax[_yearn][_entity];
    }
    
    /*
    /// @notice Gets the total amount of weekly Upgrade Tax payments of any entity.
    /// Allowed to call just from active GRS `Method` or entity contract owner.
    /// @param _weekn Week number.
    /// @param _driver Address of any active entity.
    /// @return Weekly amount of Upgrade tax payd by entity
    */
    function getWeeklyPaymentsOfUpgradeTax(uint256 _weekn, address _entity)
        getByTrusted(_entity)
        onlyForEntities(_entity)
        checkWeek(_weekn)
        external view returns (uint256)
    {
        return weeklyUpgradeTax[_weekn][_entity];
    }
    
    /*
    /// @notice The basis of addition of Extra Tax payment of any entity.
    /// Addition is fixing at all levels of database needed.
    /// Allowed to call just from active GRS `Method`.
    /// Allowed to add only for active business entity.
    /// @param _entity Address of any active entity.
    /// @param _amount Amount of Tax.
    */
    function addPaymentOfExtraTax(address _entity, uint256 _amount)
        onlyAtActiveCB
        onlyByActiveMethod
        onlyForEntities(_entity)
        external returns (bool)
    {
        require(_amount > 0);
        uint year = _year();
        uint week = _week();
        annualExtraTax[year][_entity] += _amount;
        weeklyExtraTax[week][_entity] += _amount;
        return true;
    }
    
    /*
    /// @notice Gets the total amount of annual Extra Tax payments of any entity.
    /// Allowed to call just from active GRS `Method` or entity contract owner.
    /// @param _yearn Year number.
    /// @param _driver Address of any active entity.
    /// @return Annual amount of Extra tax payd by entity
    */
    function getAnnualPaymentsOfExtraTax(uint256 _yearn, address _entity)
        getByTrusted(_entity)
        onlyForEntities(_entity)
        checkYear(_yearn)
        external view returns (uint256)
    {
        return annualExtraTax[_yearn][_entity];
    }
    
    /*
    /// @notice Gets the total amount of weekly Extra Tax payments of any entity.
    /// Allowed to call just from active GRS `Method` or entity contract owner.
    /// @param _weekn Week number.
    /// @param _driver Address of any active entity.
    /// @return Weekly amount of Extra tax payd by entity
    */
    function getWeeklyPaymentsOfExtraTax(uint256 _weekn, address _entity)
        getByTrusted(_entity)
        onlyForEntities(_entity)
        checkWeek(_weekn)
        external view returns (uint256)
    {
        return weeklyExtraTax[_weekn][_entity];
    }
    
    /*
    /// @notice The basis of addition of Migration Tax payment of any `Driver`.
    /// Addition is fixing at all levels of database needed.
    /// Allowed to call just from active GRS `Method`.
    /// Allowed to add only for active `Driver`.
    /// @param _driver Address of any active `Driver`.
    /// @param _amount Amount of Tax.
    */
    function addPaymentOfMigrationTax(address _driver, uint256 _amount)
        onlyAtActiveCB
        onlyByActiveMethod
        onlyForActiveDriver(_driver)
        external returns (bool)
    {
        require(_amount == migrationTax);
        migrationTaxPaid[_driver] = true;
        return true;
    }
    
    /*
    /// @notice The basis of completion of Migration process of any `Driver`.
    /// Allowed to call just from active GRS `Method`.
    /// Allowed to add only for active `Driver`.
    /// @param _driver Address of any active `Driver`.
    */
    function completeMigrationProcess(address _driver)
        onlyAtActiveCB
        onlyByActiveMethod
        onlyForActiveDriver(_driver)
        external returns (bool)
    {
        require(migrationTaxPaid[_driver]);
        migrationTaxPaid[_driver] = false;
        return true;
    }
    
    /*
    /// @notice The basis of addition of Emigration Tax payment of any `Driver`.
    /// Addition is fixing at all levels of database needed.
    /// Allowed to call just from active GRS `Method`.
    /// Allowed to add only for active `Driver`.
    /// @param _driver Address of any active `Driver`.
    /// @param _amount Amount of Tax.
    */
    function addPaymentOfEmigrationTax(address _driver, uint256 _amount)
        onlyAtActiveCB
        onlyByActiveMethod
        onlyForActiveDriver(_driver)
        external returns (bool)
    {
        require(_amount == emigrationTax);
        emigrationTaxPaid[_driver] = true;
        return true;
    }
    
    /*
    /// @notice The basis of completion of Emigration process of any `Driver`.
    /// Allowed to call just from active GRS `Method`.
    /// Allowed to add only for active `Driver`.
    /// @param _driver Address of any active `Driver`.
    */
    function completeEmigrationProcess(address _driver)
        onlyAtActiveCB
        onlyByActiveMethod
        onlyForActiveDriver(_driver)
        external returns (bool)
    {
        require(emigrationTaxPaid[_driver]);
        emigrationTaxPaid[_driver] = false;
        return true;
    }
    
    /*
    /// @notice The basis of setting of duration of one cicle in weeks.
    /// In case of computation of loan repayment amount (methods > 0).
    /// Allowed to call just from active GRS `Method`.
    /// @param _weeks Number of weeks of one cicle.
    */
    function setCicleInWeeksForLoanRepaymentAmount(uint8 _weeks)
        onlyAtActiveCB
        onlyByActiveMethod
        external returns (bool)
    {
        require(_weeks > 0);
        cicleInWeeksForLoanRepaymentAmount = _weeks;
        return true;
    }
    
    /*
    /// @notice The basis of setting of number of cicles.
    /// In case of computation of loan repayment amount (methods > 0).
    /// Allowed to call just from active GRS `Method`.
    /// @param _cicles Number of cicles.
    */
    function setNumberOfCiclesForLoanRepaymentAmount(uint8 _cicles)
        onlyAtActiveCB
        onlyByActiveMethod
        external returns (bool)
    {
        require(_cicles > 3);
        numberOfCiclesForLoanRepaymentAmount = _cicles;
        return true;
    }
    
    /*
    /// @notice The basis of setting of percentage from turnover in period of cicles.
    /// In case of computation of loan repayment amount (methods > 0).
    /// Allowed to call just from active GRS `Method`.
    /// @param _perc Percentage from turnover for last amount of cicles.
    */
    function setPercentageFromTurnoverForLoanRepaymentAmount(uint8 _perc)
        onlyAtActiveCB
        onlyByActiveMethod
        external returns (bool)
    {
        require(_perc > 5 && _perc <= grSystem.maxPercFromTurnoverForLoanRepaymentAmount());
        percentageFromTurnoverForLoanRepaymentAmount = _perc;
        return true;
    }
    
    /*
    /// @notice Add Amount of common (weekly & annual) turnovers.
    /// Allowed to call just from active GRS `Method`.
    /// Not allowed for any `CB`.
    /// @param _entity Address of account owner.
    /// @param _amount Amount of funds.
    */
    function addToTurnovers(address _entity, uint256 _amount)
        onlyAtActiveCB
        onlyByActiveMethod
        external returns (bool)
    {
        require(allActivities[_entity]);
        require(_amount > 0);
        /* Annual amount data */
        annualTurnovers[_year()][_entity] += _amount;
        /* Weekly amount data */
        weeklyTurnovers[_week()][_entity] += _amount;
        return true;
    }
    
    /*
    /// @notice Get Amount of annual turnover.
    /// Allowed to call just from trusted contract or GRS `Method`.
    /// Not allowed for any `CB`.
    /// @param _yearn Number of annual cicle.
    /// @param _entity Address of account owner.
    */
    function getAnnualTurnover(uint256 _yearn, address _entity)
        getByTrusted(_entity)
        external view returns (uint256)
    {
        require(allActivities[_entity]);
        require(_yearn > 0);
        return annualTurnovers[_yearn][_entity];
    }
    
    /*
    /// @notice Get Amount of annual turnover.
    /// Allowed to call just from trusted contract or GRS `Method`.
    /// Not allowed for any `CB`.
    /// @param _yearn Number of annual cicle.
    /// @param _entity Address of account owner.
    */
    function getWeeklyTurnover(uint256 _weekn, address _entity)
        getByTrusted(_entity)
        external view returns (uint256)
    {
        require(allActivities[_entity]);
        require(_weekn > 0);
        return annualTurnovers[_weekn][_entity];
    }
}
