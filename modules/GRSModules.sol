pragma solidity >=0.5.1 <0.6.0;

import "../common.sol";
//import "industries/ProductTypeStandard.sol";
//import "industries/IndustryStandard.sol";
import "../cb/CBStandard.sol";
import "../GRSystem.sol";
import "./method.sol";
import "../industries/objects/serviceObjects.sol";
import "../industries/objects/operationalObjects.sol";

/*
/// @title Send funds from owner contract to owner account.
/// Allowed to call just from `GRS`.
/// @param _subject Amount of funds to transfer from sender contract to sender account.
/// @param _sender Account of funds owner.
*/
contract SendEtherToAccount is MethodMaker {

    constructor (address _grs) public {
        assert(baseConstructor(_grs, bytes32("SendEtherToAccount")));
    }

    function make(address _object, address payable _sender, uint256 _value)
        onlyByGRS
        external returns (bool)
    {
        require(_value > 0);
        require(_object > address(0));
        require(grSystem.getTokenBalance(_sender) > 0);
    }
}

/*
/// @title Ether Withdrawal `Method`.
/// Allowed to call just from `GRS`.
/// @param _subject Amount of Ether to withdraw from account to contract.
/// @param _sender Account of Ether owner.
*/
contract EtherWithdrawal is MethodMaker {

    constructor (address _grs) public {
        assert(baseConstructor(_grs, bytes32("EtherWithdrawal")));
    }

    function make(uint256 _subject, address payable _sender, uint256 _value)
        onlyByGRS
        zeroValue(_value)
        external returns (bool)
    {
        require(grSystem.withdrawEther(_sender, _subject));
        return true;
    }
}

/*
/// @title End-to-End transaction `Method` making by sender and by `Invoice`.
/// Allowed to call just from `GRS`.
/// @param _subject Amount of funds to transfer from sender contract to recipient account.
/// @param _sender Account of funds owner.

contract E2E1stTxByInvoice is MethodMaker {

    constructor (address _grs) public {
        assert(baseConstructor(_grs, bytes32("E2E1stTxByInvoice")));
    }

    function make(uint256 _subject, address payable _sender, uint256 _value)
        onlyByGRS
        subjectAsAddress(_subject)
        external returns (bool)
    {
        require(_value > 0);
        require(grSystem.getTokenBalance(_sender) > 0);
    }
}
*/
/*
/// @title Direct transaction `Method` making by sender and by `Invoice`.
/// Allowed to call just from `GRS`.
/// @param _subject Amount of funds to transfer from sender account to recipient account.
/// @param _sender Account of funds owner.
*/
contract DirectTxByInvoice is MethodMaker {

    constructor (address _grs) public {
        assert(baseConstructor(_grs, bytes32("DirectTxByInvoice")));
    }

    function make(uint256 _subject, address payable _sender, uint256 _value)
        onlyByGRS
        subjectAsAddress(_subject)
        zeroValue(_value)
        external returns (bool)
    {
        Invoice invoice = Invoice(address(_subject));
        require(invoice.getBuyer() == _sender);
        uint256 eth = grSystem.getEtherBalance(_sender);
        uint256 tok = grSystem.getTokenBalance(_sender);
        uint256 total = invoice.getCostTotal();

        uint256 holding = eth + tok;
        require(holding > total);
        uint8 len = uint8(invoice.getProductsList().length);
        Product[] memory products = invoice.getProductsList();
        for (uint8 i=0; i<len; i++) {
            Product product = products[i];
            product.setSales(invoice);
            product.productType().setSales(invoice);
            product.productType().industry().setSales(invoice);
            if (!invoice.directToSeller()) {
                /// make Tx for each product
            }
        }
    }
}

