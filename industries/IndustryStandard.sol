pragma solidity ^0.5.0;
//import "../common.sol";
import "../GRSystem.sol";
import "./objects/serviceObjects.sol";
import "./objects/operationalObjects.sol";

/*
/// @title I2Balance Standard of Common Industry Contract
*/
contract Industry {
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
    /* `Industry` Central Bank address */
    address public centralBank;
    /*
    /// @notice ID of industry.
    /// eg. "SW-001", or "PW-023", "HW-101", "RG-005", "SV-205" etc.
    */
    bytes6 public industryID;
    /*
    /// @notice Units of `Industry` to count.
    /// eg. "Pcs", "Kg", "Tonn", "kW/h", "Hrs" etc.
    */
    bytes4 public units;
    /* Decimals of units */
    uint8 public constant decimals = 4;
    /* 
    /// @notice Is `Industry` included into SW block or its regional.
    /// Depends from CB Contract address. 
    */
    bool public isSW;
    /* Economic cycle of `Industry` in years */
    uint256 public economicCycle;
    /* 
    /// @notice Total Sales of `Industry` per 1 week from new Epoch.
    /// Week Nr. => CB => Amount.
    */
    mapping (uint256 => mapping (address => uint256)) public weeklySoldTotal;
    /* Weekly money raised by `Industry` */
    mapping (uint256 => uint256) public weeklyRaisedTotal;
    /* Total money raised */
    uint256 public raisedTotal;
    
    /* Total Internal regional, or SW sales */
    uint256 public intSoldTotal;
    /* Total export sales */
    uint256 public expSoldTotal;
    /* Total global sales to the SW block. Only if `Industry` not in SW block */
    uint256 public glbSoldTotal;
    /*
    /// @notice Total purchases of `Industry` per 1 week from new Epoch.
    /// Week Nr => CB purcased from => `Industry` purchased from => Amount
    */
    mapping (uint256 => mapping (address => mapping (address => uint256))) public weeklyPurchasedTotal;
    
    /* Allowance only for active `GRS` `Method` */
    modifier onlyByActiveMethod() {
        require(grSystem.activeMethods(msg.sender));
            _;
    }
    
    constructor (
            address _grs, // development argument
            address _cb, 
            bytes6 _id, 
            bytes4 _units, 
            uint256 _eCycle
        ) public 
    {
        require(_grs > address(0));
        require(_cb > address(0));
        require(_id.length == 6);
        require(_units.length > 0);
        require(_eCycle > 0);
        grsAddr = _grs;
        grSystem = GRS(_grs);
        centralBank = _cb;
        if (_cb == grsAddr)
            isSW = true;
        industryID = _id;
        units = _units;
        economicCycle = _eCycle;
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
        uint256 sold = invoice.getSoldTotalFromIndustry();
        uint256 raised = invoice.getRaisedTotalByIndustry();
        address cb = invoice.getBuyerCB();
        uint256 week = grSystem.week();
        require(sold > 0);
        require(cb > address(0));
        weeklySoldTotal[week][cb] += sold;
        if (cb == centralBank) {
            intSoldTotal += sold;
        } else if (cb == grsAddr && centralBank != grsAddr) {
            glbSoldTotal += sold;
        }
        else {
            expSoldTotal += sold;
        }
        weeklyRaisedTotal[week] += raised;
        raisedTotal += raised;
        return true;
    }
    
    /*
    /// @notice Sets purchases from each region and industry.
    /// @param _invoice Address of approved `Invoice` contract.
    /// @param _industry Address of `Industry` purchased from.
    */
    function setPurchases(Invoice invoice, address _industry)
        onlyByActiveMethod
        external returns (bool)
    {
        require(_industry > address(0));
        require(invoice.approved());
        require(!invoice.paid());
        Industry industry = Industry(_industry);
        uint256 week = grSystem.week();
        address fromIndustryCB = industry.centralBank();
        
        uint256 amount = invoice.getPurchasedByIndustryTotal(_industry);
        weeklyPurchasedTotal[week][fromIndustryCB][_industry] += amount;
        return true;
    }
}
