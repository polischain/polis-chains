const hre = require("hardhat");

const DAO_MULTISIG = process.env.DAO_MULTISIG;
const AGORA = process.env.AGORA;

async function main() {
    const [owner] = await hre.ethers.getSigners();

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

    const ValidatorSetAuRa = await hre.ethers.getContractFactory("ValidatorSetAuRa");
    const BlockRewardAuRa = await hre.ethers.getContractFactory("BlockRewardAuRa");
    const RandomAuRa = await hre.ethers.getContractFactory("RandomAuRa");
    const StakingAuRa = await hre.ethers.getContractFactory("StakingAuRa");
    const Governance = await hre.ethers.getContractFactory("Governance");
    const TxPermission = await hre.ethers.getContractFactory("TxPermission");
    const Certifier = await hre.ethers.getContractFactory("Certifier");
    const Registry = await hre.ethers.getContractFactory("Registry");

    const Proxy = await hre.ethers.getContractFactory("AdminUpgradeabilityProxy");

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
    let tx = await validatorSetProxyAccess.initialize(
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
        AGORA
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