/*
/// @title Conversion Depth computation mechanism for Direct transactions.
/// In case of computation of max tokens from total tx amount of funds. 
/// Allowed to call just from `GRS`.
/// @param _subject[](1) Amount of funds to be converted.
/// @param _sender Account of funds owner.
/// @return Amount of Ether from total amount.
*/
contract DirectConversionDepthMaxTokens is MethodGetter {

    constructor (address _grs) public {
        assert(baseConstructor(_grs, bytes32("DirectConversionDepthMaxTokens")));
    }

    function get(uint256 _subject, address _sender)
        onlyByGRS
        external view returns (uint256)
    {
        uint256 tokenAmount = grSystem.getTokenBalance(_sender);
        uint256 amount = _subject;
        assert(amount > 0);
        /* Double check that total amount is enough */
        require(_operator().amountIsEnough(_sender, amount));
        /* Send rest in Ether only if amount of tokens not enough */
        return tokenAmount >= amount ? 0 : amount - tokenAmount;
    }
}

/*
/// @title Conversion Depth computation mechanism for Direct transactions.
/// In case of computation of max Ether from total tx amount of funds. 
/// Allowed to call just from `GRS`.
/// @param _subject[](1) Amount of funds to be converted.
/// @param _sender Account of funds owner.
/// @return amount of Tokens from total amount.
*/
contract DirectConversionDepthMaxEther is MethodGetter {

    constructor (address _grs) public {
        assert(baseConstructor(_grs, bytes32("DirectConversionDepthMaxEther")));
    }

    function get(uint256 _subject, address _sender)
        onlyByGRS
        external view returns (uint256)
    {
        uint256 etherAmount = grSystem.getEtherBalance(_sender);
        uint256 amount = _subject;
        assert(amount > 0);
        /* Double check that total amount is enough */
        require(_operator().amountIsEnough(_sender, amount));
        /* Send rest in Ether only if amount of tokens not enough */
        return etherAmount >= amount ? 0 : amount - etherAmount;
    }
}

/*
/// @title Conversion Depth computation mechanism for End-to-End transactions.
/// In case of computation of max tokens from total tx amount of funds. 
/// Allowed to call just from `GRS`.
/// @param _subject[](1) Amount of funds to be converted.
/// @param _sender Account of funds owner.
/// @return Amount of Ether from total amount.
*/
contract E2E1stConversionDepthMaxTokens is MethodGetter {

    constructor (address _grs) public {
        assert(baseConstructor(_grs, bytes32("E2E1stConversionDepthMaxTokens")));
    }

    function get(uint256 _subject, address _sender)
        onlyByGRS
        external view returns (uint256)
    {
        /* Check that sender is not `CB` */
        require(!CBMS(_extension(bytes4("CBMS"))).allCentralBanks(_sender));
        uint tokenAmount = grSystem.getTokenBalance(_sender);
        uint amount = _subject;
        assert(amount > 0);
        /* Double check that total amount is enough */
        require(_operator().E2EAmountIsEnough(_sender, amount));
        /* Send rest in Ether only if amount of tokens not enough */
        return tokenAmount >= amount ? 0 : amount - tokenAmount;
    }
}

/*
/// @title `Method` of Creation of Credit Tokens.
/// Allowed to call just from `GRS`.
/// Allowed to create just if `CB` or `GRS` not have requested amount.
/// @param _subject Amount of tokens to create.
/// @param _sender Account of `CB` or `GRS` contract.
*/
contract CreateCreditTokens is MethodMaker {

    constructor (address _grs) public {
        assert(baseConstructor(_grs, bytes32("CreateCreditTokens")));
    }

    function make(uint256 _subject, address payable _sender, uint256 _value)
        onlyByGRS
        zeroValue(_value)
        external returns (bool)
    {
        uint amount = _subject;
        /* Check that sender is real and active `CB` */
        require(CBMS(_extension(bytes4("CBMS"))).activeCentralBanks(_sender));
        /* If calling from `GRS`, will skip this step */
        if (_sender != grsAddr) {
            /* Before token creation check that `CB` funds not enough for amount */
            require(!_operator().amountIsEnough(_sender, amount));
        }
        /* Before token creation check that `GRS` funds not enough for amount */
        require(!_operator().amountIsEnough(grsAddr, amount));
        require(grSystem.createTokens(amount));
        return true;
    }
}

