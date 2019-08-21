pragma solidity >=0.5.1 <0.6.0;
import "./GRSystem.sol";

/*
/// @title Common `Subject` Contract aimed to be as an ABI interface
/// for secure `GRS` `Method` calls.
/// At this moment `Subject`s are:
/// - `Driver`;
/// - `FamilyUnion`;
/// - `Company`;
/// - `Budget`;
/// - `CB`;
/// - `GRS`;
*/
contract Subject {

    function make (bytes32 _name, uint256 _subject) external returns (bool);
    function get  (bytes32 _name, uint256 _subject) external view returns (uint256);
}

contract Entity is Subject {

    function execMake (bytes32 _name, address _object) external returns (bool);
    function execGet  (bytes32 _name, address _object) external view returns (uint256);
}

contract BaseContract {

    address public centralBank;
    
    uint256 birthDT;
    
    address public allowedParent;
    
    function setInvoiceCreated() external returns (bool);
    function setInvoiceApproved() external returns (bool);
    function setInvoicePaid() external returns (bool);
    
    function getBirthDT() external view returns (uint256);
}

/*
/// @dev Models a uint -> uint mapping where it is possible to iterate over all keys.
 */
library IterableMapping {

    struct itmap {
        mapping(uint => IndexValue) data;
        KeyFlag[] keys;
        uint size;
    }
    
    struct IndexValue {
        uint keyIndex; 
        uint value; 
    }
    
    struct KeyFlag {
        uint key; 
        bool deleted; 
    }
    
    function insert(itmap storage self, uint key, uint value) external returns (bool replaced)
    {
        uint keyIndex = self.data[key].keyIndex;
        self.data[key].value = value;
        if (keyIndex > 0)
            return true;
        else {
            keyIndex = self.keys.length++;
            self.data[key].keyIndex = keyIndex + 1;
            self.keys[keyIndex].key = key;
            self.size++;
            return false;
        }
    }
    
    function remove(itmap storage self, uint key) external returns (bool success)
    {
        uint keyIndex = self.data[key].keyIndex;
        if (keyIndex == 0)
            return false;
        delete self.data[key];
        self.keys[keyIndex - 1].deleted = true;
        self.size --;
    }
    
    function contains(itmap storage self, uint key) external view returns (bool) {
        return self.data[key].keyIndex > 0;
    }
    /*
    function iterate_start(itmap storage self) external returns (uint keyIndex) {
        return iterate_next(self, uint(-1));
    }
    */
    function iterate_valid(itmap storage self, uint keyIndex) external view returns (bool) {
        return keyIndex < self.keys.length;
    }
  
    function iterate_next(itmap storage self, uint keyIndex) external view returns (uint r_keyIndex) {
        r_keyIndex = keyIndex+1;
        while (r_keyIndex < self.keys.length && self.keys[r_keyIndex].deleted)
            r_keyIndex++;
        return r_keyIndex;
    }
  
    function iterate_get(itmap storage self, uint keyIndex) external view returns (uint key, uint value) {
        key = self.keys[keyIndex].key;
        value = self.data[key].value;
    }
}

/*
/// How to use it:
*/
contract User {
    /* Just a struct holding our data. */
    IterableMapping.itmap data;
    
    /* Insert something */
    function insert(uint k, uint v) external returns (uint size) {
        /* Actually calls itmap_impl.insert, auto-supplying the first parameter for us. */
        IterableMapping.insert(data, k, v);
        /* We can still access members of the struct - but we should take care not to mess with them. */
        return data.size;
    }
    
    /* Computes the sum of all stored data. */
    function sum() external view returns (uint s) {
        for (uint i = IterableMapping.iterate_next(data, uint(-1)); IterableMapping.iterate_valid(data, i); i = IterableMapping.iterate_next(data, i))
        {
            (uint k, uint value) = IterableMapping.iterate_get(data, i);
            s += value;
            k = 0;
        }
        return s;
    }
}

