// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract NFT is ERC1155 {
  uint256 public constant TOKEN = 0;

    constructor() ERC1155("https://foo.bar/{id}.json") {
        _mint(msg.sender, TOKEN, 1, "");
    }
}