/*
/// @title The request for loan for `CB` `Method`.
/// Allowed to call just from `GRS`.
/// Allowed to create just for active `CB`.
/// @param _subject Amount of tokens to request.
/// @param _sender Address of `CB` contract.
*/
contract MakeRequestForLoanForCB is MethodMaker {

    constructor (address _grs) public {
        assert(baseConstructor(_grs, bytes32("MakeRequestForLoanForCB")));
    }

    function make(uint256 _subject, address payable _sender, uint256 _value)
        onlyByGRS
        zeroValue(_value)
        external returns (bool)
    {
        uint amount = _subject;
        /*
        /// Before token creation check that `GRS` funds maybe enough for amount
        /// otherwise create credit tokens.
        */
        if (!_operator().amountIsEnough(grsAddr, amount)) {
            Subject(_sender).make(bytes32("CreateCreditTokens"), _subject);
        }
        uint tokens = Subject(grsAddr).get(bytes32("DirectConversionDepthMaxEther"), amount);
        require(grSystem.sendEther(grsAddr, _sender, amount - tokens));
        if (tokens > 0)
            require(grSystem.sendTokens(grsAddr, _sender, tokens));
        require(grSystem.addLoanOfCentralBank(_sender, amount));
        return true;
    }
}

/*
/// @title The repayment of loan for `CB` `Method`.
/// Allowed to call just from `GRS`.
/// Allowed to create just for active `CB`.
/// @param _subject Amount of repayment.
/// @param _sender Address of `CB` contract.
*/
contract MakeRepaymentOfLoanForCB is MethodMaker {

    constructor (address _grs) public {
        assert(baseConstructor(_grs, bytes32("MakeRepaymentOfLoanForCB")));
    }

    function make(uint256 _subject, address payable _sender, uint256 _value)
        onlyByGRS
        zeroValue(_value)
        external returns (bool)
    {
        uint amount = _subject;
        require(_operator().amountIsEnough(_sender, amount));
        require(grSystem.deductLoanOfCentralBank(_sender, amount));
        return true;
    }
}

/*
/// @title The getter of total interest of private bank deposit.
/// Allowed to call just from `GRS`.
/// Allowed to make request just for active `Driver`.
/// @param _subject[](1) Empty.
/// @param _sender Address of `CB` contract.
/// @return total Percentage of all years from last update of bank deposit.
*/
contract GetTotalInterestOfBankDeposit is MethodGetter {

    constructor (address _grs) public {
        assert(baseConstructor(_grs, bytes32("GetTotalInterestOfBankDeposit")));
    }

    function get(address _object, address _sender)
        onlyByGRS
        zeroObject(_object)
        external view returns (uint256)
    {
        uint depositedTime = grSystem.getTimeOfPrivateBankDeposit(_sender);
        uint8 privateInterest = grSystem.getBankDepositPrivateInterest(_sender);
        uint8 globalInterest = grSystem.interestsOnBankDeposits(_operator().getCentralBankByEntity(_sender));
        uint rest = now - depositedTime;
        uint oddYear;
        uint fullYears;
        (fullYears, oddYear) = _operator().getNumberOfCiclesLeft(rest, 365 days);
        /*
        /// if the installment interest rate on deposits exceeds the current
        /// interest rate on deposits of the `CB, then winnings are returned
        /// for the last year only (Needed single redifinition of deposit).
        */
        if (fullYears > 0 && privateInterest > globalInterest)
            return privateInterest;
        uint cicles;
        if (oddYear > 0) {
            uint oddWeeks;
            (cicles, oddWeeks) = _operator().getNumberOfCiclesLeft(oddYear, 60 days);
            if (oddWeeks > 0)
                cicles++;
        }
        /* if just at first 60 days making tx, will return 0 interest rate */
        return privateInterest / 6 * cicles + fullYears * privateInterest;
    }
}

