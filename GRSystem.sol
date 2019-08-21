pragma solidity >=0.5.1 <0.6.0;

import "./common.sol";
import "./drivers/DriverStandard.sol";
import "./industries/CompanyStandard.sol";
import "./modules/method.sol";
import "./modules/SCModules.sol";
import "./modules/GRSModules.sol";
import "./modules/DMSModules.sol";
import "./modules/CBMSModules.sol";

/*
/// @title Global Reserve System Contract. It's a kernel of all Economic
/// System with Modules of `Methods`, `Extensions` of database,
/// fundamental values and Credit-Financial system.
/// JUST `GRS` kernel contains payable operations through "make" function (!!!)
*/
contract GRS {

    /*
    ///
    ////// Fundamental data
    ///
    */
    /* New Epoch starts from first monday of registration at 0:0:0 UTC */
    uint256 public Epoch;
    /* Count of weeks from first monday of new Epoch */
    uint256 public week;
    /* Year at which `GRS` registered */
    uint public registrationYear;
    /* Current year number */
    uint256 public year;
    /* Definition of weeks at which each year starts */
    mapping (uint256 => uint256) public yearStartedAtWeek;
    /* Timestamp of 1 january of year + 1 */
    uint256 public nextYearStartsAt;
    /* Timestamp of 1 january of current year */
    uint256 public thisYearStartedAt;
    /* Number of leap seconds added at current year */
    uint8 public thisYearLeapsAdded;
    /* Common `Operator` contract */
    Operator public operator;
    /* Stage of lifecicle of Economic System */
    uint8 public lifecicleStage;
    /* Decimals of all system currency (credit Token) floats. Same as Ether. */
    uint8 public constant decimals = 18;
    /*
    /// Address of `CashBox` platform to receive tokens from it at 
    /// preparatory stage of economy system.
    /// See `i2balance` paper and `CashBox` white paper.
    */
    address public cashBox;
    /*
    /// `CashBox` value of 1 token per 1 Ether. To be divided by
    /// In real life may be less, depends on market value of PSY-Token.
    */
    uint256 public constant cashBoxTokenValue = 10000;
    /*
    /// Creator of Agent to compare at `CashBox` side 
    /// and Manager at preparatory stage.
    */
    address public creator;
    /* 
    /// Minimal amount of price in economic turnover.
    /// All amounts should be divided by 1000.
    */
    uint256 public constant cent = 1000; 
    /* Limitation of products per `Invoice` */
    uint8 public productsLimit = 70;

    /*
    ///
    ////// `GRS` extensions control system
    ///
    */
    /* `GRS` kernel extensions */
    mapping (bytes4 => address) public extensions;
    /* `GRS` kernel extensions sign of activation */
    mapping (address => bool) public activeExtensions;
    /* `Company` UPGRADE functional block accounting */
    mapping (address => address) public upgradeExtensions;
    /*
    /// `Extension`s accounting. All `Extension`s are indexed.
    */
    /* Total number of `Extension`s registered */
    uint256 public totalExtensions;
    /* Index of `Extentsion` => `Extension` name */
    mapping (uint256 => bytes4) public indexedExtensions;
    /*
    ///
    ////// `Method` modules control system
    ///
    */
    /* All contracts that 'making' or 'calling' should be created by special `Method` */
    mapping (address => bool) public createdByMethod;
    /* Total number of `Subject` contracts created by `Method` */
    uint256 public numberOfCreatedByMethod;
    /* Database of active `GRS` methods */
    mapping (address => bool) public activeMethods;
    /* Database of methods */
    mapping (bytes32 => address) public methods;
    /*
    /// `Method`s accounting. All `Method`s are indexed.
    */
    /* Total number of `Method`s registered */
    uint256 public totalMethods;
    /* Index of `Method` => `Method` name */
    mapping (uint256 => bytes32) public indexedMethods;
    /*
    ///
    ////// Credit-financial system
    ///
    */

    /*
    ////// Balances accounting system
    */
    /* Balances of credit tokens. Private amounts are hidden */
    mapping (address => uint256) tokenBalances;
    /* Balances of Ether. Private amounts are hidden */
    mapping (address => uint256) etherBalances;
    /* Limits of ciclical withdrawals for each `CB` */
    mapping (address => uint256) public ciclicalWithdrawalLimits;
    /* Accounting of ciclical Withdrawals for each entity per week */
    mapping (uint256 => mapping (address => uint256)) public ciclicallyWithdrawed;
    /* Common constant of time frame for ciclically withdrawal limits in weeks */
    uint8 public constant ciclicalWithdrawalsTimeFrame = 4;
    /* Total supply of credit tokens created */
    uint256 public totalTokenSupply;

    /*
    ////// Bank Deposits accounting system
    */
    /* Amounts of bank deposits for each `CB`.*/
    mapping (address => uint256) public bankDeposits;
    /* Amounts of bank deposits for each `CB` in the turnover of Economy */
    mapping (address => uint256) public bankDepositsInTurnover;
    /*
    /// Percentages of interests on bank deposits for each `CB`
    /// uint8 means that maximum interest is 25.5 % 
    */
    mapping (address => uint8) public interestsOnBankDeposits;
    /* Minimum values of bank deposits for each `CB`. Can't set BD if less than min */
    mapping (address => uint256) public bankDepositMinValues;
    /* Amount of toal payments of interests on deposits from `CB` to depositors */
    mapping (address => uint256) public paydBankDepositInterests;
    /* Structure of private Bank Deposit data */
    struct privateBankDeposit {
        /* Global timestamp latest amount of deposit was defined at */
        uint256 time;
        /* Amount of deposit */
        uint256 amount;
        /* Percentage of Interest on Bank Deposit */
        uint8 interest;
    }
    /* Amounts of bank deposits for each depositor. Private amounts are hidden */
    mapping (address => privateBankDeposit) bankDepositPrivateValues;

    /*
    ////// Loans accounting system
    */
    /* Total outstanding loans given by `GRS` to all `CB`s */
    uint256 public totalLoansOfAllCentralBanks;
    /* Structure of `CB` Loan data. No repayment rates on loan for `CB`s */
    struct cBloan {
        /* Total amount of loan */
        uint256 amount;
        /* Timestamp latest addition was made at */
        uint256 lastAdded;
        /* Timestamp latest repayment was made at */
        uint256 lastRepayment;
    }
    /* Structure of entity Loan data */
    struct loan {
        /* Base amount of loan without annum interst rate */
        uint256 baseAmount;
        /* Timestamp latest addition was made at */
        uint256 lastAdded;
        /* Amount of total repayments */
        uint256 repayments;
        /* Timestamp latest repayment was made at */
        uint256 lastRepayment;
        /* Value of repayment rate on amount taken */
        uint8 repaymentRate;
        /* `CB` which gave loan in case of migration */
        address givenByCB;
    }
    /* Amounts of `CB` loans taken from `GRS` */
    mapping (address => cBloan) public loansOfCentralBanks;
    /* 
    /// The GLOBAL maximum volume of loans is determined by 
    /// the number of average annual turnovers.
    */
    uint8 public constant maxAnnualTurnoversForLoan = 10;
    /* Maximal Percentage from turnover allowed to set amount of ciclical repayments */
    uint8 public constant maxPercFromTurnoverForLoanRepaymentAmount = 255; /* 25.5% */
    /* 
    /// The REGIONAL maximum volume of loans is determined by 
    /// the number of average annual turnovers.
    /// address of `CB` => ( number <= maxAnnualTurnoversForLoan );
    /// The algorithm:
    /// Total summ of prev. 3 full annual turnovers / 3 years * max num. of years =
    /// = maximum volume of the loan.
    /// See: `Method(methods[bytes32("GetMaxLoanAmountForEntity")])` in "GRSModules.sol"
    */
    mapping (address => uint8) public maxAnnualTurnoversForLoanForRegions;
    /* Remaining amounts of taken loans for each entity. Private amounts are hidden */
    mapping (address => loan) loanAmounts;
    /* Total loans given by `CB`s to all regional entities */
    mapping (address => uint256) public totalOutstandingLoans;
    /* Loan repayment rates for each region (`CB`), annual repaymnt rates. */
    mapping (address => uint8) public loanRepaymentRates;
    /*
    /// Loan repayment methods for each entity (1-3):
    /// 0. Repayment at each deal only;
    /// 1. Cyclical repayment;
    /// 2. Both.
    /// Private data is hidden
    */
    mapping (address => uint8) loanRepaymentMethods;
    /*
    /// Percentages of loan repayments at each deal for each entity (max 25.5%).
    /// Percentage from price of goods and services.
    /// Private amounts are hidden.
    */
    mapping (address => uint8) loanRepaymentPercentages;
    /* Repayment amounts of month cicles for each entity. Private amounts are hidden. */
    mapping (address => uint256) loanRepaymentCiclicalAmounts;

    /*
    /// Allowance to modify only by active GRS `Method` at transition and
    /// full load period. At preparatory stage just register new `Methods`
    /// and `Extensions` and allowed to preparatory manager.
    */
    modifier onlyByActiveMethodOrPreparatory() {
        require(
            activeMethods[msg.sender] || 
            lifecicleStage == 0 && msg.sender == creator
            );
                _;
    }

    /*
    /// Allowance to modify only by active GRS `Method` at any stage.
    */
    modifier onlyByActiveMethod() {
        require(activeMethods[msg.sender]);
            _;
    }
    
    /*
    /// Allowance to give access to 'make' and 'get' functions only to trusted callers.
    /// With this approach all functions in system are securely covered.
    */
    modifier makeAndGetByTrusted(bytes32 _name) {
        require(createdByMethod[msg.sender] || activeMethods[msg.sender]);
            _;
    }

    /*
    /// Allowance to GET only by owner of addr or active GRS `Method` at any stage.
    */
    modifier getByTrusted(address _sender) {
        require(_sender == msg.sender || activeMethods[msg.sender]);
            _;
    }
    
    /*
    /// Allowance to set only for active `CB`.
    */
    modifier onlyForActiveCB(address _subject) {
        require(this.activeCentralBank(_subject));
            _;
    }
    
    /*
    /// Not allowed to set for any `CB`.
    */
    modifier notAllowedForCB(address _subject) {
        require(!CBMS(extensions[bytes4("CBMS")]).allCentralBanks(_subject));
            _;
    }
    
    /*
    /// Rigid rules for financial management
    */
    modifier onlyRigidAmount(uint256 _amount) {
        require(_amount >= cent);
        require(_amount % cent == 0);
            _;
    }

    constructor (
            uint256 _epochStarts, 
            uint256 _thisYear, // 2018.01.01:00:00 = 1514757600
            uint8   _year,     // 2018
            address _cashBox
        ) public 
    {
        require(_epochStarts >= now);
        require(_epochStarts < (now + 1 weeks));
        require(_thisYear < now);
        Epoch = _epochStarts;
        thisYearStartedAt = _thisYear;
        year = _year;
        registrationYear = _year;
        assert(_setNextYearTimestamp());    
        assert(nextYearStartsAt >= thisYearStartedAt + 365 days);
        creator = msg.sender;
        // require(_cashBox > 0);
        cashBox = _cashBox;
        createdByMethod[address(this)] = true;
        /* set creator as created by `Method` for preparatory stage */
        createdByMethod[creator] = true;
    }
    
    function _manageTime() internal returns (bool) {
        if (now >= Epoch + ((week + 1) * 1 weeks))
            week += 1;
        if (now >= nextYearStartsAt) {
            thisYearStartedAt = nextYearStartsAt;
            thisYearLeapsAdded = 0;
            year += 1;
            yearStartedAtWeek[year] = week;
            _setNextYearTimestamp();            
        }
        return true;
    }
    
    /* 
    /// The simple algorithm that determines a leap year.
    /// See: https://en.wikipedia.org/wiki/Leap_year#Algorithm
    */
    function _setNextYearTimestamp() internal returns (bool) {
        if (year % 4 == 0 && year % 100 != 0 || year % 400 == 0) {
            nextYearStartsAt += 366 days; // Leap year;
        } else {
            nextYearStartsAt += 365 days; // Common year;
        }
        return true;
    }
    
    /* External function to check out `CB` activity */
    function activeCentralBank(address _cb) external view returns (bool) {
        return CBMS(extensions[bytes4("CBMS")]).activeCentralBanks(_cb);
    }
    
    /*
    /// @notice Universal GRS "make" function that connects to the `CommonMethod` from DB.
    /// @param _name Name of `Method` in DB;
    /// @param _subject Any subject that operates with called `Method`.
    /// @return Whether the transaction was successful or not
    */
    function make(bytes32 _name, address _object)
        makeAndGetByTrusted(_name)
        payable external returns (bool)
    {
        _manageTime();
        return MethodMaker(methods[_name]).make(_object, msg.sender, msg.value);
    }
    
    /*
    /// @notice Universal GRS "execMake" function that connects to the `executive` `Method` from DB.
    /// @param _name Name of `Method` in DB;
    /// @param _subject Any subject that operates with called `Method`.
    /// @param _driver `Driver` address of contract that operates with called `Entity`.
    /// @return Whether the transaction was successful or not
    */
    function execMake(bytes32 _name, address _object, address payable _driver, uint256 _value)
        makeAndGetByTrusted(_name)
        payable external returns (bool)
    {
        _manageTime();
        return ExecMethodMaker(methods[_name]).execMake(_driver, _object, msg.sender, _value);
    }

    /*
    /// @notice Universal GRS "get" function that connects to the `Method` from DB.
    /// @param _name Name of `Method` in DB;
    /// @param _subject Address of object that operates with called `Method`.
    /// @return Any value converted to `uint256`
    */
    function get(bytes32 _name, address _object)
        makeAndGetByTrusted(_name)
        external view returns (uint256)
    {
        return MethodGetter(methods[_name]).get(_object, msg.sender);
    }
    
    /*
    /// @notice Universal GRS "execGet" function that connects to the `Method` from DB.
    /// @param _name Name of `Method` in DB;
    /// @param _subject Address of object that operates with called `Method`.
    /// @param _driver `Driver` address of contract that operates with called `Entity`.
    /// @return Any value converted to `uint256`
    */
    function execGet(bytes32 _name, address _object, address _driver)
        makeAndGetByTrusted(_name)
        external view returns (uint256)
    {
        return ExecMethodGetter(methods[_name]).execGet(_driver, _object, msg.sender);
    }
    
    /*
    /// @notice Function aimed at management of leap seconds of any year needed.
    /// Maximal yearly allowance is usually 1 second.
    /// See: https://en.wikipedia.org/wiki/Leap_second
    /// @return Whether the transaction was successful or not
    */
    function setLeapSecond()
        onlyByActiveMethod
        external returns (bool)
    {
        assert(thisYearLeapsAdded == 0);
        thisYearLeapsAdded += 1;
        nextYearStartsAt += 1;
        return true;
    }

    /*
    /// @notice Set the Stage of Economic System Lifecicle.
    /// Stage 0: preparatory stage;
    /// - Registration of all `Methods` and `Extensions`;
    /// - Migration of all tokens from `CashBox` platform;
    /// - Economic activity at this stage not yet allowed;
    /// Stage 1: transition period;
    /// - Registration of all `Methods` and `Extensions` by Voting System
    /// Stage 2: full load capacity stage;
    /// @param _stage Stage to setup.
    */
    function setLifecicleStage(uint8 _stage)
        onlyByActiveMethod
        external returns (bool)
    {
        require(_stage > 0);
        require(_stage < 3);
        require(_stage > lifecicleStage);
        lifecicleStage = _stage;
        /* unset `creator` from created by `Method` */
        if (createdByMethod[creator])
            createdByMethod[creator] = false;
        return true;
    }

    /*
    /// @notice Set the limit of products per one `Invoice`
    /// @param _limit New limit definition.
    */
    function setProductsLimit(uint8 _limit)
        onlyByActiveMethod
        external returns (bool)
    {
        require(_limit > 0);
        productsLimit = _limit;
        return true;
    }
    
    /*
    /// @notice Set the address of `Operator` cotract with global
    /// and common functions.
    /// @param _operator address of contract.
    */
    function setOperatorContract(address _operator)
        onlyByActiveMethod
        external returns (bool)
    {
        require(_operator > address(0));
        operator = Operator(_operator);
        return true;
    }

    /*
    /// @notice Set New `Extension` of database.
    /// Allowed to set just once if `Extension` not yet defined.
    /// @param _name Name of `Extension` in DB;
    /// @param _extension address of new `Extension`.
    */
    function setExtension(bytes4 _name, address _extension)
        onlyByActiveMethodOrPreparatory
        external returns (bool)
    {
        require(_name.length > 0);
        require(_extension > address(0));
        if (lifecicleStage > 0)
            assert(extensions[_name] == address(0));
        /* `Extension`s accounting */
        if (extensions[_name] == address(0)) {
            totalExtensions += 1;
            indexedExtensions[totalExtensions] = _name;
        } else {
            activeExtensions[extensions[_name]] = false;
        }
        extensions[_name] = _extension;
        activeExtensions[_extension] = true;
        return true;
    }

    /*
    /// @notice Set UPGRADE `Extension` of database created on common principles
    /// for each entity which participates in UPGRADE block.
    /// `Drivers` are not Allowed.
    /// @param _entity Address of entity in DB;
    /// @param _extension address of new `Extension`.
    */
    function setUpgradeExtension(address _entity, address _extension)
        onlyByActiveMethod
        external returns (bool)
    {
        require(_entity > address(0));
        require(_extension > address(0));
        //assert(upgradeExtensions[_entity] == 0);
        /* Deny creation of UPGRADE `Extension` for `Driver` */
        require(!DMS(extensions[bytes4("DMS")]).allDrivers(_entity));
        upgradeExtensions[_entity] = _extension;
        return true;
    }
    
    /*
    /// @notice Set contract created by active `Method`.
    /// @param _contract Address of any trusted contract created by `Method`;
    */
    function setCreatedByMethod(address _contract)
        onlyByActiveMethodOrPreparatory
        external returns (bool)
    {
        assert(!createdByMethod[_contract]);
        createdByMethod[_contract] = true;
        /* Counting of all `Subject` contracts */
        numberOfCreatedByMethod += 1;
        return true;
    }

    /*
    /// @notice The basis of `Method` deactivation.
    /// For temporary deactivation any methods in Economic System.
    /// Allowed to call just from active GRS `Method`.
    /// Method should be registered at the `GRS` DB.
    /// @param _name The name of `Method`.
    */
    function deactivateMethod(bytes32 _name)
        onlyByActiveMethodOrPreparatory
        external returns (bool)
    {
        require(methods[_name] > address(0));
        require(activeMethods[methods[_name]]);
        activeMethods[methods[_name]] = false;
        return true;
    }

    /*
    /// @notice The basis of `Method` activation.
    /// For activation any methods in Economic System.
    /// Allowed to call just from active GRS `Method`.
    /// Method should be registered at the `GRS` DB.
    /// @param _name The name of `Method`.
    */
    function activateMethod(bytes32 _name)
        onlyByActiveMethodOrPreparatory
        external returns (bool)
    {
        require(_name.length > 0);
        require(methods[_name] > address(0));
        require(!activeMethods[methods[_name]]);
        activeMethods[methods[_name]] = true;
        return true;
    }

    /*
    /// @notice Set New `Method` and Update previous with deactivation.
    /// @param _name Name of Method in DB;
    /// @param _method address of new `Method`.
    */
    function setMethod(bytes32 _name, address _method)
        onlyByActiveMethodOrPreparatory
        external returns (bool)
    {
        require(_name.length > 0);
        require(_method > address(0));
        /* `Method`s accounting */
        if (methods[_name] == address(0)) {
            totalMethods += 1;
            indexedMethods[totalMethods] = _name;
        }
        activeMethods[methods[_name]] = false;
        methods[_name] = _method;
        activeMethods[methods[_name]] = true;
        return true;
    }
    
    /*
    /// @notice The basis of credit Tokens creation of Economic System
    /// Defines created tokens at the side of `GRS` system account.
    /// Allowed to call just from active GRS `Method`.
    /// @param _amount Amount of tokens to be created.
    */
    function createTokens(uint256 _amount)
        onlyByActiveMethod
        external returns (bool)
    {
        totalTokenSupply += _amount;
        tokenBalances[address(this)] += _amount;
        return true;
    }
    
    /*
    /// @notice Credit Tokens migration tool from `CashBox` side
    /// Defines migrated tokens at the side of Ethereum wallet account.
    /// After that owner of Ethereum wallet will use the `redefineTokens`.
    /// Allowed to call just from `CashBox` side.
    /// @param _from Address of Ethereum wallet.
    /// @param _amount Amount of tokens to be migrated.
    */
    function migrateFrom(address _from, uint256 _amount) external returns (bool) {
        assert(lifecicleStage == 0);
        require(msg.sender == cashBox);
        require(_amount >= cashBoxTokenValue);
        uint amount = operator.removeOddFromNumber(_amount, cashBoxTokenValue);
        if (amount > 0) {
            amount /= cashBoxTokenValue;
            totalTokenSupply += amount;
            /* Defines to the Ethereum wallet address */
            tokenBalances[_from] += amount;
            return true;
        } revert();
    }
    
    /*
    /// @notice Credit Tokens definition tool from `CashBox` account owner
    /// to the `Driver` contract.
    /// Defines migrated tokens at the side of `Driver` account.
    /// Allowed to call just from Ethereum wallet that owns the `Driver` contract
    /// and owns amount of previously migrated tokens.
    */
    function redefineTokens() external returns (bool) {
        assert(lifecicleStage == 0);
        assert(tokenBalances[msg.sender] > 0);
        address owner = DMS(extensions[bytes4("DMS")]).getEthereumAccount(msg.sender);
        /* Before definition `Driver` contract should be registered */
        assert(owner > address(0));
        tokenBalances[owner] += tokenBalances[msg.sender];
        tokenBalances[msg.sender] = 0;
        return true; 
    }

    /*
    /// @notice Get Credit Tokens account Balance.
    /// Allowed to call just from trusted contract or GRS `Method`.
    /// @param _owner address of account owner;
    */
    function getTokenBalance(address _owner)
        getByTrusted(_owner)
        external view returns (uint256)
    {
        require(_owner > address(0));
        return tokenBalances[_owner];
    }

    /*
    /// @notice Get Ether account Balance.
    /// Allowed to call just from trusted contract or GRS `Method`.
    /// @param _owner address of account owner;
    */
    function getEtherBalance(address _owner)
        getByTrusted(_owner)
        external view returns (uint256)
    {
        require(_owner > address(0));
        return etherBalances[_owner];
    }
    
    /*
    /// @notice Get total account Balance of funds.
    /// Allowed to call just from trusted contract or GRS `Method`.
    /// @param _owner address of account owner;
    */
    function getBalance(address _owner)
        getByTrusted(_owner)
        external view returns (uint256)
    {
        require(_owner > address(0));
        return etherBalances[_owner] + tokenBalances[_owner];
    }

    /*
    /// @notice Send Tokens from one to another account.
    /// Allowed to call just from active GRS `Method`.
    /// @param _owner Address of token owner contract.
    /// @param _receiver Address of recipient contract.
    /// @param _amount Amount of tokens.
    */
    function sendTokens(address _owner, address _receiver, uint256 _amount)
        onlyByActiveMethod
        external returns (bool)
    {
        require(_owner > address(0));
        require(_receiver > address(0));
        require(_owner != _receiver);
        require(tokenBalances[_owner] >= _amount);
        tokenBalances[_owner] -= _amount;
        tokenBalances[_receiver] += _amount;
        return true;
    }
    
    /*
    /// @notice Direct Transactions basis.
    /// Send Ether from one to another account at the side of GRS DB.
    /// Allowed to call just from active GRS `Method`.
    /// @param _owner Address of Ether owner contract.
    /// @param _receiver Address of recipient contract.
    /// @param _amount Amount of Ether.
    */
    function sendEther(address _owner, address _receiver, uint256 _amount)
        onlyByActiveMethod
        external returns (bool)
    {
        require(_owner > address(0));
        require(_receiver > address(0));
        require(_owner != _receiver);
        require(etherBalances[_owner] >= _amount);
        etherBalances[_owner] -= _amount;
        etherBalances[_receiver] += _amount;
        return true;
    }
    
    /*
    /// @notice Ether Receiver basis.
    /// Transfer Ether from entity contract to their `GRS` account.
    /// In case of End-to-End tx. will receive first and after that `sendEther`.
    /// Can't receive Ether from the any `CB` side.
    /// Allowed to call just from active `GRS` `Method`.
    /// @param _entity Address of Ether owner contract.
    /// @param _amount Amount of Ether.
    */
    function receiveEther(address _entity, uint256 _amount)
        onlyByActiveMethod
        notAllowedForCB(_entity)
        external returns (bool)
    {
        require(_entity > address(0));
        etherBalances[_entity] += _amount;
        return true;
    }

    /*
    /// @notice Ether Withdrawal basis.
    /// Transfer Ether from GRS to caller contract.
    /// Can't withdraw Ether to the any CB side.
    /// Allowed to call just from active GRS `Method`.
    /// @param _entity Address of Ether owner contract.
    /// @param _amount Amount of Ether.
    */
    function withdrawEther(address payable _entity, uint256 _amount)
        onlyByActiveMethod
        notAllowedForCB(_entity)
        external returns (bool)
    {
        require(etherBalances[_entity] >= _amount);
        etherBalances[_entity] -= _amount;
        _entity.transfer(_amount);
        return true;
    }

    /*
    /// @notice The basis of definition of
    /// Ciclically Withdral Limits for each `CB`.
    /// Allowed to call just from active GRS `Method`.
    /// Allowed to set limits just to active `CB`.
    /// Allowed to setup only at transition period.
    /// @param _cb address of active `CB`.
    /// @param _limit Amount of limit of funds.
    */
    function setCiclicalWithdrawalLimits(address _cb, uint256 _limit)
        onlyByActiveMethod
        onlyForActiveCB(_cb)
        onlyRigidAmount(_limit)
        external returns (bool)
    {
        assert(lifecicleStage < 2);
        ciclicalWithdrawalLimits[_cb] = _limit;
        return true;
    }

    /*
    /// @notice The basis of definition of
    /// Ciclically Withdrals for entities.
    /// Allowed to call just from active GRS `Method`.
    /// Allowed to setup only at transition period.
    /// Not allowed for `CB` and `Drivers`.
    /// @param _entity Address of business or budgetary entity.
    /// @param _amount Amount of withdrawed funds.
    */
    function setCiclicallyWithdrawed(address _entity, uint256 _amount)
        onlyByActiveMethod
        onlyRigidAmount(_amount)
        external returns (bool)
    {
        // assert(lifecicleStage < 2);
        // assert(week > 4);
        require(_entity > address(0));
        /* Not a `Driver` contract */
        require(DMS(extensions[bytes4("DMS")]).activatedDriversBy(_entity) == address(0));
        uint256 totalWithdrawed = _amount;
        for (uint i = 0; i < ciclicalWithdrawalsTimeFrame; i++)
            totalWithdrawed += ciclicallyWithdrawed[week-i][_entity];
        address cb = operator.getCentralBankByEntity(_entity);
        assert(cb > address(0));
        if (ciclicalWithdrawalLimits[cb] <= totalWithdrawed)
            revert();
        ciclicallyWithdrawed[week][_entity] = _amount;
        return true;
    }

    /*
    /// @notice The basis of definition of Bank Deposits for any `CB`.
    /// Allowed to call just from active GRS `Method`.
    /// Allowed for `CB` only.
    /// @param _cb Address of `CB`.
    /// @param _amount Amount of bank deposit.
    */
    function addBankDeposit(address _cb, uint256 _amount)
        onlyByActiveMethod
        onlyForActiveCB(_cb)
        external returns (bool)
    {
        bankDeposits[_cb] += _amount;
        return true;
    }

    /*
    /// @notice The basis of deduction of Bank Deposits from any `CB`.
    /// Allowed to call just from active GRS `Method`.
    /// Allowed for `CB` only.
    /// @param _cb Address of `CB`.
    /// @param _amount Amount of bank deposit to deduct.
    */
    function deductBankDeposit(address _cb, uint256 _amount)
        onlyByActiveMethod
        onlyForActiveCB(_cb)
        external returns (bool)
    {
        /* 
        /// This line commented because having an idea, that deposits in turnover
        /// will show global common data without any deduction.
        /// Investigation needed.
        */
        // assert((bankDeposits[_cb] - bankDepositsInTurnover[_cb]) >= _amount);
        bankDeposits[_cb] -= _amount;
        return true;
    }
    
    /*
    /// @notice The basis of addition part of bank deposit into regional turnover.
    /// Allowed to call just from active GRS `Method`.
    /// Allowed for `CB` only.
    /// @param _cb Address of `CB`.
    /// @param _amount Amount of part of total bank deposits into turnover.
    */
    function addBankDepositsIntoTurnover(address _cb, uint256 _amount)
        onlyByActiveMethod
        onlyForActiveCB(_cb)
        external returns (bool)
    {
        assert(bankDeposits[_cb] >= _amount);
        bankDepositsInTurnover[_cb] += _amount;
        return true;
    }
    
    /*
    /// @notice The basis of deduction part of bank deposit from regional turnover.
    /// In case of loan repayment, with loan taken from bank deposit.
    /// Allowed to call just from active GRS `Method`.
    /// Allowed for `CB` only.
    /// @param _cb Address of `CB`.
    /// @param _amount Amount of part of total bank deposits from turnover.
    */
    function deductBankDepositsFromTurnover(address _cb, uint256 _amount)
        onlyByActiveMethod
        onlyForActiveCB(_cb)
        external returns (bool)
    {
        assert(bankDepositsInTurnover[_cb] >= _amount);
        bankDepositsInTurnover[_cb] -= _amount;
        return true;
    }
    
    /*
    /// @notice The basis of setting of interest rate on Bank Deposits for any `CB`.
    /// Allowed to call just from active GRS `Method`.
    /// Allowed for `CB` only.
    /// The idea is that the minimum interest rate on deposits should be 0.6% 
    /// and should increase by 0.6% each. This is created in order to display 
    /// the won amounts from the bank deposit in real time. 
    /// Thus, the real winnings will be updated every 60 days of the year.
    /// @param _cb Address of `CB`.
    /// @param _interest Percentage of interest rate of bank deposit.
    */
    function setInterestOnBankDeposits(address _cb, uint8 _interest)
        onlyByActiveMethod
        onlyForActiveCB(_cb)
        external returns (bool)
    {
        require(_interest >= 6);
        require(_interest % 6 == 0);
        interestsOnBankDeposits[_cb] = _interest;
        return true;
    }
    
    /*
    /// @notice The basis of setting the minimum value 
    /// of Bank Deposits for any `CB`.
    /// Allowed to call just from active GRS `Method`.
    /// Allowed for `CB` only.
    /// @param _cb Address of `CB`.
    /// @param _amount Amount of minimum value of bank deposit.
    */
    function setBankDepositMinValue(address _cb, uint256 _amount)
        onlyByActiveMethod
        onlyForActiveCB(_cb)
        onlyRigidAmount(_amount)
        external returns (bool)
    {
        bankDepositMinValues[_cb] = _amount;
        return true;
    }
    
    /*
    /// @notice The basis of setting the payd won of Bank Deposits
    /// from any `CB` to any depositor.
    /// Allowed to call just from active GRS `Method`.
    /// Allowed for `CB` only.
    /// @param _cb Address of `CB`.
    /// @param _amount Amount of won value of bank deposit.
    */
    function setPaydBankDepositInterest(address _cb, uint256 _amount)
        onlyByActiveMethod
        onlyForActiveCB(_cb)
        external returns (bool)
    {
        require(_amount > 0);
        paydBankDepositInterests[_cb] += _amount;
        return true;
    }
    
    /*
    /// @notice Get the amount of personal bank deposit.
    /// Allowed to call just from trusted contract or GRS `Method`.
    /// @param _depositor Address of personal contract of depositor.
    */
    function getBankDepositPrivateAmount(address _depositor)
        getByTrusted(_depositor)
        external view returns (uint256)
    {
        return bankDepositPrivateValues[_depositor].amount;
    }
    
    /*
    /// @notice Get the interst rate of personal bank deposit.
    /// Interest rate redefines after each withdrawal or new addition.
    /// Allowed to call just from trusted contract or GRS `Method`.
    /// @param _depositor Address of personal contract of depositor.
    */
    function getBankDepositPrivateInterest(address _depositor)
        getByTrusted(_depositor)
        external view returns (uint8)
    {
        return bankDepositPrivateValues[_depositor].interest;
    }
    
    /*
    /// @notice Get the definition time of personal bank deposit.
    /// Definition time redefines after each withdrawal or new addition.
    /// Allowed to call just from trusted contract or GRS `Method`.
    /// @param _depositor Address of personal contract of depositor.
    */
    function getTimeOfPrivateBankDeposit(address _depositor)
        getByTrusted(_depositor)
        external view returns (uint256)
    {
        return bankDepositPrivateValues[_depositor].time;
    }
    
    /*
    /// @notice The basis of setting the private amount of Bank Deposit
    /// for any depositor.
    /// Allowed to call just from active GRS `Method`.
    /// Not allowed for any `CB`s.
    /// @param _depositor Address of personal contract of _depositor.
    /// @param _amount NEW Amount of bank deposit.
    */
    function setPrivateAmountOfBankDeposit(address _depositor, uint256 _amount)
        onlyByActiveMethod
        notAllowedForCB(_depositor)
        external returns (bool)
    {
        /* In case of total withdrawals of Bank Deposits, do not define interest rate */
        if (_amount > 0) {
            uint8 interest = interestsOnBankDeposits[operator.getCentralBankByEntity(_depositor)];
            assert(interest > 0);
            bankDepositPrivateValues[_depositor].interest = interest;
        } else if (_amount == 0 && bankDepositPrivateValues[_depositor].interest > 0) {
            bankDepositPrivateValues[_depositor].interest = 0;
        }
        bankDepositPrivateValues[_depositor].amount = _amount;
        bankDepositPrivateValues[_depositor].time = now;
        return true;
    }
    
    /*
    /// @notice The basis of addition of loan for `CB`
    /// Allowed to call just from active GRS `Method`.
    /// Allowed just for any active `CB`.
    /// @param _cb Address of `CB`.
    /// @param _amount Amount of loan for `CB` to add.
    */
    function addLoanOfCentralBank(address _cb, uint256 _amount)
        onlyByActiveMethod
        onlyForActiveCB(_cb)
        external returns (bool)
    {
        require(_amount > 0);
        loansOfCentralBanks[_cb].amount += _amount;
        loansOfCentralBanks[_cb].lastAdded = now;
        totalLoansOfAllCentralBanks += _amount;
        return true;
    }
    
    /*
    /// @notice The basis of deduction of loan for `CB`
    /// Allowed to call just from active GRS `Method`.
    /// Allowed just for any active `CB`.
    /// @param _cb Address of `CB`.
    /// @param _amount Amount of loan for `CB` to deduct.
    */
    function deductLoanOfCentralBank(address _cb, uint256 _amount)
        onlyByActiveMethod
        onlyForActiveCB(_cb)
        external returns (bool)
    {
        require(_amount > 0);
        loansOfCentralBanks[_cb].amount -= _amount;
        loansOfCentralBanks[_cb].lastRepayment = now;
        totalLoansOfAllCentralBanks -= _amount;
        return true;
    }
    
    /*
    /// @notice Get the total amount of loan of `CB`
    /// Allowed to call just from trusted contract or GRS `Method`.
    /// @param _cb Address of `CB`.
    */
    function getLoanAmountOfCentralBank(address _cb)
        onlyByActiveMethod
        external view returns (uint256)
    {
        return loansOfCentralBanks[_cb].amount;
    }
    
    /*
    /// @notice The basis of delegation of loan from one `CB` to union `CB`
    /// Allowed to call just from active GRS `Method`.
    /// Allowed just for any active `CB`.
    /// @param _fromCb Address of `CB` delegated functions from.
    /// @param _toCb Address of `CB` delegated functions to.
    */
    function delegateAllLoansOfCentralBank(address _fromCb, address _toCb)
        onlyByActiveMethod
        external returns (bool)
    {
        require(CBMS(extensions[bytes4("CBMS")]).delegatedToCentralBanks(_fromCb) == _toCb);
        loansOfCentralBanks[_toCb] = loansOfCentralBanks[_fromCb];
        totalOutstandingLoans[_toCb] += totalOutstandingLoans[_fromCb];
        totalOutstandingLoans[_fromCb] = 0;
        return true;
    }
    
    /*
    /// @notice The basis of setting of maximal annual turnovers for
    /// any economy participator of region.
    /// Allowed to call just from active GRS `Method`.
    /// Allowed just for any active `CB`.
    /// @param _cb Address of `CB`.
    /// @param _number Number of annual turnovers.
    */
    function setMaxAnnualTurnoversForLoanForRegion(address _cb, uint8 _number)
        onlyByActiveMethod
        onlyForActiveCB(_cb)
        external returns (bool)
    {
        require(_number <= maxAnnualTurnoversForLoan);
        require(_number > 0);
        maxAnnualTurnoversForLoanForRegions[_cb] = _number;
        return true;
    }
    
    /*
    /// @notice The basis of deduction amounts from total
    /// outstanding loans of any region. (interests on loan not deductible).
    /// Allowed to call just from active GRS `Method`.
    /// Allowed just for any active `CB`.
    /// @param _cb Address of `CB`.
    /// @param _amount Amount of total loans part to deduct.
    */
    function deductFromTotalOutstandingLoan(address _cb, uint256 _amount)
        onlyByActiveMethod
        onlyForActiveCB(_cb)
        external returns (bool)
    {
        require(_amount > 0);
        require(totalOutstandingLoans[_cb] >= _amount);
        totalOutstandingLoans[_cb] -= _amount;
        return true;
    }
    
    /*
    /// @notice The basis of setting of loan amount, or loan amount update.
    /// Allowed to call just from active GRS `Method`.
    /// Allowed Not allowed for any `CB`.
    /// @param _entity Address of any entity.
    /// @param _amount NEW Amount of loan.
    */
    function setLoanAmount(address _entity, uint256 _amount)
        onlyByActiveMethod
        notAllowedForCB(_entity)
        external returns (bool)
    {
        address cb = operator.getCentralBankByEntity(_entity);
        if (_amount > 0) {
            /* 
            /// Total repayment needed before addition of new loan amount 
            /// in case of `Driver` regional migration process.
            */
            address delegatedToCb = CBMS(extensions[bytes4("CBMS")]).delegatedToCentralBanks(loanAmounts[_entity].givenByCB);
            if (
                loanAmounts[_entity].givenByCB > address(0)   && 
                loanAmounts[_entity].givenByCB != cb &&
                /* Current entity `CB` not equals to delegated from `CB` */
                cb != delegatedToCb
                ) 
            {
                revert();
            /* In case of unification process of regions, should redefined `CB` */
            } else if (cb == delegatedToCb) {
                loanAmounts[_entity].givenByCB = cb;
            }
            loanAmounts[_entity].repaymentRate = loanRepaymentRates[cb];
        } else {
            loanAmounts[_entity].givenByCB = address(0);
            loanAmounts[_entity].repaymentRate = 0;
        }
        /* zeroing repayments in case of `Method` should do deductions from amounts */
        loanAmounts[_entity].repayments = 0;
        loanAmounts[_entity].baseAmount = _amount;
        loanAmounts[_entity].lastAdded  = now;
        totalOutstandingLoans[cb] += _amount;
        return true;
    }
    
    /*
    /// @notice The basis of addition of loan repayment.
    /// Allowed to call just from active GRS `Method`.
    /// Allowed Not allowed for any `CB`.
    /// @param _entity Address of any entity.
    /// @param _amount NEW Amount of loan.
    */
    function addLoanRepayment(address _entity, uint256 _amount)
        onlyByActiveMethod
        notAllowedForCB(_entity)
        external returns (bool)
    {
        require(_amount > 0);
        loanAmounts[_entity].repayments += _amount;
        loanAmounts[_entity].lastRepayment = now;
        return true;
    }
    
    /*
    /// @notice The basis of delegation loan to NEW union `CB`.
    /// Allowed to call just from active GRS `Method`.
    /// Allowed Not allowed for any `CB`.
    /// @param _entity Address of any entity.
    */
    function delegateLoanToCentralBank(address _entity)
        onlyByActiveMethod
        notAllowedForCB(_entity)
        external returns (bool)
    {
        address cb = operator.getCentralBankByEntity(_entity);
        assert(cb != loanAmounts[_entity].givenByCB);
        require(cb == CBMS(extensions[bytes4("CBMS")]).delegatedToCentralBanks(loanAmounts[_entity].givenByCB));
        loanAmounts[_entity].givenByCB = cb;
        return true;
    }
    
    /*
    /// @notice Get the loan amount of any entity.
    /// Allowed to call just from trusted contract or GRS `Method`.
    /// @param _entity Address of any entity.
    */
    function getLoanAmount(address _entity)
        getByTrusted(_entity)
        external view returns (uint256)
    {
        return loanAmounts[_entity].baseAmount;
    }
    
    /*
    /// @notice Get the amount of total loan repayments of any entity.
    /// Allowed to call just from trusted contract or GRS `Method`.
    /// @param _entity Address of any entity.
    */
    function getLoanRepayments(address _entity)
        getByTrusted(_entity)
        external view returns (uint256)
    {
        return loanAmounts[_entity].repayments;
    }
    
    /*
    /// @notice Get the loan repayments rate of loan of any entity.
    /// Allowed to call just from trusted contract or GRS `Method`.
    /// @param _entity Address of any entity.
    */
    function getLoanRepaymentRate(address _entity)
        getByTrusted(_entity)
        external view returns (uint8)
    {
        return loanAmounts[_entity].repaymentRate;
    }
    
    /*
    /// @notice Get the timestamp of last loan amount update.
    /// Allowed to call just from trusted contract or GRS `Method`.
    /// @param _entity Address of any entity.
    */
    function getLoanTimestamp(address _entity)
        getByTrusted(_entity)
        external view returns (uint256)
    {
        return loanAmounts[_entity].lastAdded;
    }
    
    /*
    /// @notice Get the `CB` of loan given by.
    /// Allowed to call just from trusted contract or GRS `Method`.
    /// @param _entity Address of any entity.
    */
    function getLoanCentralBank(address _entity)
        getByTrusted(_entity)
        external view returns (address)
    {
        return loanAmounts[_entity].givenByCB;
    }
    
    /*
    /// @notice The basis of setting of loan repayment rate of `CB`.
    /// Allowed to call just from active GRS `Method`.
    /// Allowed Allowed just for active `CB`.
    /// @param _cb Address of any active `CB`.
    /// @param _rate Global Loan repayment rate of `CB`.
    */
    function setLoanRepaymentRate(address _cb, uint8 _rate)
        onlyByActiveMethod
        onlyForActiveCB(_cb)
        external returns (bool)
    {
        require(_rate > 0);
        loanRepaymentRates[_cb] = _rate;
        return true;
    }
    
    /*
    /// @notice The basis of setting of loan repayment method of any entity.
    /// Allowed to call just from active GRS `Method`.
    /// Allowed Not allowed for any `CB`.
    /// @param _entity Address of any active entity.
    /// @param _method Method 0-2.
    */
    function setLoanRepaymentMethod(address _entity, uint8 _method)
        onlyByActiveMethod
        notAllowedForCB(_entity)
        external returns (bool)
    {
        require(_method < 3);
        loanRepaymentMethods[_entity] = _method;
        return true;
    }
    
    /*
    /// @notice Get the loan repayment method of any entity.
    /// Allowed to call just from trusted contract or GRS `Method`.
    /// @param _entity Address of any entity.
    */
    function getLoanRepaymentMethod(address _entity)
        getByTrusted(_entity)
        external view returns (uint8)
    {
        return loanRepaymentMethods[_entity];
    }
    
    /*
    /// @notice The basis of setting of loan repayment percentage of any entity.
    /// In case of addition of percentage to tax on deal, or methods 0 and 2.
    /// Allowed to call just from active GRS `Method`.
    /// Allowed Not allowed for any `CB`.
    /// @param _entity Address of any active entity.
    /// @param _perc Percentage to add to any deal.
    */
    function setLoanRepaymentPercentage(address _entity, uint8 _perc)
        onlyByActiveMethod
        notAllowedForCB(_entity)
        external returns (bool)
    {
        require(_perc > 0);
        loanRepaymentPercentages[_entity] = _perc;
        return true;
    }
    
    /*
    /// @notice Get the loan repayment percentage of any entity.
    /// Allowed to call just from trusted contract or GRS `Method`.
    /// @param _entity Address of any entity.
    */
    function getLoanRepaymentPercentage(address _entity)
        getByTrusted(_entity)
        external view returns (uint8)
    {
        return loanRepaymentPercentages[_entity];
    }
    
    /*
    /// @notice The basis of setting of loan repayment ciclical amount of any entity.
    /// In case of ciclical repayments, or methods 1 and 2.
    /// Allowed to call just from active GRS `Method`.
    /// Allowed Not allowed for any `CB`.
    /// @param _entity Address of any active entity.
    /// @param _amount Amount of ciclical repayments.
    */
    function setLoanRepaymentCiclicalAmount(address _entity, uint256 _amount)
        onlyByActiveMethod
        external returns (bool)
    {
        require(_amount > 0);
        require(loanAmounts[_entity].baseAmount > _amount);
        loanRepaymentCiclicalAmounts[_entity] = _amount;
        return true;
    }
    
    /*
    /// @notice Get the amount of loan ciclical repayments of any entity.
    /// Allowed to call just from trusted contract or GRS `Method`.
    /// @param _entity Address of any entity.
    */
    function getLoanRepaymentCiclicalAmount(address _entity)
        getByTrusted(_entity)
        external view returns (uint256)
    {
        return loanRepaymentCiclicalAmounts[_entity];
    }
}

