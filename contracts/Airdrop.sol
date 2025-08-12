// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract Airdrop {
    IERC20 public token;
    uint256 public airdropAmount;
    address public owner;

    mapping(address => bool) public whitelist;
    mapping(address => bool) public claimed;

    event Claimed(address indexed user, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor(IERC20 _token, uint256 _airdropAmount) {
        token = _token;
        airdropAmount = _airdropAmount;
        owner = msg.sender;
    }

    function addToWhitelist(address _user) external onlyOwner {
        whitelist[_user] = true;
    }

    function addManyToWhitelist(address[] calldata _users) external onlyOwner {
        for (uint256 i = 0; i < _users.length; i++) {
            whitelist[_users[i]] = true;
        }
    }

    function claim() external {
        require(whitelist[msg.sender], "Not in whitelist");
        require(!claimed[msg.sender], "Already claimed");
        
        claimed[msg.sender] = true;
        require(token.transfer(msg.sender, airdropAmount), "Token transfer failed");

        emit Claimed(msg.sender, airdropAmount);
    }
}