/*
/// @title The `Method` which updates amount of private bank deposit.
/// Allowed to call just from `GRS`.
/// Allowed to add just for active `Driver`.
/// @param _subject Amount of bank deposit to add.
/// @param _sender Address of `Driver` contract.
*/
contract AddAmountOfBankDeposit is MethodMaker {

    constructor (address _grs) public {
        assert(baseConstructor(_grs, bytes32("AddAmountOfBankDeposit")));
    }

    function make(address _object, address payable _sender, uint256 _value)
        onlyByGRS
        onlyRigidAmount(_object)
        zeroValue(_value)
        external returns (bool)
    {
        uint subject = uint(_object);
        uint amount = grSystem.getBankDepositPrivateAmount(_sender);
        address cb = _operator().getCentralBankByEntity(_sender);
        uint rate;
        assert(cb > address(0));
        if (amount > 0) {
            uint interest = Subject(_sender).get(bytes32("GetTotalInterestOfBankDeposit"), 0);
            assert(interest > 0);
            rate = _operator().getPercentageFromNumber(amount, interest);
            amount += rate;
            /* Set up even total amount divisible by 1000 */
            uint odd = (amount + subject) % cent;
            if (odd > 0)
                subject -= odd;
            amount += subject;
            /* Set interest on bank deposit as paid */
            require(grSystem.setPaydBankDepositInterest(cb, rate));
        } else {
            amount = subject;
            /* Check that amount more than or equals to min value of BD of `CB` */
            assert(amount >= grSystem.bankDepositMinValues(cb));
        }
        /* Before `DirectConversionDepthMaxTokens` module call check funds enough for amount */
        require(_operator().amountIsEnough(_sender, subject));
        uint eth = Subject(_sender).get(bytes32("DirectConversionDepthMaxTokens"), subject);
        require(grSystem.sendTokens(_sender, cb, subject - eth));
        if (eth > 0)
            require(grSystem.sendEther(_sender, cb, eth));
        /* Add bank deposit to `CB` */
        require(grSystem.addBankDeposit(cb, subject + rate));
        require(grSystem.setPrivateAmountOfBankDeposit(_sender, amount));
        return true;
    }
}

/*
/// @title The `Method` which makes request of any amount from private bank deposit.
/// Allowed to call just from `GRS`.
/// Allowed to make request just for active `Driver`.
/// @param _subject Amount to deduct from bank deposit.
/// @param _sender Address of `Driver` contract.
*/
contract GetAmountFromBankDeposit is MethodMaker {

    constructor (address _grs) public {
        assert(baseConstructor(_grs, bytes32("GetAmountFromBankDeposit")));
    }

    function make(uint256 _subject, address payable _sender, uint256 _value)
        onlyByGRS
        zeroValue(_value)
        external returns (bool)
    {
        /* Allowed to withdraw only at first 30 days of year */
        require(_operator().getAverageMonthOfYear() == 1);
        uint256 subject = _subject;
        uint amount = grSystem.getBankDepositPrivateAmount(_sender);
        address cb = _operator().getCentralBankByEntity(_sender);
        uint interest = Subject(_sender).get(bytes32("GetTotalInterestOfBankDeposit"), 0);
        /* Allowed to get amount after 2 first month only */
        assert(interest > 0);
        uint rate = _operator().getPercentageFromNumber(amount, interest);
        amount += rate;
        assert(amount >= subject);
        /* Amount that should be registered at the Bank Deposit side */
        amount -= subject;
        /* Set up even total amount divisible by 1000 */
        uint odd = amount % cent;
        if (odd > 0) {
            subject += odd;
            amount -= odd;
        }
        /* Check that NEW amount more than or equals to min value of BD of `CB` */
        assert(amount >= grSystem.bankDepositMinValues(cb));
        if (subject <= rate) {
            /* Set interest on bank deposit as paid */
            require(grSystem.setPaydBankDepositInterest(cb, subject));
        } else {
            /* Set interest on bank deposit as paid */
            require(grSystem.setPaydBankDepositInterest(cb, rate));
            /* Deduct bank deposit from `CB` */
            require(grSystem.deductBankDeposit(cb, subject - rate));
        }
        /*
        /// Before `DirectConversionDepthMaxEther` module call check `CB` funds is enough for amount.
        /// Otherwise make request for a Loan for `CB` from `GRS` side.
        */
        if (!_operator().amountIsEnough(cb, subject)) {
            Subject(cb).make(bytes32("MakeRequestForLoanForCB"), subject);
        }
        uint tokens = Subject(cb).get(bytes32("DirectConversionDepthMaxEther"), subject);
        require(grSystem.sendEther(cb, _sender, subject - tokens));
        if (tokens > 0)
            require(grSystem.sendTokens(cb, _sender, tokens));
        require(grSystem.setPrivateAmountOfBankDeposit(_sender, amount));
        return true;
    }
}

