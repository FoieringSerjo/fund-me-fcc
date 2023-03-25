// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./PriceConverter.sol";

error NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    mapping(address => uint256) public addressToAmountFunded;
    address[] public funders;

    // Could we make this constant?  /* hint: no! We should make it immutable! */
    address public /* immutable */ i_owner;
    uint256 public constant MINIMUM_USD = 50 * 10 ** 18;
    
    constructor() {
        i_owner = msg.sender;
    }

    function fund() public payable {
        require(msg.value.getConversionRate() >= MINIMUM_USD, "You need to spend more ETH!");
        // require(PriceConverter.getConversionRate(msg.value) >= MINIMUM_USD, "You need to spend more ETH!");
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
    }
    
    function getVersion() public view returns (uint256){
        // ETH/USD price feed address of Sepolia Network.
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        return priceFeed.version();
    }
    
    modifier onlyOwner {
        // require(msg.sender == owner);
        if (msg.sender != i_owner) revert NotOwner();
        _;
    }
    
    function withdraw() public onlyOwner {
        for (uint256 funderIndex=0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
        // // transfer
        // payable(msg.sender).transfer(address(this).balance);
        // // send
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send failed");
        // call
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }
    // Explainer from: https://solidity-by-example.org/fallback/
    // Ether is sent to contract
    //      is msg.data empty?
    //          /   \ 
    //         yes  no
    //         /     \
    //    receive()?  fallback() 
    //     /   \ 
    //   yes   no
    //  /        \
    //receive()  fallback()

    fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();
    }

}

// Concepts we didn't cover yet (will cover in later sections)
// 1. Enum
// 2. Events
// 3. Try / Catch
// 4. Function Selector
// 5. abi.encode / decode
// 6. Hash with keccak256
// 7. Yul / Assembly


// Get funds from users
// Withdraw funds
// Set a minimum funding value in USD

// SPDX-License-Identifier: MIT
// pragma solidity ^0.8.0;

// // 693,155
// // 673,649 with constant
// // 650,746 with immutable
// import "./PriceConverter.sol";

// // interface AggregatorV3Interface {
// //     function decimals() external view returns (uint8);

// //     function description() external view returns (string memory);

// //     function version() external view returns (uint256);

// //     function getRoundData(uint80 _roundId)
// //         external
// //         view
// //         returns (
// //             uint80 roundId,
// //             int256 answer,
// //             uint256 startedAt,
// //             uint256 updatedAt,
// //             uint80 answeredInRound
// //         );

// //     function latestRoundData()
// //         external
// //         view
// //         returns (
// //             uint80 roundId,
// //             int256 answer,
// //             uint256 startedAt,
// //             uint256 updatedAt,
// //             uint80 answeredInRound
// //         );
// // }

// error NotOwner(); //https://blog.soliditylang.org/2021/04/21/custom-errors/

// contract FundMe {
//     using PriceConverter for uint256;

//     uint256 public constant MINIMUM_USD = 50 * 1e18;

//     address[] public funders;
//     mapping(address => uint256) public addressToAmountFunded;

//     address public immutable i_owner;

//     constructor() {
//         i_owner = msg.sender;
//     }

//     function fund() public payable {
//         // Want to be able to set a minimum fund amount
//         // 1. How to send ETH to this contract?
//         require(
//             msg.value.getConversionRate() >= MINIMUM_USD,
//             "Didn't sent enough"
//         ); // 1e18 == 1* 10 ** 18 == 1000000000000000000
//         funders.push(msg.sender);
//         addressToAmountFunded[msg.sender] = msg.value;

//         // What is reverting? - Undo any action before and send remaining gas back.
//     }

//     function Withdraw() public onlyOwner {
//         /* starting index, ending index, step amount*/
//         for (
//             uint256 funderIndex = 0;
//             funderIndex < funders.length;
//             funderIndex++
//         ) {
//             address funder = funders[funderIndex];
//             addressToAmountFunded[funder] = 0;
//         }
//         // reset the array
//         funders = new address[](0);
//         // actually withdraw the funds

//         // transfer
//         // msg.sender = address
//         // payble(msg.sender) = payable address
//         // payable(msg.sender).transfer(address(this).balance);

//         // send
//         // bool sendSuccess = payable(msg.sender).send(address(this).balance);
//         // require(sendSuccess, "Send failed");

//         // call
//         (bool callSuccess, ) = payable(msg.sender).call{
//             value: address(this).balance
//         }("");
//         require(callSuccess, "Call failed");
//     }

//     modifier onlyOwner() {
//         // require(msg.sender == i_owner, "Sender is not owner");
//         if (msg.sender != i_owner) {
//             revert NotOwner();
//         }
//         _;
//     }

//     fallback() external payable {
//         fund();
//     }

//     receive() external payable {
//         fund();
//     }
// }
