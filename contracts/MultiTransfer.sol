// SPDX-License-Identifier: MIT

pragma solidity >=0.8.19;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function transferFromMulti(address sender, address[] memory recipients, uint256[] memory amounts) external returns (bool);

    function transferFromMultiEqual(address sender, address[] memory recipients, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// @dev Wrappers over Solidity's arithmetic operations with added overflow * checks.
library SafeMath {
    // Counterpart to Solidity's `+` operator.
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    // Counterpart to Solidity's `-` operator.
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    // Counterpart to Solidity's `-` operator.
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    // Counterpart to Solidity's `*` operator.
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    // Counterpart to Solidity's `/` operator.
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    // Counterpart to Solidity's `/` operator.
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    // Counterpart to Solidity's `%` operator.
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    // Counterpart to Solidity's `%` operator.
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () { }

    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "onlyOwner");
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract Wallet is Ownable {
    receive() external payable {}
    fallback() external payable {}

    // Transfer Eth
    function transferEth(address _to, uint256 _amount) public onlyOwner {
        (bool sent, ) = _to.call{value: _amount}("");
        require(sent, "Failed to send Ether");
    }

    // Transfer Tokens
    function transferTokens(address _token, address _to, uint256 _amount) public onlyOwner {
        IERC20 contractToken = IERC20(_token);
        contractToken.transfer(_to, _amount);
    }

}

contract MultiTransfer is Context, Ownable, Wallet {
    using SafeMath for uint256;

    function getSumByArr(uint256[] memory _uintArr) internal pure returns (uint256) {
        uint256 uintSum = 0;
        for (uint i; i < _uintArr.length; i++) {
            uintSum = uintSum.add(_uintArr[i]);
        }
        return uintSum;
    }

    // multiTransfersEth
    function multiTransfersEth(address[] memory  _addressesArray, uint256[] memory  _amountsArray) payable public returns (bool) {
        require(_addressesArray.length == _amountsArray.length, "_addressesArray.length != _amountsArray.length");
        require(msg.value >= getSumByArr(_amountsArray), "You must send eth");

        for (uint i; i < _addressesArray.length; i++) {
            payable(_addressesArray[i]).transfer(_amountsArray[i]);
        }

        // Refund
        uint256 amountRefund = msg.value.sub(getSumByArr(_amountsArray));
        if(amountRefund>0){
            (bool success, ) = msg.sender.call{value:amountRefund}("");
            require(success, "Transfer failed.");
        }

        return true;
    }

    // multiTransfersEth Equal Amount
    function multiTransfersEthEqualAmount(address[] memory  _addressesArray, uint256 _amount) payable public returns (bool) {
        require(msg.value >= _amount.mul(_addressesArray.length), "You must send eth");

        for (uint i; i < _addressesArray.length; i++) {
            payable(_addressesArray[i]).transfer(_amount);
        }

        // Refund
        uint256 amountRefund = msg.value.sub(_amount.mul(_addressesArray.length));
        if(amountRefund>0){
            (bool success, ) = msg.sender.call{value:amountRefund}("");
            require(success, "Transfer failed.");
        }

        return true;
    }
    function test() payable public returns (bool) {
                payable(address(this)).transfer(msg.value);
                return true;
        }

    // multiTransfersTokens
    function multiTransfersTokens(address _token, address[] memory  _addressesArray, uint256[] memory  _amountsArray) public returns (bool) {
        require(_addressesArray.length == _amountsArray.length, "_addressesArray.length != _amountsArray.length");
        IERC20 contractToken = IERC20(_token);
        contractToken.transferFromMulti(msg.sender, _addressesArray, _amountsArray);


        

        return true;
    }
    // multiTransfersTokens Equal Amount
    function multiTransfersTokensEqualAmount(address _token, address[] memory  _addressesArray, uint256 _amount) public returns (bool) {
        IERC20 contractToken = IERC20(_token);
        contractToken.transferFromMultiEqual(msg.sender, _addressesArray, _amount);
        return true;
    }
}

contract SimpleToken is Context, Ownable, IERC20 {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;
    uint8 public _decimals;
    string public _symbol;
    string public _name;

    constructor() {
        _name = "Komron";
        _symbol = "KMR";
        _decimals = 18;
        _totalSupply = 1000000 * 10 ** 18;
        _balances[msg.sender] = _totalSupply;

        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function getOwner() external view returns (address) {
        return owner();
    }

    function decimals() external view returns (uint8) {
        return _decimals;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address addressOwner, address spender) external view returns (uint256) {
        return _allowances[addressOwner][spender];
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "Transfer amount exceeds allowance"));
        return true;
    }

    function transferFromMulti(address sender, address[] memory recipients, uint256[] memory amounts) external returns (bool) {
        for (uint i; i < recipients.length; i++) {
            _transfer(sender, recipients[i], amounts[i]);
            _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amounts[i], "Transfer amount exceeds allowance"));
        }
        return true;
    }

    function transferFromMultiEqual(address sender, address[] memory recipients, uint256 amount) external returns (bool) {
        for (uint i; i < recipients.length; i++) {
            _transfer(sender, recipients[i], amount);
            _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "Transfer amount exceeds allowance"));
        }
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "Decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "Transfer from the zero address");
        require(recipient != address(0), "Transfer to the zero address");
        require(amount <= _balances[sender], "Transfer amount exceeds balance");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _approve(address addressOwner, address spender, uint256 amount) internal {
        require(addressOwner != address(0), "Approve from the zero address");
        require(spender != address(0), "Approve to the zero address");

        _allowances[addressOwner][spender] = amount;
        emit Approval(addressOwner, spender, amount);
    }

}