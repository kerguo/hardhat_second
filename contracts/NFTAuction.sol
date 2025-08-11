// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8;

contract NFTAuction {
    struct Auction {
        address seller; // seller address
        address NFTAddress; // NFT contract address
        uint256 tokenId; // nft token id
        uint256 startTime; // auction start time
        uint256 duration; // auction duration
        bool ended; // auction ended flag
        uint256 startingPrice; // auction starting price
        uint256 highestBid; // highest bid
        address highestBidder; // highest bidder
    }
    //  状态变量
    mapping(uint256 => Auction) public auctions;
    // 下一个拍卖ID
    uint256 public nextAuctionId;
    // 管理员地址
    address public admin;

    constructor() {
        admin = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not admin");
        _;
    }

    // 创建拍卖
    function createAuction(
        uint256 _duration,
        uint256 _startingPrice,
        address _NFTAddress,
        uint256 _tokenId

    ) public onlyAdmin {
        require(_duration > 2*60*1000, "Duration must be greater than 2*60*1000 (2 minutes)");
        require(_startingPrice > 0, "Starting price must be greater than 0");
        Auction memory auction = Auction({
            seller: msg.sender,
            NFTAddress: _NFTAddress,
            tokenId: _tokenId,
            startTime: block.timestamp,
            duration: _duration,
            ended: false,
            startingPrice: _startingPrice,
            highestBid: 0,
            highestBidder: address(0)
        });
        auctions[nextAuctionId] = auction;
        nextAuctionId++;
    }


    // 买单
    function bid(uint256 _auctionId) external payable {
        Auction storage auction = auctions[_auctionId];
        // 拍卖未结束
        require(!auction.ended || block.timestamp < auction.startTime + auction.duration, "Auction already ended");
        // 拍卖未开始
        require(block.timestamp > auction.startTime, "Auction not started");
        // 买单金额大于当前最高出价
        require(msg.value > auction.highestBid && msg.value >= auction.startingPrice, "Bid too low");

        // 如果有最高出价者，退还其出价
        if (auction.highestBidder != address(0)) {
            payable(auction.highestBidder).transfer(auction.highestBid);
        }
        // 更新最高出价
        auction.highestBid = msg.value;
        auction.highestBidder = msg.sender;
    }
}


// 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
// 1000001

// 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4


// 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
// 1000002
// 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2