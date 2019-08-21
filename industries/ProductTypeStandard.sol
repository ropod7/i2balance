pragma solidity ^0.5.0;
import "../common.sol";
import "./IndustryStandard.sol";
import "../GRSystem.sol";
import "./objects/serviceObjects.sol";
import "./objects/operationalObjects.sol";

/*
/// @title I2Balance Standard of Industry Product Type Contract.
*/
contract ProductType {
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
    /* `Industry` type of contract */
    Industry public industry;
    /*
    /// @notice ID of product type.
    /// eg. "SWP-0010", or "PWP-0230", "HWP-1010", "RGP-0050", "SVP-2059" etc.
    */
    bytes8 public typeID;
    /* 
    /// @notice Total Sales of `ProductType` per 1 week from new Epoch.
    /// Week Nr. => Amount.
    */
    mapping (uint256 => uint256) public weeklySoldTotal;
    /* Weekly money raised by `ProductType` */
    mapping (uint256 => uint256) public weeklyRaisedTotal;
    /* Total money raised */
    uint256 public raisedTotal;
    
    /* Allowance only for active `GRS` `Method` */
    modifier onlyByActiveMethod() {
        require(grSystem.activeMethods(msg.sender));
            _;
    }
    
    constructor (address _grs, address _industry, bytes8 _id) public {
        require(_grs > address(0));
        require(_industry > address(0));
        require(_id.length == 8);
        grsAddr = _grs;
        grSystem = GRS(_grs);
        industry = Industry(_industry);
        typeID = _id;
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
        uint256 amount = invoice.getSoldTotalOfProductType();
        uint256 raised = invoice.getRaisedTotalByProductType();
        require(amount > 0);
        uint256 week = grSystem.week();
        weeklySoldTotal[week] += amount;
        weeklyRaisedTotal[week] += raised;
        return true;
    }
}
