// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    function weiToUsd(uint256 weiAmount) internal view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            0x694AA1769357215DE4FAC081bf1f309aDC325306
        );
        (, int256 answer, , , ) = priceFeed.latestRoundData();
        uint256 ethPrice = uint(answer);
        uint256 weiAmountInUsd = ethPrice * (weiAmount / (10 ** 8));
        return weiAmountInUsd / 1000000000000000000;
    }

    function usdToWei(uint256 usdAmount) internal view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            0x694AA1769357215DE4FAC081bf1f309aDC325306
        );
        (, int256 answer, , , ) = priceFeed.latestRoundData();
        uint256 ethPriceInWei = uint256(answer) / 100000000;
        return (usdAmount * 1000000000000000000) / ethPriceInWei;
    }
}
