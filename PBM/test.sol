// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract WLStablecoin is ERC20, Ownable {
    
    enum PurposeType { Meal, Tech, Culture }

    // Mapping to store different types of stablecoin balances
    mapping(address => mapping(PurposeType => uint256)) public voucherBalance;

    // Mappings for roles
    mapping(address => bool) public distributors;
    mapping(address => bool) public issuers;

    // Mapping to store merchant authorizations
    mapping(address => PurposeType[]) public merchants;

    // Events for role management
    event DistributorAdded(address indexed distributor);
    event DistributorRemoved(address indexed distributor);
    event IssuerAdded(address indexed issuer);
    event IssuerRemoved(address indexed issuer);

    // Modifier to restrict certain functions to distributors only
    modifier onlyDistributor() {
        require(distributors[msg.sender], "Access restricted to distributors");
        _;
    }


    // Constructor to initialize the ERC20 token
    constructor() ERC20("MyToken", "MTK") Ownable(msg.sender) {}

    // Function to mint new tokens
    function mint(address account, uint256 amount) public onlyOwner {
        _mint(account, amount);
    }

    // Function to mint a voucher
    function mintVoucher(address account, uint256 amount, PurposeType purposeType) public onlyOwner {
        voucherBalance[account][purposeType] += amount;
        _burn(account, amount);
    }

    // Function to burn a voucher
    function burnVoucher(address account, uint256 amount, PurposeType purposeType) public onlyOwner {
        require(voucherBalance[account][purposeType] >= amount, "Insufficient voucher balance");
        voucherBalance[account][purposeType] -= amount;
        _mint(account, amount);
    }

    // Function for distributors to distribute vouchers
    function distributeVoucher(address accountTo, uint256 amount, PurposeType purposeType) public onlyDistributor {
        require(voucherBalance[msg.sender][purposeType] >= amount, "Insufficient balance to distribute");
        voucherBalance[accountTo][purposeType] += amount;
        voucherBalance[msg.sender][purposeType] -= amount;
    }

    // Function to transfer vouchers
    function transferVoucher(address accountTo, uint256 amount, PurposeType purposeType) public {
        require(hasAuthorization(accountTo, purposeType), "Recipient does not have authorization");
        require(voucherBalance[msg.sender][purposeType] >= amount, "Insufficient voucher balance");

        voucherBalance[accountTo][purposeType] += amount;
        voucherBalance[msg.sender][purposeType] -= amount;
    }

    // Function to redeem a voucher for tokens
    function redeemVoucher(uint256 amount, PurposeType purposeType) public {
        require(voucherBalance[msg.sender][purposeType] >= amount, "Insufficient voucher balance to redeem");
        voucherBalance[msg.sender][purposeType] -= amount;
        _mint(msg.sender, amount);
    }

    // Functions for managing issuers
    function addIssuer(address _issuer) external onlyOwner {
        require(!issuers[_issuer], "Issuer already exists");
        issuers[_issuer] = true;
        emit IssuerAdded(_issuer);
    }

    function removeIssuer(address _issuer) external onlyOwner {
        require(issuers[_issuer], "Issuer does not exist");
        issuers[_issuer] = false;
        emit IssuerRemoved(_issuer);
    }

    // Functions for managing distributors
    function addDistributor(address _distributor) external onlyOwner {
        require(!distributors[_distributor], "Distributor already exists");
        distributors[_distributor] = true;
        emit DistributorAdded(_distributor);
    }

    function removeDistributor(address _distributor) external onlyOwner {
        require(distributors[_distributor], "Distributor does not exist");
        distributors[_distributor] = false;
        emit DistributorRemoved(_distributor);
    }

    // Functions for merchant authorizations
    function addAuthorization(address _merchant, PurposeType _authorization) external onlyOwner {
        require(!hasAuthorization(_merchant, _authorization), "Merchant already has this authorization");
        merchants[_merchant].push(_authorization);
    }

    function removeAuthorization(address _merchant, PurposeType _authorization) external onlyOwner {
        require(hasAuthorization(_merchant, _authorization), "Merchant does not have this authorization");

        // Remove the authorization from the merchant's list
        uint256 length = merchants[_merchant].length;
        for (uint256 i = 0; i < length; i++) {
            if (merchants[_merchant][i] == _authorization) {
                merchants[_merchant][i] = merchants[_merchant][length - 1]; // Swap and pop
                merchants[_merchant].pop();
                break;
            }
        }
    }

    function hasAuthorization(address _merchant, PurposeType _authorization) public view returns (bool) {
        uint256 length = merchants[_merchant].length;
        for (uint256 i = 0; i < length; i++) {
            if (merchants[_merchant][i] == _authorization) {
                return true;
            }
        }
        return false;
    }

    // Function to get all authorizations for a specific merchant
    function getAuthorizations(address _merchant) external view returns (PurposeType[] memory) {
        return merchants[_merchant];
    }
}
