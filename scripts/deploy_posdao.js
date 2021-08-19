const hre = require("hardhat");

const DAO_MULTISIG = process.env.DAO_MULTISIG;

async function main() {
    const [owner] = await ethers.getSigners();

    let initial_miners = process.env.INITIAL_MINERS.split(",")
    let initial_stakers = process.env.INITIAL_STAKERS.split(",")

    console.log("\n POSDAO Config: \n")
    console.log("Initial Miners:                    ", JSON.stringify(initial_miners))
    console.log("Initial Stakers:                   ", JSON.stringify(initial_stakers))
    console.log("First Validator unremovable:       ", process.env.FIRST_VALIDATOR_UNREMOVABLE)
    console.log("Delegator Minimum Stake:           ", process.env.DELEGATOR_MIN_STAKE, "wei")
    console.log("Candidate Minimum Stake:           ", process.env.CANDIDATE_MIN_STAKE, "wei")
    console.log("Epoch Duration:                    ", process.env.EPOCH_DURATION, "blocks")
    console.log("Epoch Start Block:                 ", process.env.EPOCH_START_BLOCK)
    console.log("Stake withdrawal disallow period:  ", process.env.STAKE_WITHDRAWAL_DISALLOW_PERIOD, "blocks")
    console.log("Collect round length:              ", process.env.COLLECT_ROUND_LENGTH, "blocks")

    console.log("\n ==> Deploying Contracts \n")

    const ValidatorSetAuRa = await ethers.getContractFactory("ValidatorSetAuRa");
    const BlockRewardAuRa = await ethers.getContractFactory("BlockRewardAuRa");
    const RandomAuRa = await ethers.getContractFactory("RandomAuRa");
    const StakingAuRa = await ethers.getContractFactory("StakingAuRa");
    const Governance = await ethers.getContractFactory("Governance");
    const TxPermission = await ethers.getContractFactory("TxPermission");
    const Certifier = await ethers.getContractFactory("Certifier");
    const Registry = await ethers.getContractFactory("Registry");
    const Agora = await ethers.getContractFactory("Agora");
    const Timelock = await ethers.getContractFactory("Timelock");
    const Parliament = await ethers.getContractFactory("Parliament");
    const Drachma = await ethers.getContractFactory("Drachma");
    const WETH = await ethers.getContractFactory("WETH9");

    const Proxy = await ethers.getContractFactory("contracts/posdao/upgradeability/AdminUpgradeabilityProxy.sol:AdminUpgradeabilityProxy");

    console.log("==> Deploying Polis Governance Contracts")

    console.log("Deploying WETH")
    let weth = await WETH.deploy()
    await weth.deployed()

    console.log("Deploying Drachma")
    let drachma = await Drachma.deploy()
    await drachma.deployed()

    console.log("Deploying Agora")
    let agora = await Agora.deploy(weth.address)
    await agora.deployed()

    console.log("Deploying Timelock")
    // Set delay to 1 week
    let timelock = await Timelock.deploy(owner.address, 604800)
    await timelock.deployed()

    console.log("Deploying Parliament")
    let parliament = await Parliament.deploy(timelock.address, drachma.address, owner.address)
    await parliament.deployed()

    console.log("==> Setting Polis Governance Ownerships")

    let tx = await agora.proposeOwner(timelock.address);
    await tx.wait()

    tx = await timelock.claimAddress(agora.address);
    await tx.wait()

    tx = await timelock.setPendingAdmin(parliament.address);
    await tx.wait()

    tx = await parliament.__acceptAdmin();
    await tx.wait()

    tx = await parliament.__changeGuardian(DAO_MULTISIG);
    await tx.wait()

    console.log("==> Deploying POSDAO Contracts")

    console.log("Deploying ValidatorSetAuRa")
    let validatorSet = await ValidatorSetAuRa.deploy()
    await validatorSet.deployed()
    let validatorSetProxy = await Proxy.deploy(validatorSet.address, owner.address)
    await validatorSetProxy.deployed()

    console.log("Deploying BlockRewardAuRa")
    let blockReward = await BlockRewardAuRa.deploy()
    await blockReward.deployed()
    let blockRewardProxy = await Proxy.deploy(blockReward.address, owner.address)
    await blockRewardProxy.deployed()

    console.log("Deploying RandomAuRa")
    let random = await RandomAuRa.deploy()
    await random.deployed()
    let randomProxy = await Proxy.deploy(random.address, owner.address)
    await randomProxy.deployed()

    console.log("Deploying StakingAuRa")
    let staking = await StakingAuRa.deploy()
    await staking.deployed()
    let stakingProxy = await Proxy.deploy(staking.address, owner.address)
    await stakingProxy.deployed()

    console.log("Deploying Governance")
    let governance = await Governance.deploy()
    await governance.deployed()
    let governanceProxy = await Proxy.deploy(governance.address, owner.address)
    await governanceProxy.deployed()

    console.log("Deploying TxPermission")
    let txPermission = await TxPermission.deploy()
    await txPermission.deployed()
    let txPermissionProxy = await Proxy.deploy(txPermission.address, owner.address)
    await txPermissionProxy.deployed()

    console.log("Deploying Certifier")
    let certifier = await Certifier.deploy()
    await certifier.deployed()
    let certifierProxy = await Proxy.deploy(certifier.address, owner.address)
    await certifierProxy.deployed()

    console.log("Deploying Registry")
    let registry = await Registry.deploy(certifierProxy.address, owner.address)
    await registry.deployed()

    console.log("\n ==> Initializing POSDAO contracts \n")

    console.log("Initializing ValidatorSetAuRa")
    const validatorSetProxyAccess = ValidatorSetAuRa.attach(validatorSetProxy.address)
    tx = await validatorSetProxyAccess.initialize(
        blockRewardProxy.address,
        governanceProxy.address,
        randomProxy.address,
        stakingProxy.address,
        initial_miners,
        initial_stakers,
        process.env.FIRST_VALIDATOR_UNREMOVABLE
    )
    await tx.wait()

    console.log("Initializing BlockRewardAuRa")
    const blockRewardProxyAccess = BlockRewardAuRa.attach(blockRewardProxy.address)
    tx = await blockRewardProxyAccess.initialize(
        validatorSetProxy.address,
        owner.address,
        agora.address
    )
    await tx.wait()

    console.log("Initializing RandomAuRa")
    const randomProxyAccess = RandomAuRa.attach(randomProxy.address)
    tx = await randomProxyAccess.initialize(
        process.env.COLLECT_ROUND_LENGTH,
        validatorSetProxy.address,
        true
    )
    await tx.wait()

    let ids = []

    for (let i = 1; i <= initial_miners.length; i++) {
        ids.push(i)
    }


    console.log("Initializing StakingAuRa")
    const stakingProxyAccess = StakingAuRa.attach(stakingProxy.address)
    tx = await stakingProxyAccess.initialize(
        validatorSetProxy.address,
        governanceProxy.address,
        ids,
        process.env.DELEGATOR_MIN_STAKE,
        process.env.CANDIDATE_MIN_STAKE,
        process.env.EPOCH_DURATION,
        process.env.EPOCH_START_BLOCK,
        process.env.STAKE_WITHDRAWAL_DISALLOW_PERIOD
    )
    await tx.wait()

    console.log("Initializing Governance")
    const governanceProxyAccess = Governance.attach(governanceProxy.address)
    tx = await governanceProxyAccess.initialize(
        validatorSetProxy.address
    )
    await tx.wait()

    console.log("Initializing TxPermission")
    const txPermissionProxyAccess = TxPermission.attach(txPermissionProxy.address)
    tx = await txPermissionProxyAccess.initialize(
        [owner.address],
        certifierProxy.address,
        validatorSetProxy.address,
    )
    await tx.wait()

    console.log("Initializing Certifier")
    const certifierProxyAccess = Certifier.attach(certifierProxy.address)
    tx = await certifierProxyAccess.initialize(
        [owner.address],
        validatorSetProxy.address
    )
    await tx.wait()

    console.log("==> Setting POSDAO ownership to DAO multi-signature account")
    tx = await validatorSetProxy.changeAdmin(DAO_MULTISIG)
    await tx.wait()

    tx = await blockRewardProxy.changeAdmin(DAO_MULTISIG)
    await tx.wait()

    tx = await randomProxy.changeAdmin(DAO_MULTISIG)
    await tx.wait()

    tx = await stakingProxy.changeAdmin(DAO_MULTISIG)
    await tx.wait()

    tx = await governanceProxy.changeAdmin(DAO_MULTISIG)
    await tx.wait()

    tx = await txPermissionProxy.changeAdmin(DAO_MULTISIG)
    await tx.wait()

    tx = await certifierProxy.changeAdmin(DAO_MULTISIG)
    await tx.wait()

    tx = await registry.setOwner(DAO_MULTISIG)
    await tx.wait()

    console.log("\n Polis Governance Deployment Finished: \n")
    console.log("WETH:              ", weth.address)
    console.log("Drachma:           ", drachma.address)
    console.log("Agora:             ", agora.address)
    console.log("Timelock:          ", timelock.address)
    console.log("Parliament:        ", parliament.address)

    console.log("\n AuRa Deployment Finished: \n")
    console.log("Please add the following information to the chain spec json:")
    console.log("ValidatorAuRa:     ", validatorSetProxy.address)
    console.log("StakingAuRa:       ", stakingProxy.address)
    console.log("BlockRewardAuRa:   ", blockRewardProxy.address)
    console.log("TxPermission:      ", txPermissionProxy.address)
    console.log("Registry:          ", registry.address)
    console.log("Epoch Start Block: ", process.env.EPOCH_START_BLOCK)
    console.log("RandomAuRa:        ", randomProxy.address)
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });