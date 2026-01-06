// 存款后借款
const { ethers } = require("hardhat");

async function main() {
   const [user] = await ethers.getSingers();

   // ==========修改为你部署后的地址===========
   const TOKEN = "0x...";
   const ORACLE = "0x...";
   const POOL = "0x...";

   const token = await ethers.getContractAt("Token",TOKEN);
   const oracle = await ethers.getContractAt("PriceOracle",ORACLE);
   const pool = await ethers.getContractAt("LendingPool",POOL);

   // 1、设置价格
   await oracle.setPrice(TOKEN,ethers.parseEther("1"));

   // 2、给用户一些token

   // 3、approve LendingPool
   const depositAmount = ethers.parseEther("100");
   await token.approve(POOL,depositAmount);

   // 4、deposit
   await pool.deposit(TOKEN,depositAmount);
   console.log("Deposited 100 tokens");

   // 5、borrow
   const brrowAmount = ethers.parseEther("50");
   await pool.borrow(TOKEN,brrowAmount);

   // 6、查看health factor
   const hf = await pool.healthFactor(user.address,TOKEN);
   console.log("Health Factor:",ethers.formatEther(hf));
}

main().catch((err) =>{
    console.error(err);
    process.exit(1);
}
);