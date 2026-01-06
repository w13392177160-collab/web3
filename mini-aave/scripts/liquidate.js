// 价格下跌后触发清算
const {ethers} = require("hardhat");

async function main() {

    const [liquidator,user] = await ethers.getSingers();
    
   // ==========修改为你部署后的地址===========
   const TOKEN = "0x...";
   const ORACLE = "0x...";
   const POOL = "0x...";
   const LIQUIDATION = "0x...";

   const token = await ethers.getContractAt("Token",TOKEN);
   const oracle = await ethers.getContractAt("PriceOracle",ORACLE);
   const pool = await ethers.getContractAt("LendingPool",POOL);
   const liquidation = await ethers.getContractAt("liquidation",LIQUIDATION);

   // 1、模拟价格暴跌
   await oracle.setPrice(TOKEN,ethers.parseEther("0.5"));
   console.log("Price drooped to 0.5");

   // 2、检查health factor
   const hf = await pool.healthFactor(user.address,TOKEN);
   console.log("Health Factor:",ethers.formatEther(hf));

   if(hf >= ethers.parseEther("1")){
     console.log("Position still healthy");
     return;
   }

   // 3、清算人 approve token
   const repayAmount = ethers.parseEther("10");
   await token.connect(liquidator).approve(LIQUIDATION,repayAmount);

   // 4、执行清算
   await liquidation.connect(liquidator).liquidate(pool.target,user.address,TOKEN,repayAmount);

   console.log("liquidation executed");
    
}

main().catch((err) =>{
    console.error(err);
    process.exit(1);
});