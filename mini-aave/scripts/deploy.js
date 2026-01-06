async function main() {

    const Oracle = await ethers.getContractFactory("PriceOracle");
    const oracle = await Oracle.deploy();

    const Pool = await ethers.getContractFactory("LendingPool");
    const pool = await Pool.deploy(oracle.target);

    console.log("Oracle:",oracle.target);
    console.log("LendingPool",pool.target);
    
}

main();