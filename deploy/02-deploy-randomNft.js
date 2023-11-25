// imports
require("dotenv").config({ path: process.env.MY_LOCAL_FILE_PATH })
const { verify } = require("../utils/verify")
const { ethers, run, network } = require("hardhat")
const vrfCoordinatorV2 = process.env.vrfCoordinatorV2
const subId = process.env.subscriptionId
const gasLine = process.env.gasLane
const callbackGasLimit = process.env.callbackGasLimit

let tokenUris = [
    "ipfs://QmaVkBn2tKmjbhphU7eyztbvSQU5EXDdqRyXZtRhSGgJGo",
    "ipfs://QmYQC5aGZu2PTH8XzbJrbDnvhj3gVs7ya33H9mqUNvST3d",
    "ipfs://QmZYmH5iDbD6v3U2ixoVAjioSzvWJszDzYdbeCLquGSpVm",
]
// async main
async function main() {
    const RandomIpfsNtfFactory =
        await ethers.getContractFactory("RandomIpfsNtf")
    console.log("Deploying contract...")
    const RandomIpfsNtf = await RandomIpfsNtfFactory.deploy(
        vrfCoordinatorV2,
        subId,
        gasLine,
        callbackGasLimit,
        tokenUris,
    )
    await RandomIpfsNtf.waitForDeployment()

    console.log(`Deployed contract to: ${RandomIpfsNtf.target}`)

    //wait for etherscan got the contract
    await RandomIpfsNtf.deploymentTransaction().wait(10)
    await verify(RandomIpfsNtf.target, [
        vrfCoordinatorV2,
        subId,
        gasLine,
        callbackGasLimit,
        tokenUris,
    ])
    console.log(`Varify contract done to: ${RandomIpfsNtf.target}`)
}

// main
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error)
        process.exit(1)
    })
