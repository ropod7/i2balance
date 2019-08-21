pragma solidity >=0.5.1 <0.6.0;

import "../common.sol";
import "../GRSystem.sol";
import "./method.sol";
import "../drivers/DriverStandard.sol";
import "../cb/CBStandard.sol";
import "../industries/CompanyStandard.sol";
import "../industries/objects/serviceObjects.sol";
import "../drivers/serviceObjects.sol";

contract SCMethod is MethodMaker {
    
    function construction(address _grs, bytes32 _name)
        internal returns (bool)
    {
        assert(baseConstructor(_grs, _name));
        return true;
    }
}

/*
/// @title Creator of `Driver` contract using preregistered construction data
/// from `PreDriver` contract. Aimed to be as cover for secure `Driver` contract 
/// creation and exclude manipulations with `Driver` contract source code body.
/// Allowed to call just from `GRS`.
/// @param _subject Address of registered `PreDriver` contract.
/// @param _sender Address of `PreDriver` creator.
*/
contract CreateDriverContract is SCMethod {

    address public dmsAddr;
    DMS public dmSystem;

    constructor (address _grs) public {
        assert(baseConstructor(_grs, bytes32("CreateDriverContract")));
        dmsAddr = grSystem.extensions(bytes4("DMS"));
        assert(dmsAddr > address(0));
        dmSystem = DMS(dmsAddr);
    }
    
    function make(uint256 _subject, address payable _sender, uint256 _value)
        onlyByGRS
        zeroValue(_value)
        subjectAsAddress(_subject)
        external returns (bool)
    {
        PreDriver preDriver = PreDriver(address(_subject));
        /* On the basis of `PreDriver` contract should be created contract of `Driver` */
        require(
            preDriver.creator() == _sender                              || 
            preDriver.creator() == Driver(_sender).ethereumAccount()
            );
        Driver driver = new Driver(
            grsAddr,
            preDriver.getFirstName(),
            preDriver.getLastName(),
            preDriver.gender(),
            preDriver.getBirthTimestamp(),
            preDriver.getOlderTimestamp(),
            preDriver.getBirthCoordinates(),
            preDriver.birthWeek(),
            version
        );
        grSystem.setCreatedByMethod(address(driver));
        dmSystem.setPreDriverAsUsed(address(preDriver));
        return true;
    }
}

/*
/// @title Creator of `CB` contract using preregistered construction data
/// from `PreCentralBank` contract. Aimed to be as cover for secure `CB` contract 
/// creation and exclude manipulations with `CB` contract source code body.
/// Allowed to call just from `GRS`.
/// @param _subject Address of registered `PreCentralBank` contract.
/// @param _sender Address of `PreCentralBank` creator.
*/
contract CreateCentralBankContract is SCMethod {

    address public cbmsAddr;
    CBMS public cbmSystem;
    
    constructor (address _grs) public {
        assert(baseConstructor(_grs, bytes32("CreateCentralBankContract")));
        cbmsAddr = grSystem.extensions(bytes4("CBMS"));
        assert(cbmsAddr > address(0));
        cbmSystem = CBMS(cbmsAddr);
    }
    
    function make(uint256 _subject, address payable _sender, uint256 _value)
        onlyByGRS
        zeroValue(_value)
        subjectAsAddress(_subject)
        external returns (bool)
    {
        PreCentralBank preCB = PreCentralBank(address(_subject));
        require(preCB.creator() == _sender);
        CB cb = new CB(
            grsAddr,
            preCB.adultAge(),
            preCB.allowedSecondParentAge(),
            preCB.incomeTax(),
            preCB.generalTax(),
            preCB.subsidyTax(),
            preCB.upgradeTax(),
            preCB.extraTax(),
            preCB.contourTax(),
            preCB.cicleInWeeksForLoanRepaymentAmount(),
            preCB.numberOfCiclesForLoanRepaymentAmount(),
            preCB.percentageFromTurnoverForLoanRepaymentAmount(),
            version
        );
        grSystem.setCreatedByMethod(address(cb));
        cbmSystem.setPreCentralBankAsUsed(address(preCB));
        return true;
    }
}

contract SignToPreCompanyContract is SCMethod {
    address public cmsAddr;
    CMS public cmSystem;
    
    constructor (address _grs) public {
        assert(baseConstructor(_grs, bytes32("SignToPreCompanyContract")));
        cmsAddr = grSystem.extensions(bytes4("CMS"));
        assert(cmsAddr > address(0));
        cmSystem = CMS(cmsAddr);
    }
    
    function make(uint256 _subject, address payable _sender, uint256 _value)
        onlyByGRS
        zeroValue(_value)
        subjectAsAddress(_subject)
        external returns (bool)
    {
        PreCompany preCompany = PreCompany(_subject);
        /* Double check all lists and variables */
        require(preCompany.getNumberOfOwners() > 1);
        require(!preCompany.ownersSigns(_sender));
        require(preCompany.getOwnership(_sender) > 0);
        /* Register sign to owner */
        require(preCompany.setOwnerSign(_sender));
        return true;
    }
}
