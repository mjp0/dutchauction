// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "hardhat/console.sol";

contract DutchAuction {
    IERC1155 public NFT;
    uint public nftId;
    uint private constant AUCTION_DURATION = 1 days;
    address payable public owner;
    uint public price;
    uint public startedAt;
    uint public endsAt;
    uint public discountRate;

    constructor(
        address _nft,
        uint _nftId,
        uint _startingPrice,
        uint _discountRate
    ) {
        // set the auction token and owner
        NFT = IERC1155(_nft);
        nftId = _nftId;
        owner = payable(msg.sender);

        // set the price and discount rate
        price = _startingPrice;
        discountRate = _discountRate;
        require(
            _startingPrice > discountRate * AUCTION_DURATION,
            "invalid starting price"
        );

        // set start and expiration
        startedAt = block.timestamp;
        endsAt = startedAt + AUCTION_DURATION;
    }

    function getCurrentPrice() public view returns (uint) {
        // calculate price minus discount
        uint dRate = discountRate * (block.timestamp - startedAt);
        return price - dRate;
    }

    function buyNow() external payable {
        // is auction still going?
        require(block.timestamp < endsAt, "expired");

        // is price equal or higher than current price?
        uint p = getCurrentPrice();
        require(msg.value >= p, "less price sent");

        // transfer NFT to the new owner
        NFT.safeTransferFrom(owner, msg.sender, 0, msg.value, bytes('0x'));

        // refund excess
        uint refund = msg.value - p;
        if (refund > 0) payable(msg.sender).transfer(refund);

        // send received value to owner and destroy the auction contract
        selfdestruct(owner);
    }
}