/*
/// @title The `Method` which withdraws total amount from private bank deposit.
/// Withdraws to `Driver` account.
/// Allowed to call just from `GRS`.
/// Allowed to make request just for active `Driver`.
/// @param _subject Must be a zero.
/// @param _sender Address of `Driver` contract.
*/
contract WithdrawBankDeposit is MethodMaker {

    constructor (address _grs) public {
        assert(baseConstructor(_grs, bytes32("WithdrawBankDeposit")));
    }

    function make(address _object, address payable _sender, uint256 _value)
        onlyByGRS
        zeroValue(_value)
        zeroObject(_object)
        external returns (bool)
    {
        /* Allowed to withdraw only at first 30 days of year */
        require(_operator().getAverageMonthOfYear() == 1);
        uint amount = grSystem.getBankDepositPrivateAmount(_sender);
        address cb = _operator().getCentralBankByEntity(_sender);
        uint interest = Subject(_sender).get(bytes32("GetTotalInterestOfBankDeposit"), 0);
        /* If once registered, should be withdrawed only after 60 days */
        assert(interest > 0);
        uint rate = _operator().getPercentageFromNumber(amount, interest);
        /* Set interest on bank deposit as paid */
        require(grSystem.setPaydBankDepositInterest(cb, rate));
        /* Deduct bank deposit from `CB` */
        require(grSystem.deductBankDeposit(cb, amount));
        amount += rate;
        /*
        /// Before `DirectConversionDepthMaxEther` module call check `CB` funds is enough for amount.
        /// Otherwise make request for a Loan for `CB` from `GRS` side.
        */
        if (!_operator().amountIsEnough(cb, amount)) {
            Subject(cb).make(bytes32("MakeRequestForLoanForCB"), amount);
        }
        uint tokens = Subject(cb).get(bytes32("DirectConversionDepthMaxEther"), amount);
        require(grSystem.sendEther(cb, _sender, amount - tokens));
        if (tokens > 0)
            require(grSystem.sendTokens(cb, _sender, tokens));
        require(grSystem.setPrivateAmountOfBankDeposit(_sender, 0));
        return true;
    }
}

