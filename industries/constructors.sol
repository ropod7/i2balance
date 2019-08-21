pragma solidity >=0.5.1 <0.6.0;

import "./CompanyStandard.sol";
import "../GRSystem.sol";
import "../common.sol";
import "../drivers/DriverStandard.sol";
import "../cb/CBStandard.sol";

/*
/// @title Common construction data handler of `PreCompany` and `Company` contracts.
*/
contract CompanyConstructor {
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
    ////// General data of `Company`
    ///
    */
    /*
    /// Central Bank address of `Company`. Can't be redefined. 
    /// Will be defining just once at the `PreDriver` construction */
    address public centralBank;
    /* The name of company. At this moment lets leave it unchengeable */
    bytes32 public companyName; 
    /* List of company owners */
    address[] public owners;
    /* `Company` owners ownership share (in public company should be public) */
    mapping (address => uint256) ownership;
    /* Company ownership leaved for public use in future */
    uint256 public publicNotInUseShare;

    /* Regional address of `Company` */
    struct PostalAddress {
        /* Address of property contract */
        address realEstate;
        /* Or postal address */
        bytes32 city;
        bytes32 street;
        uint256 postalCode;
        bytes32 homeNumber;
    }
    PostalAddress public postalAddress;
    
    /* Allowance only for active `GRS` `Method` */
    modifier onlyByActiveMethod() {
        require(grSystem.activeMethods(msg.sender));
            _;
    }
    
    /* Allowance only for trusted admins */
    modifier onlyByTrustedAdmins() {
        require(
            grSystem.activeMethods(msg.sender)  ||
            ownership[msg.sender] > 0
            );
                _;
    }
    
    function construction (
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
        ) 
        internal returns (bool) 
    {
        /* Just "one-off function"  */
        assert(grsAddr == address(0));
        require(_grs > address(0));
        grsAddr = _grs;
        grSystem = GRS(_grs);
        require(grSystem.activeCentralBank(_cb));
        /* Minimum 5 bytes of `Company` name */
        require(_name.length > 5);
        /* Check that `Company` name is unique */
        require(!CB(_cb).localCompanyNames(_name));
        require(_owners.length > 0);
        require(
            /* 
            /// Check that ownership list has the same lenght as list of owners
            /// to assign for each other. 
            */
            _owners.length == _ownership.length ||
            /*
            /// Or if leaved odd for future public use, odd will be assigned 
            /// to the special register named `publicNotInUseShare`
            */
            _owners.length == _ownership.length-1
        );
        /* Check all owners in list */
        for (uint i=0; i < _owners.length; i++) {
            require(
                /* Check that owner is active `Driver` */
                DMS(_grsExtension(bytes4("DMS"))).activeDrivers(_owners[i])   ||
                /* Or owner is active `Company` */
                CMS(_grsExtension(bytes4("CMS"))).activeCompanies(_owners[i])
            );
        }
        /* Check that total summ of percentages of array is 100% */
        require(_operator().summOfArrayElements(_ownership) == 1000);
        owners = _owners;
        for (uint i=0; i < _ownership.length; i++) {
            if (i < _owners.length)
                ownership[_owners[i]] = _ownership[i];
            else
                publicNotInUseShare = _ownership[i];
        }
        if (_realEstate > address(0)) {
            postalAddress.realEstate = _realEstate;
        } else if (
            _city.length > 0 && _street.length > 0     && 
            _postalCode > 0 && _homeNumber.length > 0
            )
        {
            postalAddress.city = _city;
            postalAddress.street = _street;
            postalAddress.postalCode = _postalCode;
            postalAddress.homeNumber = _homeNumber;
        } else {
            /* If nothing given */
            revert();
        }
        return true;
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
    /// @notice Gets the amount of percentages of `Company` ownership for given `Subject`.
    /// Can be got only by trusted admins.
    /// @param _owner (or one of owners) of the `Company`
    /// @return percentage of given user ownership
    */
    function getOwnership(address _owner)
        onlyByTrustedAdmins
        external view returns (uint256)
    {
        return ownership[_owner]; 
    }
    
    /*
    /// @notice Gets the number of `Company` owners.
    /// Can be got only by trusted admins.
    /// @return percentage of given user ownership
    */
    function getNumberOfOwners()
        onlyByTrustedAdmins
        external view returns (uint256)
    {
        return owners.length; 
    }
}
