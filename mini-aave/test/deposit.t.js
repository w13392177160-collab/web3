// 用 ES 模块的 import 语法引入依赖
import { expect } from "chai";
import hre from "hardhat"; // 导入HRE的默认导出
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";

// 定义夹具（复用合约部署逻辑）
async function deployContractsFixture() {
  // 直接从hre获取ethers（强制初始化）
  const { ethers } = hre;
  const [user] = await ethers.getSigners();

  const Token = await ethers.getContractFactory("Token");
  const Oracle = await ethers.getContractFactory("PriceOracle");
  const Pool = await ethers.getContractFactory("LendingPool");

  const token = await Token.deploy("T", "T", ethers.parseEther("1000"));
  const oracle = await Oracle.deploy();
  const pool = await Pool.deploy(oracle.target);

  return { user, token, oracle, pool, ethers };
}

describe("Deposit",function(){
  it("deposit increases balance",async function () {
    // 加载夹具（确保ethers初始化完成）
    const { user, token, pool } = await loadFixture(deployContractsFixture);

    await token.approve(pool.target,100);
    await pool.deposit(token.target,100);

    expect(await pool.deposit(user.address,token.target)).to.equal(100);

  });
});