/*
/// @title The `Method` which makes request of maximal loan amount for any entity.
/// `Method` makes computations of last 3 annual turnovers in arithmetic mean.
/// Allowed to call just from `GRS`.
/// Allowed to make request just for any active entity.
/// @param _subject[](1) Empty.
/// @param _sender Address of any entity contract.
/// @return Maximal loan amount for entity.
*/
contract GetMaxLoanAmountForEntity is MethodGetter {

    constructor (address _grs) public {
        assert(baseConstructor(_grs, bytes32("GetMaxLoanAmountForEntity")));
    }

    function get(address _object, address _sender)
        onlyByGRS
        zeroObject(_object)
        external view returns (uint256)
    {
        address cb = _operator().getCentralBankByEntity(_sender);
        uint8 maxAnnuals = grSystem.maxAnnualTurnoversForLoanForRegions(cb);
        uint turnover;
        /* Get summ of amounts of turnover for last full 3 annual periods */
        for (uint i = 1; i <= 3; i++) {
            turnover += CB(cb).getAnnualTurnover(_year() - i, _sender);
        }
        /* Get average turnover for last 3 years */
        turnover = _operator().removeOddFromNumber(turnover, 3);
        /* Return average multiplied by max annual turnovers */
        return turnover > 0 ? turnover / 3 * maxAnnuals : 0;
    }
}

/*
/// @title The `Method` which makes request of rest of loan from last loan update.
/// Allowed to call just from `GRS`.
/// Allowed to make request just for any active entity.
/// @param _subject[](1) Empty.
/// @param _sender Address of any entity contract.
/// @return Rest of loan.
/// 
*/
contract GetRestOfLoanOfEntity is MethodGetter {

    constructor (address _grs) public {
        assert(baseConstructor(_grs, bytes32("GetRestOfLoanOfEntity")));
    }

    function get(address _object, address _sender)
        onlyByGRS
        zeroObject(_object)
        external view returns (uint256)
    {
        uint oddYear;
        uint cicles;
        (cicles, oddYear) = _operator().getNumberOfCiclesLeft(grSystem.getLoanTimestamp(_sender), 365 days);
        if (oddYear > 0)
            cicles++;
        uint totalRate = grSystem.getLoanRepaymentRate(_sender) * cicles;
        uint amount = grSystem.getLoanAmount(_sender);
        uint repayments = grSystem.getLoanRepayments(_sender);
        amount += _operator().getPercentageFromNumber(amount, totalRate);
        assert(amount >= repayments);
        return amount - repayments;
    }
}

/*
/// @title The `Method` defines new amount of loan or loan update.
/// Allowed to call just from `GRS`.
/// Allowed to make request just for any active entity.
/// @param _subject Amount of loan.
/// @param _sender Address of any entity contract.
*/
contract AddLoanAmountOfEntity is MethodMaker {

    constructor (address _grs) public {
        assert(baseConstructor(_grs, bytes32("AddLoanAmountOfEntity")));
    }

    function make(address _object, address payable _sender, uint256 _value)
        onlyByGRS
        zeroValue(_value)
        external returns (bool)
    {
        /*
        /// _subject in future should be replaced by any
        /// address of contract of any product or service.
        */
        uint subject = uint(_object);
        uint amount = grSystem.getLoanAmount(_sender);
        address cb = _operator().getCentralBankByEntity(_sender);
        uint maxAmount = Subject(_sender).get(bytes32("GetMaxLoanAmountForEntity"), 0);
        if (amount > 0) {
            uint repayments = grSystem.getLoanRepayments(_sender);
            /*
            /// Zeroing current loan amount from all loans given by `CB`.
            /// In the body of the `grSystem.setLoanAmount`
            /// it should be redefined by new amount.
            */
            if (amount >= repayments)
                require(grSystem.deductFromTotalOutstandingLoan(cb, amount - repayments));
            amount = Subject(_sender).get(bytes32("GetRestOfLoanOfEntity"), 0);
        }
        amount += subject;
        assert(amount <= maxAmount);
        /*
        /// Before `DirectConversionDepthMaxTokens` module call check `CB` funds is enough for amount.
        /// Otherwise make request for a Loan for `CB` from `GRS` side.
        */
        if (!_operator().amountIsEnough(cb, amount)) {
            Subject(cb).make(bytes32("MakeRequestForLoanForCB"), amount);
        }
        /* In case of loans for entities, will transfer amount in credit tokens */
        uint eth = Subject(cb).get(bytes32("DirectConversionDepthMaxTokens"), subject);
        require(grSystem.sendTokens(cb, _sender, subject - eth));
        if (eth > 0)
            require(grSystem.sendEther(cb, _sender, eth));
        require(grSystem.setLoanAmount(_sender, amount));
        return true;
    }
}

