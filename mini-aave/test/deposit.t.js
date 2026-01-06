const {expect} = require("chai");

describe("Deposit",function(){
  it("deposit increases balance",async function () {
    const [user] = await ethers.getSigners();
    const Token = await ethers.getContractFactory("Token");
    const Oracle = await ethers.getContractFactory("PriceOracle");
    const Pool = await ethers.getContractFactory("LendingPool");

    const token = await Token.deploy("T","T",ethers.parseEther("1000"));
    const oracle = await Oracle.deploy();
    const pool = await Pool.deploy(oracle.target);

    await token.approve(pool.target,100);
    await pool.deposit(token.target,100);

    expect(await pool.deposit(user.address,token.target)).to.equal(100);

  } );
});