/*
/// @title `Extension` interface of `GRS` database.
*/
contract Extension {

    address public grsAddr;
    GRS public grSystem;

    /* Allowance to modify only by active GRS `Method` */
    modifier onlyByActiveMethod() {
        require(grSystem.activeMethods(msg.sender));
            _;
    }
    
    /*
    /// Allowance to set only for active `CB`.
    */
    modifier onlyForActiveCB(address _subject) {
        require(_activeCentralBank(_subject));
            _;
    }
    
    /*
    /// Allowance to GET only by owner of addr or active GRS `Method` at any stage.
    */
    modifier getByTrusted(address _sender) {
        require(_sender == msg.sender || grSystem.activeMethods(msg.sender));
            _;
    }
    
    /*
    /// Check week number.
    */
    modifier rightWeekNumber(uint256 _weekn) {
        require(_weekn <= _week());
            _;
    }
    
    /*
    /// Check year number.
    */
    modifier rightYearNumber(uint256 _yearn) {
        require(_yearn <= _year());
            _;
    }

    /*
    /// @notice Common function calling in any `Extension` constructor
    */
    function construction(address _grs, bytes4 _name) internal returns (bool) {
        require(_grs > address(0));
        assert(grsAddr == address(0));
        grsAddr = _grs;
        grSystem = GRS(_grs);
        require(grSystem.Epoch() > 0);
        require(grSystem.setExtension(_name, address(this)));
        return true;
    }
    
    function _year() internal view returns (uint256) {
        return grSystem.year();
    }
    
    function _week() internal view returns (uint256) {
        return grSystem.week();
    }
    
    function _grsExtension(bytes4 _name) internal view returns (address) {
        address ext = grSystem.extensions(_name);
        assert(ext > address(0));
        return ext;
    }
    
    function _activeCentralBank(address _cb) internal view returns (bool) {
        return grSystem.activeCentralBank(_cb);
    }
    
    /* Returns `Operator` contract */
    function _operator() internal view returns (Operator) {
        return grSystem.operator();
    }
}

