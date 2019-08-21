pragma solidity ^0.5.0;
import "../common.sol";
import "./InvoiceStandard.sol";
import "./ProductTypeStandard.sol";
import "./CompanyStandard.sol";
import "../GRSystem.sol";

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
