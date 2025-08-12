const { ethers } = require("hardhat");
const { expect } = require("chai");

describe("Airdrop", async () => {
    let Token, token, Airdrop, airdrop;
    let owner, user1, user2, user3;

    const initialSupply = ethers.parseEther("1000"); // 1000 TTK
    const airdropAmount = ethers.parseEther("10"); // 每人 10 TTK

    beforeEach(async () => {
        [owner, user1, user2, user3] = await ethers.getSigners();

        // 部署测试代币
        Token = await ethers.getContractFactory("TestToken");
        token = await Token.deploy(initialSupply);
        await token.waitForDeployment();

        // 部署空投合约
        Airdrop = await ethers.getContractFactory("Airdrop");
        airdrop = await Airdrop.deploy(token.target, airdropAmount);
        await airdrop.waitForDeployment();

        // 转移代币到空投合约
        await token.transfer(await airdrop.getAddress(), ethers.parseEther("100"));
    });


    it("用户可以成功领取空投", async () => {
        await airdrop.addToWhitelist(user1.address);

        await expect(airdrop.connect(user1).claim())
            .to.emit(airdrop, "Claimed")
            .withArgs(user1.address, airdropAmount);

        const balance = await token.balanceOf(user1.address);
        expect(balance).to.equal(airdropAmount);
    });

    it("非白名单用户领取应失败", async function () {
        await expect(airdrop.connect(user2).claim()).to.be.revertedWith("Not in whitelist");
    });

    it("同一用户不能重复领取", async function () {
        await airdrop.addToWhitelist(user1.address);
        await airdrop.connect(user1).claim();

        await expect(airdrop.connect(user1).claim()).to.be.revertedWith("Already claimed");
    });

    it("批量添加白名单并领取", async () => {
        await airdrop.addManyToWhitelist([user1.address, user2.address]);
        await airdrop.connect(user1).claim();
        await airdrop.connect(user2).claim();

        expect(await token.balanceOf(user1.address)).to.equal(airdropAmount);
        expect(await token.balanceOf(user2.address)).to.equal(airdropAmount);
    });
});