/*
/// @title Common `Operator` Contract aimed to manage global and constant data.
*/
contract Operator {

    address public grsAddr;
    GRS public grSystem;
    
    uint256 public constant cent = 1000;

    constructor (address _grs) public {
        require(_grs > address(0));
        grSystem = GRS(_grs);
        grsAddr = _grs;
    }
    
    /*
    ///
    ////// Common Array utils
    ///
    */
    function setOneItemArray(uint256 _item) external pure returns (uint256[] memory item) {
        require(_item > 0);
        item = new uint256[](1);
        item[0] = _item;
        return item;
    }
    
    function setTwoItemsArray(uint256 _item0, uint256 _item1)
        external pure returns (uint256[] memory item) 
    {
        require(_item0 > 0);
        require(_item1 > 0);
        item = new uint256[](2);
        item[0] = _item0;
        item[1] = _item1;
        return item;
    }
    
    function removeFromAddressArray(address[] calldata _array, address _item)
        external pure returns (address[] memory newList)
    {
        require(_array.length > 0);
        require(_item > address(0));
        newList = new address[](_array.length-1);
        uint j;
        for (uint i=0; i<_array.length; i++) {
            if (_array[i] == _item)
                continue;
            newList[j] = _array[i];
            j++;
        }
        return newList;
    }
    
    function inAddressArray(address[] calldata _array, address _item)
        external pure returns (bool)
    {
        require(_array.length > 0);
        require(_item > address(0));
        uint j;
        for (uint i=0; i<_array.length; i++) {
            if (_array[i] == _item)
                break;
            j+=1;
        }
        return j < _array.length-1 ? true : false; 
    }
    
    function summOfArrayElements(uint256[] calldata _array)
        external pure returns (uint256)
    {
        uint summ;
        for (uint i=0; i<_array.length; i++)
            summ += _array[i];
        return summ;
    }
    
    /*
    ///
    ////// Common entity control structures
    ///
    */
    function getCentralBankByEntity(address _entity) external view returns (address) {
        CBMS cbms = CBMS(grSystem.extensions(bytes4("CBMS")));
        address cb = cbms.commonCentralBanks(_entity);
        if (cbms.delegatedToCentralBanks(cb) > address(0))
            return cbms.delegatedToCentralBanks(cb);
        return cb;
    }
    
    /*
    ///
    ////// Common datetime management structures 
    ///
    */
    function getNumberOfCiclesLeft(uint256 _timestamp, uint256 _cicleLen)
        external view returns (uint256 cicles, uint256 odds)
    {
        require(_timestamp > 0);
        uint secsLeft = now - _timestamp;
        uint odd = secsLeft % _cicleLen;
        if (secsLeft - odd == 0)
            return (0, odd);
        return odd > 0 ? ((secsLeft - odd) / _cicleLen, odd) : (secsLeft / _cicleLen, 0);
    }
    
    function getAverageMonthOfYear() external view returns (uint256) {
        uint secsLeft = now - grSystem.thisYearStartedAt();
        uint oneMonth = 30 days;
        uint odd = secsLeft % oneMonth;
        if (secsLeft - odd == 0)
            return 1;
        uint month = odd > 0 ? (secsLeft - odd) / oneMonth + 1 : secsLeft / oneMonth;
        /* Dismiss to return month number of 13 */
        return month <= 12 ? month : 12;
    }
    
    /*
    ///
    ////// Common Math functions
    ///
    */
    function getPercentageFromNumber(uint256 _number, uint256 _perc)
        external pure returns (uint256)
    {
        require(_number >= cent);
        require(_perc > 0);
        /* 
        /// If percentage more than 100% set as 100%.
        /// In case of Bank Deposits that were not withdrawn for a long time.
        */
        uint perc = _perc < cent ? _perc : cent;
        if (_number % cent == 0)
            return _number / cent * perc;
        else {
            uint odd = _number % cent;
            uint even = odd <= 500 ? _number - odd : _number + (cent - odd);
            return even / cent * perc;
        }
    }
    
    function removeOddFromNumber(uint256 _number, uint256 _op)
        external pure returns (uint256)
    {
        require(_op > 1);
        uint odd = _number % _op;
        return odd > 0 ? _number - odd : _number;
    }
    
    function amountIsEnough(address _sender, uint256 _amount)
        external view returns (bool)
    {
        require(_amount > 0);
        uint256 balance = grSystem.getBalance(_sender);
        return balance > _amount ? true : false;
    }
    
    function E2EAmountIsEnough(address _sender, uint256 _amount)
        external view returns (bool)
    {
        require(_amount > 0);
        uint256 tokenBalance = grSystem.getTokenBalance(_sender);
        uint256 etherBalance = _sender.balance;
        return etherBalance + tokenBalance > _amount ? true : false;
    }
}
