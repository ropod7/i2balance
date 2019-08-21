pragma solidity ^0.5.0;

import "../common.sol";
import "./ProductStandard.sol";
import "./ProductTypeStandard.sol";
import "../GRSystem.sol";

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
