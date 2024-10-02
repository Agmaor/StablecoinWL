// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract WhitelistDistributor {

    address public owner;

    struct wrapper{
        string wrappedName;
        bool authorization;
    }

    // Mapping to store addresses with the "Distributor" role
    mapping(address => bool) public distributors;

    mapping(address => bool) public issuers;

    mapping (address => wrapper[]) public merchants;
    
    function addMerchant(address _merchant) external onlyIssuer{
        // Need to add the wrapper in the parameter of the function
         wrapper memory newWrapper = wrapper({
            wrappedName: "Wrapper1",
            authorization: true
        });
        merchants[_merchant].push(newWrapper);
    }


    function getMerchantAuthorization(address _merchant) external view returns(wrapper[] memory){
        return merchants[_merchant];
    }

    // Event for adding/removing a distributor
    event DistributorAdded(address indexed distributor);
    event DistributorRemoved(address indexed distributor);

    // Modifier to restrict functions to the contract owner only
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    modifier onlyIssuer(){
        require(issuers[msg.sender] == true, "Only a issuer can call this");
        _;
    }
    // Modifier to restrict certain functions to distributors only
    modifier onlyDistributor() {
        require(distributors[msg.sender] == true, "Only a distributor can call this function");
        _;
    }

    // Constructor to set the contract deployer as the owner
    constructor() {
        owner = msg.sender;
    }

    function addIssuer(address _issuer) external onlyOwner {
        issuers[_issuer] = true;
    }

    function removeIssuer(address _issuer) external onlyOwner{
        issuers[_issuer] = false;
    }
    // Function for the owner to add a distributor
    function addDistributor(address _distributor) external onlyIssuer {
        distributors[_distributor] = true;
        emit DistributorAdded(_distributor);
    }

    // Function for the owner to remove a distributor
    function removeDistributor(address _distributor) external onlyIssuer {
        distributors[_distributor] = false;
        emit DistributorRemoved(_distributor);
    }

    // Example function that can only be called by a distributor
    function distributeTokens(address recipient, uint256 amount) external onlyDistributor {
        // Implement token distribution logic here
        // For example, you could integrate this with an ERC20 token contract
    }
}