/*
/// @title The `Method` defines loan as totally repaid by entity.
/// Allowed to call just from `GRS`.
/// Allowed to make request just for any active entity.
/// @param _subject Must be a Zero.
/// @param _sender Address of any entity contract.
*/
contract SetLoanRepaidByEntity is MethodMaker {

    constructor (address _grs) public {
        assert(baseConstructor(_grs, bytes32("SetLoanRepaidByEntity")));
    }

    function make(address _object, address payable _sender, uint256 _value)
        onlyByGRS
        zeroValue(_value)
        zeroObject(_object)
        external returns (bool)
    {
        /* Check that no rest of loan */
        require(Subject(_sender).get(bytes32("GetRestOfLoanOfEntity"), 0) == 0);
        require(grSystem.setLoanAmount(_sender, 0));
        return true;
    }
}

/*
/// @title The `Method` through which makes repayment of loan of entity.
/// Allowed to call just from `GRS`.
/// Allowed to make request just for any active entity.
/// @param _subject Amount of repayment.
/// @param _sender Address of any entity contract.
*/
contract MakeRepaymentOfLoanOfEntity is MethodMaker {

    constructor (address _grs) public {
        assert(baseConstructor(_grs, bytes32("MakeRepaymentOfLoanOfEntity")));
    }

    function make(address _object, address payable _sender, uint256 _value)
        onlyByGRS
        zeroValue(_value)
        external returns (bool)
    {
        uint amount = uint(_object);
        uint rest = Subject(_sender).get(bytes32("GetRestOfLoanOfEntity"), 0);
        address loanCb = grSystem.getLoanCentralBank(_sender);
        uint baseAmount = grSystem.getLoanAmount(_sender);
        uint repayments = grSystem.getLoanRepayments(_sender);
        address cb = _operator().getCentralBankByEntity(_sender);
        /* Check unification process has been complited */
        if (loanCb != cb) {
            require(grSystem.delegateLoanToCentralBank(_sender));
            require(cb == grSystem.getLoanCentralBank(_sender));
        }
        /* If last repayment, deduct rest from amount */
        if (rest < amount) {
            amount -= rest;
            /* If no rest of Loan, will zeroing loan */
            require(Subject(_sender).make(bytes32("SetLoanRepaydByEntity"), 0x0));
        }
        /*
        /// If base, given amount totally not yet repayd,
        /// deduct amount from total loans given by `CB`.
        /// (or interests not deductible).
        */
        if (baseAmount >= repayments + amount)
            require(grSystem.deductFromTotalOutstandingLoan(cb, amount));
        /* Before `DirectConversionDepthMaxTokens` module call check funds is enough for amount. */
        require(_operator().amountIsEnough(_sender, amount));
        uint eth = Subject(_sender).get(bytes32("DirectConversionDepthMaxTokens"), amount);
        require(grSystem.sendTokens(_sender, cb, amount - eth));
        if (eth > 0)
            require(grSystem.sendEther(_sender, cb, eth));
        require(grSystem.addLoanRepayment(_sender, amount));
        return true;
    }
}

/*
/// @title The `Method` defines loan repayment method of entity.
/// Allowed to call just from `GRS`.
/// Allowed to make request just for any active entity.
/// @param _subject Loan repayment method (0-2).
/// @param _sender Address of any entity contract.
*/
contract SetLoanRepaymentMethod is MethodMaker {

    constructor (address _grs) public {
        assert(baseConstructor(_grs, bytes32("SetLoanRepaymentMethod")));
    }

    function make(address _object, address payable _sender, uint256 _value)
        onlyByGRS
        subjectAsUint8(_object)
        zeroValue(_value)
        external returns (bool)
    {
        uint8 method = uint8(_object);
        assert(method < 3);
        require(method != grSystem.getLoanRepaymentMethod(_sender));
        require(grSystem.setLoanRepaymentMethod(_sender, method));
        return true;
    }
}

