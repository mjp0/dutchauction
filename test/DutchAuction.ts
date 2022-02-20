import { mine, loadFixture } from "@nomicfoundation/hardhat-network-helpers"
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs"
import { expect } from "chai"
import { ethers } from "hardhat"

describe("Dutch Auction", function () {
  async function deployDutchAuction() {
    // Contracts are deployed using the first signer/account by default
    const [owner, otherAccount] = await ethers.getSigners()

    const NFT = await ethers.getContractFactory("NFT")
    const nft = await NFT.deploy()
    const Contract = await ethers.getContractFactory("DutchAuction")
    const contract = await Contract.deploy(nft.address, 1, 1000000, 100)
    await nft.setApprovalForAll(contract.address, true);
    return { contract, owner, otherAccount }
  }

  describe("Deployment", function () {
    it("should deploy successfully", async function () {
      const { contract } = await loadFixture(deployDutchAuction)
      expect(await contract.getCurrentPrice()).to.equal(1000000000)
    })
  })

  describe("Buy now", async function () {
    it("should discount the price successfully", async () => {
      const { contract } = await loadFixture(deployDutchAuction)
      expect(await contract.getCurrentPrice()).to.equal(999999900)
      await mine(1000)
      expect(await contract.getCurrentPrice()).to.equal(999899900)
    })

    it("should buy and transfer the nft successfully", async () => {
      const { contract, otherAccount } = await loadFixture(deployDutchAuction)
      console.log(otherAccount)
      await mine(1000)
      const contract2 = await ethers.getContractAt(
        "DutchAuction",
        contract.address,
        otherAccount
      );
      await contract2.buyNow({value: 999899900 })
      

    })
  })
})
