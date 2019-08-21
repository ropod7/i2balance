pragma solidity >=0.5.1 <0.6.0;

import "../CompanyStandard.sol";
import "../ProductTypeStandard.sol";
import "../../GRSystem.sol";
import "../../common.sol";
import "../../drivers/DriverStandard.sol";

/*
/// @dev The File contains operational objects of `Entity`
*/


/*
/// @title Common `Employee` contract contains all events of employee in all common cases.
*/
contract Employee {
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
    
    /*
    ///
    ////// constants of `Employee` contract
    ///
    */
    /* `Company` creator. */
    address public creator;
    /* Address of employee `Driver` contract */
    address employeeAddress;
    /* Address of `Employee` Ethereum account */
    address public owner;
    /* Object of employee `Driver` contract */
    Driver employee;
    /* Timestamp of employee registration */
    uint256 employeeFrom;
    /* Week of employee registration */
    uint256 employeeFromWeek;
    
    /*
    ///
    ////// Events management database
    ///
    */
    /* List of all timestamps of employee events */
    uint256[] eventsList;
    /* Signs of Employee global activity */
    enum EmployeeActivity {unknown, candidate, active, businessTrip, sickLeave, onLeave, inDismissal}
    /* Current activity of `Employee` */
    EmployeeActivity employeeActivity;
    /* Set the timestamp of registartion of employee current activity */
    uint256 employeeCurrentActivityFrom;
    /* Employee events register based on timestamps from `eventsList` */
    mapping (uint256 => EmployeeActivity) events;
    
    /*
    ///
    ////// `Employee` salary accounting system
    ///
    */
    /* All available salary rates per, or task-work */
    enum SalaryRatePer {hour, day, week, month, piecework}
    /* Projects Salary base data struct */
    struct ProjectSalary {
        SalaryRatePer salaryRatePer;
        uint256 salaryRate;
    }
    /* Salary rate per project in Economic currency */
    mapping (address => ProjectSalary) projectsSalary;
    
    /* `EmployeeProjectDiary` contracts for each `Project` */
    mapping (address => address) projectsDiaries;
    
    /* 
    /// Worked out cicles per which defined rate accounting:
    /// address of `Project` =>
    ////// week number =>
    ///////// worked out hours ||
    ///////// worked out days  ||
    ///////// etc.
    */
    mapping (address => mapping (uint256 => uint256)) workedOut;
    /* Payment amounts for `Project` based on workedOut logic */
    mapping (address => mapping (uint256 => uint256)) paid;
    /* Signs of full paiments for `Project` based on workedOut logic */
    mapping (address => mapping (uint256 => bool)) fullyPaid;
    
    /* Allowance only for active `GRS` `Method` */
    modifier onlyByActiveMethod() {
        require(grSystem.activeMethods(msg.sender));
            _;
    }
    
    /* Allowance to call only from `Company` contract */
    modifier onlyByEntity() {
        require(msg.sender == creator);
            _;
    }
    
    /* Allowance to call only from Trusted side */
    modifier getByTrusted() {
        require(
            /* `Company` contract */
            msg.sender == creator                       ||
            /* employee `Driver` contract */
            msg.sender == employeeAddress               ||
            /* Ethereum account of employee */
            msg.sender == employee.ethereumAccount()    ||
            /* Or active `GRS` `Method` */
            grSystem.activeMethods(msg.sender)
        );
            _;
    }
    
    /* Check current event not equals to given one */
    modifier checkEvent(EmployeeActivity _event) {
        assert(employeeActivity != _event);
            _;
    }
    
    function construction (address _grs, address _driver)
        internal returns (bool) 
    {
        require(_grs > address(0));
        require(DMS(_grsExtension(bytes4("DMS"))).activeDrivers(_driver));
        grsAddr = _grs;
        grSystem = GRS(_grs);
        /* Assign common constants first */
        creator = msg.sender;
        employeeAddress = _driver;
        owner = Driver(_driver).ethereumAccount();
        employee = Driver(_driver);
        employeeFrom = now;
        employeeFromWeek = _week(); 
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
    
    /*
    /// @notice Function aimed to get address of employee or address of `Driver` contract.
    /// @return Whether the transfer was successful or not
    */
    function getEmployeeAddress()
        getByTrusted
        external view returns (address)
    {
        return employeeAddress;
    }
    
    /*
    /// @notice Get the timestamp of employment has started.
    /// @return Whether the transfer was successful or not
    */
    function getEmployeeFrom()
        getByTrusted
        external view returns (uint256)
    {
        return employeeFrom;
    }
    
    /*
    /// @notice Internal Common function aimed to set `Employee` event to events list.
    /// @param _event Current activity of employee from `EmployeeActivity`
    /// @param _from Timestamp of given activity
    /// @return Whether the transfer was successful or not
    */
    function _setEvent(EmployeeActivity _event, uint256 _from)
        checkEvent(_event)
        internal returns (bool)
    {
        require(_from > 0);
        employeeActivity = _event;
        /* Set event for timestamp of employee registration */
        events[now] = _event;
        eventsList.push(now);
        return true;
    }
    
    /*
    /// @notice Common function aimed to set `Employee` event to events list.
    /// @param _event Current activity of employee from `EmployeeActivity`
    /// @param _from Timestamp of given activity
    /// @return Whether the transfer was successful or not
    */
    function setEvent(EmployeeActivity _event, uint256 _from)
        onlyByActiveMethod
        external returns (bool)
    {
        assert(_setEvent(_event, _from));
        return true;
    }
    
    /*
    /// @notice Get list of timestamps from events list.
    /// @return Array of timestamps
    */
    function getEventsList()
        getByTrusted
        external view returns (uint256[] memory)
    {
        return eventsList;
    }
    
    /*
    /// @notice Get list of timestamps from events list.
    /// @param _index Index from events list array.
    /// @return Indexed timestamp from events list.
    */
    function getTimestampFromEventsList(int256 _index)
        getByTrusted
        external view returns (uint256)
    {
        return _index >= 0 ? eventsList[uint(_index)] : eventsList[uint(int(eventsList.length) + _index)];
    }
    
    /*
    /// @notice Get event from events.
    /// @param _timestamp Timestamp of registerd event of activity.
    /// @return Registered activity from Company.EmployeesActivity enum.
    */
    function getEvent(uint256 _timestamp)
        getByTrusted
        external view returns (EmployeeActivity)
    {
        require(_timestamp > 0);
        return events[_timestamp];
    }
    
    /*
    /// @notice Returns current `Employee` activity.
    */
    function getEmployeeActivity()
        getByTrusted
        external view returns (EmployeeActivity)
    {
        return employeeActivity;
    }
    
    /*
    /// @notice Set the salary data for `Employee` in given `Project`.
    /// @param _project Address of `Project` contract.
    /// @param _ratePer Salary rate per given timeframe from SalaryRatePer list.
    /// @param _salary Amount of salary.
    /// @return Whether the transfer was successful or not
    */
    function setSalary(address _project, SalaryRatePer _ratePer, uint256 _salary)
        onlyByActiveMethod
        external returns (bool)
    {
        require(Project(_project).isEmployeeHasARole(address(this)));
        projectsSalary[_project].salaryRatePer = _ratePer;
        projectsSalary[_project].salaryRate = _salary;
        return true;
    }
    
    /*
    /// @notice Add worked out units to `Project`.
    /// @param _project Address of `Project` contract.
    /// @param _weekn Week number.
    /// @param _units Units from the `SalaryRatePer` enum.
    /// @return Whether the transfer was successful or not
    */
    function addToWorkedOutToProject(address _project, uint256 _weekn, uint256 _units)
        onlyByActiveMethod
        external returns (bool)
    {
        /* Check that project not yet done */
        require(!Project(_project).projectDone());
        workedOut[_project][_weekn] += _units;
        return true;
    }
    
    /*
    /// @notice Sign the payment for `Project`.
    /// @param _weekn Week number.
    /// @param _project Address of `Project` contract.
    /// @param _amount Amount in economic system currency.
    /// @return Whether the transfer was successful or not
    */
    function setPayment(address _project, uint256 _weekn, uint256 _amount)
        onlyByActiveMethod
        external returns (bool)
    {
        require(_weekn > 0);
        require(_amount > 0);
        assert(workedOut[_project][_weekn] > 0);
        assert(!fullyPaid[_project][_weekn]);
        uint needed = projectsSalary[_project].salaryRate * workedOut[_project][_weekn];
        paid[_project][_weekn] += _amount;
        if (needed <= _amount) {
            fullyPaid[_project][_weekn] = true;
        }
        return true;
    }
}

/*
/// @title `CompanyEmployee` contract contains all events of employee. Creates
/// on employee registration at `Company` contract side, 
/// see `Company._addToEmployee` and `Company.addCandidateToEmployee`.
*/
contract CompanyEmployee is Employee {
    
    /*
    ///
    ////// constants of `Employee` contract
    ///
    */
    /* `Company` object */
    Company company;
    
    constructor (address _grs, address _employee) public {
        assert(construction(_grs, _employee));
        /* Assign local constants first */
        company = Company(msg.sender);
        /* Assign current event */
        assert(_setEvent(EmployeeActivity.active, now));
    }
}

/*
/// @title Common `Project` contract contains all general data of any entity projects.
/// From projects have been created `Product` -> `ProductType` -> `Industry`
*/
contract Project {
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
    
    /*
    ///
    ////// Global management data of `Project`
    ///
    */
    /* Address of `Entity` of `Project` creator contract */
    address public creator;
    /* Address of entity `Product` and `Service` */
    address projectOfPoduct;
    /* Timestamp when `Project` has been created from `Entity` side */
    uint256 projectBegun;
    /* Global week number when `Project` has begun */
    uint256 projectBegunInWeek;
    /* `Project` accomplished or not. If `Project` accomplished can't add data to it */
    bool public projectDone;
    
    /*
    ///
    ////// `Project` hours accounting
    ///
    */
    /* How many hours went for `Project` accomplishment weekly */
    mapping (uint256 => uint256) weeklyHoursWent;
    /* How many hours went for `Project` accomplishment annual */
    mapping (uint256 => uint256) annualHoursWent;
    /* How many hours went for `Project` accomplishment total */
    uint256 totalHoursWent;
    
    /*
    ///
    ////// Employment in `Project`
    ///
    */
    /* List of employees in `Project` */
    address[] employees;
    /* List of types of roles in `Project` */
    enum Roles {unknown, engineer, creator, manager}
    /* Sign of role for each `Employee` */
    mapping (address => Roles) roleInProject;
    /* `EmployeeProjectDiary` for each `Employee` */
    mapping (address => address) projectDiaries;
    
    /* Allowance only for active `GRS` `Method` */
    modifier onlyByActiveMethod() {
        require(grSystem.activeMethods(msg.sender));
            _;
    }
    
    /* Allowance to call only from `Company` contract */
    modifier onlyByEntity() {
        require(msg.sender == creator);
            _;
    }
    
    /* Allowance to call just from trusted contracts */
    modifier getByTrusted() {
        require(
            msg.sender == creator                       ||
            roleInProject[msg.sender] != Roles.unknown  ||
            grSystem.activeMethods(msg.sender)
            );
                _;
    }
    
    /* Allowance to call just from trusted contracts or trusted service objects */
    modifier getByTrustedOrServiceObject() {
        require(
            msg.sender == creator                       ||
            roleInProject[msg.sender] != Roles.unknown  ||
            grSystem.activeMethods(msg.sender)
            );
                _;
    }
    
    /* Allowance to call only if `Project` not yet done */
    modifier projectInProcess() {
        assert(!projectDone);
            _;
    }
    
    /* Allowance to call just if `Employee` has a role in `Project` */
    modifier inProjectRole(address _employee) {
        assert(roleInProject[_employee] != Roles.unknown);
            _;
    }
    
    constructor (address _product) public {
        grsAddr = Company(msg.sender).grsAddr();
        grSystem = Company(msg.sender).grSystem();
        creator = msg.sender;
        projectBegun = now;
        projectBegunInWeek = _week();
        projectOfPoduct = _product;
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
    
    function getProjectOfPoduct()
        getByTrusted
        external view returns (address)
    {
        return projectOfPoduct;
    }
    
    function getProjectBegun()
        getByTrusted
        external view returns (uint256)
    {
        return projectBegun;
    }
    
    function getProjectBegunInWeek()
        getByTrusted
        external view returns (uint256)
    {
        return projectBegunInWeek;
    }
    
    function setProjectDone()
        onlyByActiveMethod
        projectInProcess
        external returns (bool)
    {
        projectDone = true;
        return true;
    }
    
    function addHours(uint256 _yearn, uint256 _weekn, uint256 _hours)
        onlyByActiveMethod
        projectInProcess
        external returns (bool)
    {
        require(_hours > 0);
        weeklyHoursWent[_weekn] += _hours;
        annualHoursWent[_yearn] += _hours;
        totalHoursWent += _hours;
        return true;
    }
    
    function setEmployee(address _employee, Roles _role)
        onlyByActiveMethod
        projectInProcess
        external returns (bool)
    {
        require(_employee > address(0));
        require(_role != Roles.unknown);
        employees.push(_employee);
        roleInProject[_employee] = _role; 
        return true;
    }
    
    function isEmployeeHasARole(address _employee)
        getByTrusted
        projectInProcess
        inProjectRole(_employee)
        external view returns (bool)
    {
        return true;
    }
    
    function getRoleOfEmployee(address _employee)
        getByTrustedOrServiceObject
        projectInProcess
        inProjectRole(_employee)
        external view returns (Roles)
    {
        return roleInProject[_employee];
    }
    
    function createDiary(address _manager, address _employee)
        onlyByActiveMethod
        projectInProcess
        external returns (bool)
    {
        require(roleInProject[_manager] == Roles.manager);
        require(roleInProject[_employee] != Roles.unknown);
        EmployeeProjectDiary diary = new EmployeeProjectDiary(
            Employee(_manager).owner(),
            _manager,
            creator,
            Employee(_employee).owner(),
            _employee,
            address(this)
        );
        projectDiaries[_employee] = address(diary);
        return true;
    }
}

/*
/// @title I2Balance Standard of Companys Product Contract.
*/
contract Product {
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
    /* Address of products owner */
    address public company;
    /* `ProductType` contract */
    ProductType public productType;
    /* Product ID defined by company */
    bytes16 public productID;
    /* Product price per `Industry` unit */
    uint256 public price;
    /* Address of specifications contract */
    address public specifications;
    /* Amount of sold total */
    uint256 public soldTotal;
    
    /* Allowance only for active `GRS` `Method` */
    modifier onlyByActiveMethod() {
        require(grSystem.activeMethods(msg.sender));
            _;
    }
    
    constructor (
            address _grs, // development argument
            address _type, 
            bytes16 _id, 
            uint256 _price, 
            address _spec
        ) public 
    {
        require(_grs > address(0));
        require(_type > address(0));
        require(_id.length > 0);
        require(_price > 0);
        require(_spec > address(0));
        grsAddr = _grs;
        grSystem = GRS(_grs);
        company = msg.sender;
        productType = ProductType(_type);
        productID = _id;
        price = _price;
        specifications = _spec;
    }
    
    /*
    /// @notice Opportunity to change product price
    /// @param _price New price of product.
    */
    function changePrice(uint256 _price) external returns (bool) {
        require(msg.sender == company);
        require(_price > 0);
        price = _price;
    }
    
    /*
    /// @notice Sets sales by the active method of GRS on the payment process
    /// @param _invoice Address of approved `Invoice` contract. 
    */
    function setSales(Invoice invoice)
        onlyByActiveMethod
        external returns (bool)
    {
        require(invoice.approved());
        require(!invoice.paid());
        uint256 amount = invoice.getSoldTotalOfProduct();
        require(amount > 0);
        soldTotal += amount;
        return true;
    }
}

/*
/// @title I2Balance Standard of Invoice Contract for companies,
/// except budget organizations. 
*/
contract Invoice {
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
    
    /* Sellers company / organization personal contract address */
    address seller;
    /* Sellers Central Bank address */
    address public centralBank;
    /* 
    /// Boolean sign of money flow direction.
    /// if `true` will flow to the seller, otherwise to the manufacturer.
    */
    bool public directToSeller;
    /* Sign of approved `Invoice` */
    bool public approved;
    /* Sign of paid `Invoice` */
    bool public paid;
    /* Buyers company / organization personal contract address */
    address buyer;
    /* Address of buyer `Industry` */
    address toIndustry;
    /* Cost total */
    uint256 total;
    /* 
    /// Sales Data: 
    */
    /* List of all products to purchase */
    Product[] products;
    address[] companies;
    /* Totals Payments to each `Company` */
    mapping (address => uint256) companiesTotals;
    /* Totals per `Product` */
    mapping (address => uint256) productsTotals;
    /* Totals per `ProductType` */
    mapping (address => uint256) typesTotals;
    /* Raised per `ProductType` */
    mapping (address => uint256) raisedByProductType;
    /* Totals per `Industry` */
    mapping (address => uint256) industriesTotals;
    /* Raised per `Industry` */
    mapping (address => uint256) raisedByIndustry;
    
    /* 
    /// Purchases Data: 
    */
    /* Purchased total by `Industry` purchased from */
    mapping (address => uint256) purchasedByIndustryTotal;
    
    /* Allowance to modify only by engagement sides */
    modifier onlyBySides() {
        require(msg.sender == seller || msg.sender == buyer);
            _;
    }
    
    /* Allowance to modify only by booked `Industry` contracts */
    modifier onlyByBookedIndustry() {
        require(industriesTotals[msg.sender] > 0);
            _;
    }
    
    /* Allowance only for active `GRS` `Method` */
    modifier onlyByActiveMethod() {
        require(grSystem.activeMethods(msg.sender));
            _;
    }
    
    constructor (address _grs, address _buyer, address _toIndustry, bool _direct) public {
        require(_grs > address(0));
        require(_buyer > address(0));
        require(_toIndustry > address(0));
        grsAddr = _grs;
        grSystem = GRS(_grs);
        seller = msg.sender;
        buyer = _buyer;
        centralBank = BaseContract(seller).centralBank();
        require(BaseContract(msg.sender).setInvoiceCreated());
        toIndustry = _toIndustry;
        directToSeller = _direct;
    }
    
    /*
    /// @notice Place an order method for each product.
    /// method predicts all needed data to be booked. 
    /// @param _product The address of the companies product contract
    /// @param _amount The amount of product to be shipped in Industry units
    /// @return Whether the transfer was successful or not
    */
    function placeOrder(Product product, uint256 _amount)
        onlyBySides
        external returns (bool)
    {
        assert(products.length < grSystem.productsLimit());
        assert(!approved);
        address productAddr = address(product);
        require(productAddr > address(0));
        require(_amount > 0);
        uint256 price = product.price();
        address pType = address(product.productType());
        address fromIndustry = address(ProductType(pType).industry());
        address company = product.company();
        require(price > 0);
        require(pType > address(0));
        require(fromIndustry > address(0));
        
        if (productsTotals[productAddr] == 0) {
            products.push(product);
        }
        if (!directToSeller && companiesTotals[company] == 0) {
            companies.push(company);
        }
        if (!directToSeller) {
            companiesTotals[company] += _amount * price;
        }
        productsTotals[productAddr] += _amount;
        typesTotals[pType] += _amount;
        industriesTotals[fromIndustry] += _amount;
        
        purchasedByIndustryTotal[fromIndustry] += _amount;
        
        uint256 costTotal = _amount * price;
        total += costTotal;
        raisedByProductType[pType] += costTotal;
        raisedByIndustry[fromIndustry] += costTotal;
        return true;
    }
    
    /*
    /// @notice Approve an order method for all ordered products.
    /// @return Whether the transfer was successful or not
    */
    function approveOrder() external returns (bool) {
        require(msg.sender == seller);
        assert(total > 0);
        assert(!approved);
        require(BaseContract(seller).setInvoiceApproved());
        approved = true;
        return approved;
    }
    
    /*
    /// @notice Set `Invoice` as paid.
    /// @return Whether the transfer was successful or not
    */
    function setPaid()
        onlyByActiveMethod
        external returns (bool)
    {
        assert(approved);
        assert(!paid);
        require(BaseContract(seller).setInvoicePaid());
        paid = true;
        return paid;
    }
    
    function getSeller() external view returns (address)
    {
        require(grSystem.activeMethods(msg.sender) || msg.sender == seller);
        return seller;
    }
    
    /*
    /// @notice Gets address of buyer
    */
    function getBuyer()
        onlyByActiveMethod
        external view returns (address)
    {
        return buyer;
    }
    
    /*
    /// @notice Gets addresses of sold products
    */
    function getProductsList()
        onlyByActiveMethod
        external view returns (Product[] memory)
    {
        return products;
    }
    
    /*
    /// @notice Gets cost of all purchased products.
    */
    function getCostTotal()
        onlyByActiveMethod
        external view returns (uint256)
    {
        return total;
    }
    
    /*
    /// @notice Get sold total of `Product`.
    /// @return amount of sold total.
    */
    function getSoldTotalOfProduct() external view returns (uint256) {
        return productsTotals[msg.sender];
    }
    
    /*
    /// @notice Get sold total from `Product`.
    /// @return amount of sold total.
    */
    function getSoldTotalOfProductType() external view returns (uint256) {
        return typesTotals[msg.sender];
    }
    
    /*
    /// @notice Get amount of money total raised by `Industry`.
    /// @return amount of money raised total.
    */
    function getRaisedTotalByProductType() external view returns (uint256) {
        return raisedByProductType[msg.sender];
    }
    
    /*
    /// @notice Get sold total from `Industry`.
    /// @return amount of sold total.
    */
    function getSoldTotalFromIndustry() external view returns (uint256) {
        return industriesTotals[msg.sender];
    }
    
    /*
    /// @notice Get amount of money total raised by `Industry`.
    /// @return amount of money raised total.
    */
    function getRaisedTotalByIndustry() external view returns (uint256) {
        return raisedByIndustry[msg.sender];
    }
    
    /*
    /// @notice Get buyers CB address. Only for booked `Industry`.
    /// @return address of buyer CB.
    */
    function getBuyerCB()
        onlyByBookedIndustry
        external view returns (address) 
    {
        return BaseContract(buyer).centralBank();
    }
    
    /*
    /// @notice Get amount of products purchased buyer 
    /// `Industry` from each booked `Industry`.
    /// @return amount of purchased total.
    */
    function getPurchasedByIndustryTotal(address _industry) external view returns (uint256) {
        require(msg.sender == toIndustry);
        require(_industry > address(0));
        return purchasedByIndustryTotal[_industry];
    }
}