/*
/// @title The `Method` defines loan repayment percentage
/// through loan repayment methods 0 and 2.
/// In case of addition percentage to cost on deal.
/// Allowed to call just from `GRS`.
/// Allowed to make request just for any active entity.
/// @param _subject Loan repayment percentage (max 25.5%).
/// @param _sender Address of any entity contract.
*/
contract SetLoanRepaymentPercentage is MethodMaker {

    constructor (address _grs) public {
        assert(baseConstructor(_grs, bytes32("SetLoanRepaymentPercentage")));
    }

    function make(address _object, address payable _sender, uint256 _value)
        onlyByGRS
        subjectAsUint8(_object)
        zeroValue(_value)
        external returns (bool)
    {
        uint8 perc = uint8(_object);
        require(grSystem.setLoanRepaymentPercentage(_sender, perc));
        return true;
    }
}

/*
/// @title The `Method` makes computations of turnovers in last weeks
/// and returns maximal amount of ciclical repayments.
/// Ciclical repayments in case of loan repayment methods 1 and 2,
/// or amount of repayment at each cicle defined by `CB`.
/// Allowed to call just from `GRS`.
/// Allowed to make request just for any active entity.
/// @param _subject[](1) Empty.
/// @param _sender Address of any entity contract.
/// @return Maximal amount of ciclical repayments.
*/
contract GetMaxAmountOfCiclicalRepayments is MethodGetter {

    constructor (address _grs) public {
        assert(baseConstructor(_grs, bytes32("GetMaxAmountOfCiclicalRepayments")));
    }

    function get(address _object, address _sender)
        onlyByGRS
        zeroObject(_object)
        external view returns (uint256)
    {
        CB cb = CB(_operator().getCentralBankByEntity(_sender));
        uint8 oneCicle = cb.cicleInWeeksForLoanRepaymentAmount();
        uint8 cicles = cb.numberOfCiclesForLoanRepaymentAmount();
        uint weeksn = oneCicle * cicles;
        uint8 perc = cb.percentageFromTurnoverForLoanRepaymentAmount();
        uint turnover;
        uint week = _week();
        for (uint i = 1; i <= weeksn; i++)
            turnover += cb.getWeeklyTurnover(week - i, _sender);
        return _operator().getPercentageFromNumber(turnover, perc);
    }
}

/*
/// @title The `Method` defines amount of loan ciclical repayments.
/// Not more than max ciclical amount in case of computations
/// of `GetMaxAmountOfCiclicalRepayments`.
/// Ciclical repayments in case of loan repayment methods 1 and 2,
/// or amount of repayment at each cicle defined by `CB`.
/// In case of addition percentage to cost on deal.
/// Allowed to call just from `GRS`.
/// Allowed to make request just for any active entity.
/// @param _subject Amount defined by entity.
/// @param _sender Address of active entity contract.
*/
contract SetCiclicalAmountOfLoanRepayment is MethodMaker {

    constructor (address _grs) public {
        assert(baseConstructor(_grs, bytes32("SetCiclicalAmountOfLoanRepayment")));
    }

    function make(address _object, address payable _sender, uint256 _value)
        onlyByGRS
        zeroValue(_value)
        external returns (bool)
    {
        uint amount = uint(_object);
        uint maxAmount = Subject(_sender).get(bytes32("GetMaxAmountOfCiclicalRepayments"), 0);
        assert(amount <= maxAmount);
        require(grSystem.setLoanRepaymentCiclicalAmount(_sender, amount));
        return true;
    }
}
