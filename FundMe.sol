// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

// here we import -
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

// why this ?  For gas efficiency
error NotOwner();


contract FundMe {
    // Type Declarations
    using PriceConverter for uint256;

    // Variables declaration->
    uint256 public constant MINIMUM_USD = 1 * 10 ** 18;
    address public  immutable i_owner;
    address[] public funders;
    mapping(address => uint256) public addressToAmountFunded;
    AggregatorV3Interface public priceFeed = AggregatorV3Interface(0x9d7834C376B2b722c5693af588C3e7a03Ea8e44D); 

    
    modifier onlyOwner() {
        // require(msg.sender == i_owner);
        if (msg.sender != i_owner) revert NotOwner();
        _;
    }

    constructor() {
        i_owner = msg.sender;
    }

    
    function fund() public payable {
        require(msg.value.getConversionRate(priceFeed) >= MINIMUM_USD, "You need to spend more ETH!");
        
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
    }

    function withdraw() public onlyOwner {
       
        for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
        // Transfer vs call vs Send
        // payable(msg.sender).transfer(address(this).balance);
        (bool success,) = i_owner.call{value: address(this).balance}("");
        require(success);
    }
    function getVersion() public view returns (uint256) {
        // priceFeed = AggregatorV3Interface(0x9d7834C376B2b722c5693af588C3e7a03Ea8e44D); 
        return priceFeed.version();
    }

    receive() external payable {
        fund();
    }

    fallback() external payable { 
        fund();
    }

  
}