/*
/// @title `Driver`s Management System is an `Extension` of `GRS` database.
/// Contains all global data for `Driver`s management.
*/
contract DMS is Extension {

    /*
    ///
    ////// Population accounting system
    ///
    */
    /* Global population of Economic System */
    uint256 public totalPopulation;
    /* Regional population of Economic System */
    mapping (address => uint256) public totalPopulationOfRegions;
    
    /* Global weekly accounting of human from previous paradigm registration */
    mapping (uint256 => uint256) public weeklyHumanRegistration;
    /* Global annual accounting of human from previous paradigm registration */
    mapping (uint256 => uint256) public annualHumanRegistration;
    
    /* Global accounting of birth per week */
    mapping (uint256 => uint256) public weeklyBirthAccounting;
    /* Global accounting of birth per year */
    mapping (uint256 => uint256) public annualBirthAccounting;
    /*
    ///
    ////// The common principle of ages accounting in 5 year groups:
    ///
    /// year => list of average ages in the calculus of 5 year groups;
    /// Where list of average ages in the calculus of 5 year groups is:
    /// index 0 = from 0  to 4  years;
    /// index 1 = from 5  to 9  years;
    /// index 2 = from 10 to 14 years;
    /// indexes 3-20 = from 15 to 104
    /// index 21 = >104 years;
    /// If any `Driver` has a 35 years old he is going to the group with index `7`.
    /// Eg. see the `addToAgeAccounting` function.
    /// Such a set of mappings gives opportunity to calculate:
    /// 1. Average life expectancy;
    /// 2. Reproductive ages of parents;
    */
    /* Global annual biological mothers age accounting */
    mapping (uint256 => uint256[22]) public annualMothersAgeAccounting;
    /* Global annual biological fathers age accounting */
    mapping (uint256 => uint256[22]) public annualFathersAgeAccounting;
    
    /* Global accounting of mortality per week */
    mapping (uint256 => uint256) public weeklyMortralityAccounting;
    /* Global accounting of mortality per year */
    mapping (uint256 => uint256) public annualMortralityAccounting;
    
    /* Global accounting of mortality ages per year */
    mapping (uint256 => uint256[22]) public annualMortralityAgesAccounting;
    /* Global annual age accounting of active `Driver`s */
    mapping (uint256 => uint256[22]) public annualDriversAgeAccounting;
    /* Annual age registration of active `Driver`s */
    mapping (uint256 => mapping (address => bool)) public annualAgeRegistration;
    
    /* Global annual accounting of sick leaves (in days) */
    mapping (uint256 => uint256) public annualAccountingOfSickLeaves;
    
    /* Global weekly accounting of accidents (in the number of cases by human) */
    mapping (uint256 => uint256) public weeklyAccountingOfAccidents;
    /* Global annual accounting of accidents (in the number of cases by human) */
    mapping (uint256 => uint256) public annualAccountingOfAccidents;
    
    /* Global annual accounting of average Life expectancy */
    mapping (uint256 => uint8) public averageLifeExpectancy;
    
    /*
    ///
    ////// `Driver` Management system
    ///
    */
    uint8 public constant imageExpirationLimits = 8; // each 8 year;
    /* CB's where drivers registered in */
    mapping (address => address) public centralBanks;
    /* `Driver` contracts which Ethereum Accounts corresponds to */
    mapping (address => address) ethereumAccounts;
    /* All `Driver` contracts that has been once activated by medical structures */
    mapping (address => bool) public allDrivers;
    /* All `PreDriver` should be in use just once */
    mapping (address => bool) public usedPreDrivers;
    /* Counting of all `PreDrivers` once registered */
    uint256 public numberOfPreDrivers;
    /* 
    /// Only `Driver` contracts that has been once activated by medical structures
    /// and not jet deactivated.
    */
    mapping (address => bool) public activeDrivers;
    /* Counting of all `Drivers` once activated */
    uint256 public numberOfDriversActivated;
    /* `Driver` contracts that has been activated by medical structures */
    mapping (address => address) public activatedDriversBy;
    /* `Driver` contracts that has been deactivated by medical structures */
    mapping (address => address) public deactivatedDriversBy;
    
    /*
    ///
    ////// `Driver`s Additional Tax payments accounting system
    ///
    */
    /* Accounting of weekly common taxes on deal payments of each `Driver` */
    mapping (uint256 => mapping (address => uint256)) weeklyTaxOnDealPayments;
    /* Accounting of annual common taxes on deal payments of each `Driver` */
    mapping (uint256 => mapping (address => uint256)) annualTaxOnDealPayments;
    
    /*
    ///
    ////// Accounting of `Driver`s salaries and Social guaranties
    ///
    */
    /* Accounting of weekly salaries payd to each `Driver` */
    mapping (uint256 => mapping (address => uint256)) weeklySalariesPayd;
    /* Accounting of annual salaries payd to each `Driver` */
    mapping (uint256 => mapping (address => uint256)) annualSalariesPayd;
    
    /* Accounting of weekly payments of social guartanties for each `Driver` */
    mapping (uint256 => mapping (address => uint256)) weeklySocialGuarantiesPayd;
    /* Accounting of annual payments of social guartanties for each `Driver` */
    mapping (uint256 => mapping (address => uint256)) annualSocialGuarantiesPayd;
    
    /*
    ///
    ////// `Driver`s as Entity internal extension (JUST SIMPLE PROTOTYPES)
    ///
    */
    /*
    /// List of `Driver`s that participating in Economy as business entity
    /// At `Driver` deactivation process should be deactiveated also here (!!!)
    */
    mapping (address => bool) public driversAsEntity;
    /* 
    /// Global accounting of weeks of industries where `Driver`s worked in.
    /// Accounting based on amounts raised.
    */
    mapping (uint256 => mapping (address => mapping (bytes6 => uint256))) public weeklyDriversIndustries;
    /* 
    /// Global accounting of years of industries where `Driver`s worked in.
    /// Accounting based on amounts raised.
    */
    mapping (uint256 => mapping (address => mapping (bytes6 => uint256))) public annualDriversIndustries;
    
    modifier onlyForActiveDriver(address _driver) {
        assert(activeDrivers[_driver]);
            _;
    }
    
    constructor (address _grs) public {
        assert(construction(_grs, bytes4("DMS")));
    }
    
    /*
    /// @notice Increment the global population and population of region.
    /// Allowed to call just from active GRS `Method`.
    /// Allowed to increment just for active `CB`.
    /// @param _cb Address of active `CB` contract.
    */
    function addToTotalPopulationOfRegion(address _cb)
        onlyByActiveMethod
        onlyForActiveCB(_cb)
        external returns (bool)
    {
        totalPopulation += 1;
        totalPopulationOfRegions[_cb] += 1;
        return true;
    }
    
    /*
    /// @notice Decrement the global population and population of region.
    /// Allowed to call just from active GRS `Method`.
    /// Allowed to decrement just for active `CB`.
    /// @param _cb Address of active `CB` contract.
    */
    function deductFromTotalPopulationOfRegion(address _cb)
        onlyByActiveMethod
        onlyForActiveCB(_cb)
        external returns (bool)
    {
        totalPopulation -= 1;
        totalPopulationOfRegions[_cb] -= 1;
        return true;
    }
    
    /*
    /// @notice The basis of increment annual, weekly human registration 
    /// and total population globally.
    /// In case of computation of Human registration accounting globally.
    /// Allowed to call just from active GRS `Method`.
    */
    function addToHumanRegistration()
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
    /// In case of computation of birth accounting globally.
    /// Allowed to call just from active GRS `Method`.
    /// @param _motherIndex Index of mother age in list of 5 year groups.
    /// @param _fatherIndex Index of father age in list of 5 year groups.
    */
    function addToBirthAccounting(uint8 _motherIndex, uint8 _fatherIndex)
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
    /// and decrement total population globally.
    /// In case of computation of mortality accounting globally.
    /// Allowed to call just from active GRS `Method`.
    /// @param _index Index of `Driver` given into account in list of 5 year groups.
    */
    function addToMortalityAccounting(uint8 _index)
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
    /// @param _index Index of `Driver` given into account in list of 5 year groups.
    */
    function addToAgeAccounting(address _driver, uint8 _index)
        onlyByActiveMethod
        onlyForActiveDriver(_driver)
        external returns (bool)
    {
        if (annualAgeRegistration[_year()][_driver])
            return true;
        require(_index < 22);
        annualDriversAgeAccounting[_year()][_index] += 1;
        annualAgeRegistration[_year()][_driver] = true;
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
    function addToAccidents()
        onlyByActiveMethod
        external returns (bool)
    {
        weeklyAccountingOfAccidents[_week()] += 1;
        annualAccountingOfAccidents[_year()] += 1;
        return true;
    }
    
    /*
    /// @notice Set the global average life expectancy.
    /// Allowed to call just from active GRS `Method`.
    /// Allowed to call just once a year
    /// @param _expectancy Global average life expectancy.
    */
    function setAverageLifeExpectancy(uint8 _expectancy)
        onlyByActiveMethod
        external returns (bool)
    {
        require(_expectancy > 0);
        require(averageLifeExpectancy[_year()] == 0);
        averageLifeExpectancy[_year()] = _expectancy;
        return true;
    }
    
    /*
    /// @notice The basis of setting of `CB` where `Driver` registered.
    /// Allowed to call just from active GRS `Method`.
    /// @param _person Address of `Driver` contract.
    /// @param _cb Address of `CB` contract.
    */
    function setCentralBank(address _driver, address _cb)
        onlyByActiveMethod
        onlyForActiveDriver(_driver)
        onlyForActiveCB(_cb)
        external returns (bool)
    {
        centralBanks[_driver] = _cb;
        return true;
    }

    /*
    /// @notice Set the `Driver`s management Ethereum Account.
    /// Allowed to call just from active GRS `Method`.
    /// @param _driver Address of `Driver` contract.
    /// @param _account Address of Ethereum account.
    */
    function setEthereumAccount(address _driver, address _account)
        onlyByActiveMethod
        external returns (bool)
    {
        require(_driver > address(0));
        require(_account > address(0));
        require(ethereumAccounts[_driver] == address(0));
        ethereumAccounts[_driver] = _account;
        return true;
    }
    
    /*
    /// @notice Get the `Driver`s management Ethereum Account.
    /// Allowed to call just from active GRS `Method`.
    /// @param _driver Address of `Driver` contract.
    */
    function getEthereumAccount(address _driver)
        getByTrusted(_driver)
        external view returns (address)
    {
        require(_driver > address(0));
        return ethereumAccounts[_driver];
    }
    
    /*
    /// @notice Set the `PreDriver`s as used.
    /// Allowed to call just from active GRS `Method`.
    /// @param _preDriver Address of `PreDriver` contract.
    */
    function setPreDriverAsUsed(address _preDriver)
        onlyByActiveMethod
        external returns (bool)
    {
        require(_preDriver > address(0));
        assert(!usedPreDrivers[_preDriver]);
        usedPreDrivers[_preDriver] = true;
        numberOfPreDrivers += 1;
        return true;
    }
    
    /*
    /// @notice Set the `Driver` contract as active.
    /// Allowed to call just from active GRS `Method`.
    /// Allowed to set just with trusted medical structure.
    /// @param _driver Address of any active `Driver` contract.
    /// @param _activatedBy Address of Medical structure contract.
    */
    function activateDriver(address _driver, address _activatedBy)
        onlyByActiveMethod
        external returns (bool)
    {
        require(_driver > address(0));
        assert(!activeDrivers[_driver]);
        require(CBMS(_grsExtension(bytes4("CBMS"))).medicalCentralBanks(_activatedBy) > address(0));
        assert(ethereumAccounts[_driver] > address(0));
        allDrivers[_driver] = true;
        activeDrivers[_driver] = true;
        activatedDriversBy[_driver] = _activatedBy;
        numberOfDriversActivated += 1;
        return true;
    }
    
    /*
    /// @notice Set the `Driver` contract as deactivated.
    /// Allowed to call just from active GRS `Method`.
    /// Allowed to deactivate just with trusted medical structure.
    /// @param _driver Address of any active `Driver` contract.
    /// @param _deactivatedBy Address of Medical structure contract.
    */
    function deactivateDriver(address _driver, address _deactivatedBy)
        onlyByActiveMethod
        onlyForActiveDriver(_driver)
        external returns (bool)
    {
        require(CBMS(_grsExtension(bytes4("CBMS"))).medicalCentralBanks(_deactivatedBy) > address(0));
        assert(activeDrivers[_driver]);
        activeDrivers[_driver] = false;
        deactivatedDriversBy[_driver] = _deactivatedBy;
        driversAsEntity[_driver] = false;
        return true;
    }
    
    /*
    /// @notice The basis of addition of common Tax on deal payment of any `Driver`.
    /// Addition is fixes at all levels of database needed.
    /// Allowed to call just from active GRS `Method`.
    /// Allowed to add only for `Driver` contract.
    /// @param _driver Address of any active `Driver`.
    /// @param _amount Amount of Tax.
    */
    function addPaymentOfTaxOnDeal(address _driver, uint256 _amount)
        onlyByActiveMethod
        onlyForActiveDriver(_driver)
        external returns (bool)
    {
        require(_amount > 0);
        weeklyTaxOnDealPayments[_week()][_driver] += _amount;
        annualTaxOnDealPayments[_year()][_driver] += _amount;
        return true;
    }
    
    /*
    /// @notice Get the `Driver`s Tax on deal payments of given week.
    /// Allowed to call just from active GRS `Method`.
    /// @param _weekn Number of week.
    /// @param _driver Address of `Driver` contract.
    */
    function getWeeklyTaxOnDealPayment(uint256 _weekn, address _driver)
        rightWeekNumber(_weekn)
        getByTrusted(_driver)
        external view returns (uint256)
    {
        return weeklyTaxOnDealPayments[_weekn][_driver];
    }
    
    /*
    /// @notice Get the `Driver`s Tax on deal payments of given year.
    /// Allowed to call just from active GRS `Method`.
    /// @param _yearn Number of year.
    /// @param _driver Address of `Driver` contract.
    */
    function getAnnualTaxOnDealPayment(uint256 _yearn, address _driver)
        rightYearNumber(_yearn)
        getByTrusted(_driver)
        external view returns (uint256)
    {
        return weeklyTaxOnDealPayments[_yearn][_driver];
    }
    
    /*
    /// @notice The basis of addition of salary payment to any `Driver`.
    /// Addition is fixes at all levels of database needed.
    /// Allowed to call just from active GRS `Method`.
    /// Allowed to add only for `Driver` contract.
    /// @param _driver Address of any active `Driver`.
    /// @param _amount Amount of salary.
    */
    function addSalary(address _driver, uint256 _amount)
        onlyByActiveMethod
        onlyForActiveDriver(_driver)
        external returns (bool)
    {
        require(_amount > 0);
        weeklySalariesPayd[_week()][_driver] += _amount;
        annualSalariesPayd[_year()][_driver] += _amount;
        return true;
    }
    
    /*
    /// @notice Get the amount of salaries paid to the `Driver`s of given week.
    /// Allowed to call just from active GRS `Method`.
    /// @param _weekn Number of week.
    /// @param _driver Address of `Driver` contract.
    */
    function getWeeklySalaryPaid(uint256 _weekn, address _driver)
        rightWeekNumber(_weekn)
        getByTrusted(_driver)
        external view returns (uint256)
    {
        require(_weekn <= _week());
        return weeklySalariesPayd[_weekn][_driver];
    }
    
    /*
    /// @notice Get the amount of salaries paid to the `Driver`s of given year.
    /// Allowed to call just from active GRS `Method`.
    /// @param _yearn Number of year.
    /// @param _driver Address of `Driver` contract.
    */
    function getAnnualSalaryPaid(uint256 _yearn, address _driver)
        rightYearNumber(_yearn)
        getByTrusted(_driver)
        external view returns (uint256)
    {
        return annualSalariesPayd[_yearn][_driver];
    }
    
    /*
    /// @notice The basis of addition of social guaranty payment to any `Driver`.
    /// Addition is fixes at all levels of database needed.
    /// Allowed to call just from active GRS `Method`.
    /// Allowed to add only for active `Driver` contract.
    /// @param _driver Address of any active `Driver`.
    /// @param _amount Amount of salary.
    */
    function addSocialGuarantyPayment(address _driver, uint256 _amount)
        onlyByActiveMethod
        onlyForActiveDriver(_driver)
        external returns (bool)
    {
        require(_amount > 0);
        weeklySocialGuarantiesPayd[_week()][_driver] += _amount;
        annualSocialGuarantiesPayd[_year()][_driver] += _amount;
        return true;
    }
    
    /*
    /// @notice Get the amount of social guaranties paid to the `Driver`s of given week.
    /// Allowed to call just from active GRS `Method`.
    /// @param _weekn Number of week.
    /// @param _driver Address of `Driver` contract.
    */
    function getWeeklySocialGuarantyPayment(uint256 _weekn, address _driver)
        rightWeekNumber(_weekn)
        getByTrusted(_driver)
        external view returns (uint256)
    {
        return weeklySocialGuarantiesPayd[_weekn][_driver];
    }
    
    /*
    /// @notice Get the amount of social guaranties paid to the `Driver`s of given year.
    /// Allowed to call just from active GRS `Method`.
    /// @param _yearn Number of year.
    /// @param _driver Address of `Driver` contract.
    */
    function getAnnualSocialGuarantyPayment(uint256 _yearn, address _driver)
        rightYearNumber(_yearn)
        getByTrusted(_driver)
        external view returns (uint256)
    {
        return annualSocialGuarantiesPayd[_yearn][_driver];
    }
    
    /*
    /// @notice The basis of setting of any `Driver` as entity.
    /// Allowed to call just from active GRS `Method`.
    /// Allowed to add only for active `Driver` contract.
    /// @param _driver Address of any active `Driver`.
    */
    function setDriverAsEntity(address _driver)
        onlyByActiveMethod
        onlyForActiveDriver(_driver)
        external returns (bool)
    {
        assert(!driversAsEntity[_driver]);
        driversAsEntity[_driver] = true;
        return true;
    }
    
    /*
    /// @notice The basis of resetting of any `Driver` to basic functions.
    /// Allowed to call just from active GRS `Method`.
    /// Allowed to add only for active `Driver` contract.
    /// @param _driver Address of any active `Driver`.
    */
    function resetDriverAsEntity(address _driver)
        onlyByActiveMethod
        onlyForActiveDriver(_driver)
        external returns (bool)
    {
        assert(driversAsEntity[_driver]);
        driversAsEntity[_driver] = false;
        return true;
    }
    
    /*
    /// @notice The basis of addition of amounts raised to to any `Driver` industry.
    /// Addition is fixes at all levels of database needed.
    /// Allowed to call just from active GRS `Method`.
    /// Allowed to add only for active `Driver` contract.
    /// @param _driver Address of any active `Driver`.
    /// @param _industry Industry global id `Driver`.
    /// @param _amount raised Amount.
    */
    function addAmountToDriverIndustry(address _driver, bytes6 _industry, uint256 _amount)
        onlyByActiveMethod
        onlyForActiveDriver(_driver)
        external returns (bool)
    {   
        require(_industry.length > 0);
        require(_amount > 0);
        weeklyDriversIndustries[_week()][_driver][_industry] += _amount;
        annualDriversIndustries[_year()][_driver][_industry] += _amount;
        return true;
    }
    
    /*
    /// @notice Get the amount raised by the `Driver` in given industry of given week.
    /// Allowed to call just from active GRS `Method`.
    /// @param _weekn Number of week.
    /// @param _driver Address of `Driver` contract.
    /// @param _industry Identifier of industry.
    */
    function getWeeklyAmountOfDriverIndustry(uint256 _weekn, address _driver, bytes6 _industry)
        rightWeekNumber(_weekn)
        getByTrusted(_driver)
        external view returns (uint256)
    {
        return weeklyDriversIndustries[_weekn][_driver][_industry];
    }
    
    /*
    /// @notice Get the amount raised by the `Driver` in given industry of given year.
    /// Allowed to call just from active GRS `Method`.
    /// @param _yearn Number of year.
    /// @param _driver Address of `Driver` contract.
    /// @param _industry Identifier of industry.
    */
    function getAnnualAmountOfDriverIndustry(uint256 _yearn, address _driver, bytes6 _industry)
        rightYearNumber(_yearn)
        getByTrusted(_driver)
        external view returns (uint256)
    {
        return annualDriversIndustries[_yearn][_driver][_industry];
    }
}

/*
/// @title `Company` Management System is an `Extension` of `GRS` database.
/// Contains all global data for `Company` management.
*/
contract CMS is Extension {
    
    /*
    ///
    ////// Global Management and accounting of Companies
    ///
    */
    /* All `Company` contracts that has been once activated */
    mapping (address => bool) public allCompanies;
    /* All active `Company`ies names in global order (not deactivated) */
    mapping (bytes32 => bool) public globalCompanyNames;
    
    mapping (bytes32 => address) public cbAddressByCompanyName;
    /* `Company` contracts that has been activated */
    mapping (address => bool) public activeCompanies;
    /* `Company` contracts that has been deactivated */
    mapping (address => address) public deactivatedCompanies;
    /* Contains all Entities under sanctions by their expiration timestamps */
    mapping (address => uint256) public companySanctionsExpires;
    
    /* Only if `Company` is Active */
    modifier onlyForActiveCompany(address _company) {
        assert(activeCompanies[_company]);
            _;
    }
    
    constructor (address _grs) public {
        assert(construction(_grs, bytes4("CMS")));
    }
    
    /*
    /// @notice The basis of any `Company` assignation to the global names register.
    /// Allowed to call just from active GRS `Method`.
    /// @param _name Unique Name of any entity contract.
    /// @param _cb Address of active `CB` contract.
    */
    function addToGlobalCompanyNames(bytes32 _name, address _cb)
        onlyForActiveCB(_cb)
        onlyByActiveMethod
        external returns (bool)
    {
        assert(!globalCompanyNames[_name]);
        globalCompanyNames[_name] = true;
        cbAddressByCompanyName[_name] = _cb;
        return true;
    }
    
    /*
    /// @notice The basis of setting any `Company` to sanction list 
    /// by expiration timestamp.
    /// Allowed to call just from active GRS `Method`.
    /// @param _entity Address of entity.
    /// @param _timestamp Sanctions expiration timestamp.
    */
    function imposeSanctionsToCompany(address _company, uint256 _timestamp)
        onlyForActiveCompany(_company)
        onlyByActiveMethod
        external returns (bool)
    {
        assert(activeCompanies[_company]);
        companySanctionsExpires[_company] = _timestamp;
        return true;
    }
}

/*
/// @title `Budget` organisations Management System is an `Extension` of `GRS` database.
/// Contains all global data for `Budget` organisations management.
*/
contract BOMS is Extension {
    
    /* All `Company` contracts that has been once activated */
    mapping (address => bool) public allBudgetOrgs;
    /* `Company` contracts that has been activated */
    mapping (address => bool) public activatedBudgetOrgs;
    /* `Company` contracts that has been deactivated by any contract*/
    mapping (address => address) public deactivatedBudgetOrgs;
    /* `Driver`s that responsible for `Company` */
    //mapping (address => address) public companiesOf
    /* Global accounting of coworkers for `Company` */
    mapping (address => uint256) public budgetOrgCoworkersNumber;
    
    constructor (address _grs) public {
        assert(construction(_grs, bytes4("BOMS")));
    }
}

/*
/// @title `CB` Management System is an `Extension` of `GRS` database.
/// Contains all global data for regional `CB` management.
*/
contract CBMS is Extension {
    /*
    ///
    ////// Central Banks control system and integrated in them organizations
    ///
    */
    /* List of Central Banks */
    address[] public centralBanks;
    /* List of Active Central Banks */
    mapping (address => bool) public activeCentralBanks;
    /* List of All active and not Central Banks (before and after unification process) */
    mapping (address => bool) public allCentralBanks;
    /* Delegated to Central Banks */
    mapping (address => address) public delegatedToCentralBanks;
    /* List of All Central Banks for all economy participants */
    mapping (address => address) public commonCentralBanks;
    /*
    /// SET ALL OF CB TO OWN EXTENSION (!!!)
    */
    /* CB's where Medical structures registered in */
    mapping (address => address) public medicalCentralBanks;
    /* CB's where Budget organizations registered in */
    mapping (address => address) public budgetCentralBanks;
    /* CB's where companies registered in */
    mapping (address => address) public companyCentralBanks;
    /* All `PreCentralBank` should be in use just once */
    mapping (address => bool) public usedPreCentralBanks;
    /* Total number of `PreCentralBank` contracts already registered */
    uint256 public numberOfPreCentralBanks;
    
    /*
    ///
    ////// Taxes accounting system
    ///
    */
    /* Global tax for withdrawals % */
    uint256 public withdrawalTax = 100;
    /* General Tax of each payment between regions and SW block % */
    uint256 public generalTax = 50;
    /* The limit of general Tax % */
    uint256 public generalTaxLimit = 80;

    /*
    /// Income tax
    */
    /* Accounting of weekly Income tax fees to each regional CB */
    mapping (uint256 => mapping (address => uint256)) public weeklyIncomeTaxPayments;
    /* Accounting of annual Income tax fees to each regional CB */
    mapping (uint256 => mapping (address => uint256)) public annualIncomeTaxPayments;
    
    /*
    /// General tax
    */
    /* Accounting of weekly General tax fees to each regional CB */
    mapping (uint256 => mapping (address => uint256)) public weeklyGeneralTaxPayments;
    /* Accounting of annual General tax fees to each regional CB */
    mapping (uint256 => mapping (address => uint256)) public annualGeneralTaxPayments;
    
    /*
    /// Subsidy tax
    */
    /* Accounting of weekly Subsidy tax fees to each regional CB */
    mapping (uint256 => mapping (address => uint256)) public weeklySubsidyTaxPayments;
    /* Accounting of annual Subsidy tax fees to each regional CB */
    mapping (uint256 => mapping (address => uint256)) public annualSubsidyTaxPayments;
    
    /*
    /// Upgrade tax
    */
    /* Accounting of weekly Upgrade tax fees to each regional CB */
    mapping (uint256 => mapping (address => uint256)) public weeklyUpgradeTaxPayments;
    /* Accounting of annual Upgrade tax fees to each regional CB */
    mapping (uint256 => mapping (address => uint256)) public annualUpgradeTaxPayments;
    
    /*
    /// Extra tax
    */
    /* Accounting of weekly Extra tax fees to each regional CB */
    mapping (uint256 => mapping (address => uint256)) public weeklyExtraTaxPayments;
    /* Accounting of annual Extra tax fees to each regional CB */
    mapping (uint256 => mapping (address => uint256)) public annualExtraTaxPayments;
    
    /*
    /// Contour tax
    */
    /* Accounting of weekly Contour tax fees to each regional CB */
    mapping (uint256 => mapping (address => uint256)) public weeklyContourTaxPayments;
    /* Accounting of annual Contour tax fees to each regional CB */
    mapping (uint256 => mapping (address => uint256)) public annualContourTaxPayments;
    
    /*
    /// Migration tax
    */
    /* Accounting of weekly Migration tax fees to each regional CB */
    mapping (uint256 => mapping (address => uint256)) public weeklyMigrationTaxPayments;
    /* Accounting of annual Migration tax fees to each regional CB */
    mapping (uint256 => mapping (address => uint256)) public annualMigrationTaxPayments;
    
    /*
    /// Emigration tax
    */
    /* Accounting of weekly Emigration tax fees to each regional CB */
    mapping (uint256 => mapping (address => uint256)) public weeklyEmigrationTaxPayments;
    /* Accounting of annual Emigration tax fees to each regional CB */
    mapping (uint256 => mapping (address => uint256)) public annualEmigrationTaxPayments;
    
    /* Rewrite modifier to reduce cost of tx */
    modifier onlyForActiveCB(address _cb) {
        require(activeCentralBanks[_cb]);
            _;
    }

    constructor (address _grs) public {
        assert(construction(_grs, bytes4("CBMS")));
        /* Set `GRS` as active Central Bank for funds management */
        activeCentralBanks[_grs] = true;
    }

    /*
    /// @notice Set the CB where `Driver` should be registered.
    /// Allowed to call just from active GRS `Method`.
    /// @param _person Address of `Driver` contract.
    /// @param _cb Address of `CB` contract.
    */
    function getDriversCentralBank(address _driver)
        onlyByActiveMethod
        external view returns (address)
    {
        return DMS(_grsExtension(bytes4("DMS"))).centralBanks(_driver);
    }

    /*
    /// @notice Set the CB where `Medical` organization should be registered.
    /// Allowed to call just from active GRS `Method`.
    /// Organization Can't change CB. It changes just at the regional union process;
    /// @param _medical Address of `Medical` organization contract.
    /// @param _cb Address of `CB` contract.
    */
    function setMedicalCentralBank(address _medical, address _cb)
        onlyByActiveMethod
        external returns (bool)
    {
        require(_medical > address(0));
        require(_cb > address(0));
        require(medicalCentralBanks[_medical] == address(0));
        medicalCentralBanks[_medical] = _cb;
        return true;
    }

    /*
    /// @notice Set the CB where `Budget` organization should be registered.
    /// Allowed to call just from active GRS `Method`.
    /// Organization Can't change CB. It changes just at the regional union process;
    /// @param _budget Address of `Budget` organization contract.
    /// @param _cb Address of `CB` contract.
    */
    function setBudgetCentralBank(address _budget, address _cb)
        onlyByActiveMethod
        external returns (bool)
    {
        require(_budget > address(0));
        require(_cb > address(0));
        require(budgetCentralBanks[_budget] == address(0));
        budgetCentralBanks[_budget] = _cb;
        return true;
    }

    /*
    /// @notice Set the CB where `Company` should be registered.
    /// Allowed to call just from active GRS `Method`.
    /// Company Can't change CB. It changes just at the regional union process;
    /// @param _company Address of `Company` contract.
    /// @param _cb Address of `CB` contract.
    */
    function setCompanyCentralBank(address _company, address _cb)
        onlyByActiveMethod
        external returns (bool)
    {
        require(_company > address(0));
        require(_cb > address(0));
        require(companyCentralBanks[_company] == address(0));
        companyCentralBanks[_company] = _cb;
        return true;
    }
    
    /*
    /// @notice Set the `PreCentralBank`s as used.
    /// Allowed to call just from active GRS `Method`.
    /// @param _preCB Address of `PreCentralBank` contract.
    */
    function setPreCentralBankAsUsed(address _preCB)
        onlyByActiveMethod
        external returns (bool)
    {
        require(_preCB > address(0));
        assert(!usedPreCentralBanks[_preCB]);
        usedPreCentralBanks[_preCB] = true;
        numberOfPreCentralBanks += 1;
        return true;
    }
    
     /*
    /// @notice Set the tax of withdrawals to `Company` contracts
    /// @param _tax Tax to setup.
    */
    function setWithdrawalTax(uint16 _tax)
        onlyByActiveMethod
        external returns (bool)
    {
        require(_tax > 0);
        require(GRS(grSystem).lifecicleStage() < 2);
        withdrawalTax = _tax;
        return true;
    }

    /*
    /// @notice Set the general tax of cross regional deals. 
    /// In future can be used just from accepted `Driver` contract.
    /// @param _tax Tax to setup.
    */
    function setGeneralTax(uint8 _tax)
        onlyByActiveMethod
        external returns (bool)
    {
        require(_tax > 0);
        require(_tax <= generalTaxLimit);
        generalTax = _tax;
        return true;
    }

    /*
    /// @notice Set the gloabal general tax limit.
    /// @param _limit Tax limit to setup.
    */
    function setGeneralTaxLimit(uint8 _limit)
        onlyByActiveMethod
        external returns (bool)
    {
        require(_limit > 0);
        require(_limit <= 8);
        generalTaxLimit = _limit;
        return true;
    }
    
    /*
    /// @notice The basis of addition of Income Tax payment to given `CB`.
    /// Allowed to call just from active GRS `Method`.
    /// @param _cb Active `CB` contract.
    /// @param _amount Amount of Tax.
    */
    function addPaymentOfIncomeTax(address _cb, uint256 _amount)
        onlyForActiveCB(_cb)
        onlyByActiveMethod
        external returns (bool)
    {
        require(_amount > 0);
        weeklyIncomeTaxPayments[_week()][_cb] += _amount;
        annualIncomeTaxPayments[_year()][_cb] += _amount;
        return true;
    }
    
    /*
    /// @notice The basis of addition of General Tax payment to given `CB`.
    /// Allowed to call just from active GRS `Method`.
    /// @param _cb Active `CB` contract.
    /// @param _amount Amount of Tax.
    */
    function addPaymentOfGeneralTax(address _cb, uint256 _amount)
        onlyForActiveCB(_cb)
        onlyByActiveMethod
        external returns (bool)
    {
        require(_amount > 0);
        weeklyGeneralTaxPayments[_week()][_cb] += _amount;
        annualGeneralTaxPayments[_year()][_cb] += _amount;
        return true;
    }
    
    /*
    /// @notice The basis of addition of Subsidy Tax payment to given `CB`.
    /// Allowed to call just from active GRS `Method`.
    /// @param _cb Active `CB` contract.
    /// @param _amount Amount of Tax.
    */
    function addPaymentOfSubsidyTax(address _cb, uint256 _amount)
        onlyForActiveCB(_cb)
        onlyByActiveMethod
        external returns (bool)
    {
        require(_amount > 0);
        weeklySubsidyTaxPayments[_week()][_cb] += _amount;
        annualSubsidyTaxPayments[_year()][_cb] += _amount;
        return true;
    }
    
    /*
    /// @notice The basis of addition of Upgrade Tax payment to given `CB`.
    /// Allowed to call just from active GRS `Method`.
    /// @param _cb Active `CB` contract.
    /// @param _amount Amount of Tax.
    */
    function addPaymentOfUpgradeTax(address _cb, uint256 _amount)
        onlyForActiveCB(_cb)
        onlyByActiveMethod
        external returns (bool)
    {
        require(_amount > 0);
        weeklyUpgradeTaxPayments[_week()][_cb] += _amount;
        annualUpgradeTaxPayments[_year()][_cb] += _amount;
        return true;
    }
    
    /*
    /// @notice The basis of addition of Extra Tax payment to given `CB`.
    /// Allowed to call just from active GRS `Method`.
    /// @param _cb Active `CB` contract.
    /// @param _amount Amount of Tax.
    */
    function addPaymentOfExtraTax(address _cb, uint256 _amount)
        onlyForActiveCB(_cb)
        onlyByActiveMethod
        external returns (bool)
    {
        require(_amount > 0);
        weeklyExtraTaxPayments[_week()][_cb] += _amount;
        annualExtraTaxPayments[_year()][_cb] += _amount;
        return true;
    }
    
    /*
    /// @notice The basis of addition of Contour Tax payment to given `CB`.
    /// Allowed to call just from active GRS `Method`.
    /// @param _cb Active `CB` contract.
    /// @param _amount Amount of Tax.
    */
    function addPaymentOfContourTax(address _cb, uint256 _amount)
        onlyForActiveCB(_cb)
        onlyByActiveMethod
        external returns (bool)
    {
        require(_amount > 0);
        weeklyContourTaxPayments[_week()][_cb] += _amount;
        annualContourTaxPayments[_year()][_cb] += _amount;
        return true;
    }
    
    /*
    /// @notice The basis of addition of Migration Tax payment to given `CB`.
    /// Allowed to call just from active GRS `Method`.
    /// @param _cb Active `CB` contract.
    /// @param _amount Amount of Tax.
    */
    function addPaymentOfMigrationTax(address _cb, uint256 _amount)
        onlyForActiveCB(_cb)
        onlyByActiveMethod
        external returns (bool)
    {
        require(_amount > 0);
        weeklyMigrationTaxPayments[_week()][_cb] += _amount;
        annualMigrationTaxPayments[_year()][_cb] += _amount;
        return true;
    }
    
    /*
    /// @notice The basis of addition of Emigration Tax payment to given `CB`.
    /// Allowed to call just from active GRS `Method`.
    /// @param _cb Active `CB` contract.
    /// @param _amount Amount of Tax.
    */
    function addPaymentOfEmigrationTax(address _cb, uint256 _amount)
        onlyForActiveCB(_cb)
        onlyByActiveMethod
        external returns (bool)
    {
        require(_amount > 0);
        weeklyEmigrationTaxPayments[_week()][_cb] += _amount;
        annualEmigrationTaxPayments[_year()][_cb] += _amount;
        return true;
    }
}

/*
/// @title Voting Management System is an `Extension` of `GRS` database.
/// Contains all global and regional data for Votings management.
*/
contract VMS is Extension {
    /*
    ///
    ////// Voting Management System
    ///
    */
    constructor (address _grs) public {
        assert(construction(_grs, bytes4("VMS")));
    }
}
