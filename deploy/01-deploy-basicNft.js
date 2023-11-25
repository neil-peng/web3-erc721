// imports
require("dotenv").config({ path: process.env.MY_LOCAL_FILE_PATH })
const { verify } = require("../utils/verify")

const { ethers, run, network } = require("hardhat")

// async main
async function main() {
    const BasicNftFactory = await ethers.getContractFactory("BasicNft")
    console.log("Deploying contract...")
    const BasicNft = await BasicNftFactory.deploy()
    await BasicNft.waitForDeployment()

    console.log(`Deployed contract to: ${BasicNft.target}`)

    //wait for etherscan got the contract
    await BasicNft.deploymentTransaction().wait(10)
    await verify(BasicNft.target, [process.env.COINMARKETCAP_API_KEY])
    console.log(`Varify contract done to: ${BasicNft.target}`)
}

// main
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error)
        process.exit(1)
    })
