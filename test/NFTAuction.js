const { ethers } = require("hardhat");
const { expect } = require("chai");

describe("NFTAuction", async () => {

    let signers;
    let NFTAuctionFactory;
    let nftAuction;
    let nftAuctionAddress;

    before(async () => {
        signers = await ethers.getSigners();
        NFTAuctionFactory = await ethers.getContractFactory("NFTAuction");
        nftAuction = await NFTAuctionFactory.deploy();
        await nftAuction.waitForDeployment();
        nftAuctionAddress = await nftAuction.getAddress();
        console.log("NFTAuction deployed to:", nftAuction.target);
        console.log("NFTAuction deployed to:", nftAuctionAddress);
    })


    it("should create an auction", async () => {

        await nftAuction.createAuction(
            60 * 60 * 1000,
            100,
            nftAuctionAddress,
            1000001
        )
        const auction = await nftAuction.auctions(0);
        expect(auction.seller).to.equal(signers[0].address);
    })

    it("should bid on an auction", async () => {
        await nftAuction.connect(signers[1]).bid(0, { value: 102 });
        const auction = await nftAuction.auctions(0);   
        expect(auction.highestBidder).to.equal(signers[1].address);
        expect(auction.highestBid).to.equal(102);
    })
})