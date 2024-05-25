// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface IERC721 {
    function transferFrom(
        address _from,
        address _to,
        uint256 _nftId
    ) external;
}

contract DutchAuction {
    uint256 private constant DURATION = 7 days;
    IERC721 public immutable nft;
    uint256 public immutable nftId;
    address payable public immutable seller;
    uint256 public immutable startingPrice;
    uint256 public immutable startAt;
    uint256 public immutable expireAt;
    uint256 public immutable discoutRate;

    constructor(
        uint256 _startingPrice,
        uint256 _discoutRate,
        address _nft,
        uint256 _nftId
    ) {
        require(
            _startingPrice >= _discoutRate * DURATION,
            "starting price < discount"
        );
        seller = payable(msg.sender);
        startingPrice = _startingPrice;
        discoutRate = _discoutRate;
        startAt = block.timestamp;
        expireAt = startAt + DURATION;
        nft = IERC721(_nft);
        nftId = _nftId;
    }

    function getPrice() public view returns (uint256) {
        uint256 timeElapsed = block.timestamp - startAt;
        uint256 discount = discoutRate * timeElapsed;
        return startingPrice - discount;
    }

    function buy() external payable {
        require(block.timestamp <= expireAt, "Auction expired");
        uint256 price = getPrice();
        require(msg.value >= price, "ETH < price");
        nft.transferFrom(seller, msg.sender, nftId);
        uint refund = msg.value - price;
        if (refund > 0) {
            payable(msg.sender).transfer(refund);
        }
        selfdestruct(seller);
    }
}
