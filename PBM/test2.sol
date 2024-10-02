// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract StablecoinWithVoucher {
    
    address public owner;
    mapping(address => uint256) public balances;
    mapping(address => uint256) public voucherBalances;
    mapping(address => bool) public authorizedMerchants;

    // Event for transfers
    event Transfer(address indexed from, address indexed to, uint256 value);

    // Modifier to restrict access to only owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Mint function to create stablecoins
    function mint(address account, uint256 amount) external onlyOwner {
        balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    // Add an authorized merchant (for voucher tokens)
    function addAuthorizedMerchant(address merchant) external onlyOwner {
        authorizedMerchants[merchant] = true;
    }

    // Remove an authorized merchant
    function removeAuthorizedMerchant(address merchant) external onlyOwner {
        authorizedMerchants[merchant] = false;
    }

    // Function to wrap tokens into vouchers (restrict usage)
    function wrapAsVoucher(uint256 amount) external {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        voucherBalances[msg.sender] += amount;
    }

    // Function to unwrap vouchers back to regular tokens
    function unwrapVoucher(uint256 amount) external {
        require(voucherBalances[msg.sender] >= amount, "Insufficient voucher balance");
        voucherBalances[msg.sender] -= amount;
        balances[msg.sender] += amount;
    }

    // Transfer function for regular stablecoin
    function transfer(address to, uint256 amount) external {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        balances[to] += amount;
        emit Transfer(msg.sender, to, amount);
    }

    // Transfer function for voucher tokens (restricted to authorized merchants)
    function transferVoucher(address to, uint256 amount) external {
        require(voucherBalances[msg.sender] >= amount, "Insufficient voucher balance");
        require(authorizedMerchants[to], "Recipient is not an authorized merchant");
        voucherBalances[msg.sender] -= amount;
        balances[to] += amount;  // Merchant gets regular tokens
        emit Transfer(msg.sender, to, amount);
    }
}
