sparta:
	@echo "==> Starting a Polis node with Sparta config"
	@docker run \
		-e NETHERMIND_CONFIG=sparta \
 		-v /root/nethermind_db/:/nethermind/nethermind_db/ \
 		-v /root/logs/:/nethermind/logs/ \
 		ghcr.io/polischain/polis-chains:main

sparta-rpc:
	@echo "==> Starting a Polis node with Sparta config and JSON RPC exposed"
	@docker run \
		-e NETHERMIND_CONFIG=sparta \
		-e NETHERMIND_JSONRPCCONFIG_ENABLED=true \
		-e NETHERMIND_JSONRPCCONFIG_HOST=0.0.0.0 \
		-p 8545:8545 \
 		-v /root/nethermind_db/:/nethermind/nethermind_db/ \
 		-v /root/logs/:/nethermind/logs/ \
 		ghcr.io/polischain/polis-chains:main

sparta-validator:
	@echo "==> Starting a Polis node with Sparta config and enabled for mining"
	@docker run \
		-p 30303:30303 \
		-e NETHERMIND_CONFIG=sparta \
		-e NETHERMIND_INITCONFIG_ISMINING="true" \
		-e NETHERMIND_INITCONFIG_DISCOVERYENABLED="false" \
		-e NETHERMIND_MININGCONFIG_MINGASPRICE="100000000" \
		-e NETHERMIND_MININGCONFIG_TARGETBLOCKGASLIMIT="20000000" \
		-e NETHERMIND_KEYSTORECONFIG_TESTNODEKEY=$(KEY) \
		-e NETHERMIND_SYNCCONFIG_FASTSYNC="true" \
        -e NETHERMIND_SYNCCONFIG_FASTBLOCKS="true" \
        -e NETHERMIND_SYNCCONFIG_DOWNLOADBODIESINFASTSYNC="false" \
        -e NETHERMIND_SYNCCONFIG_DOWNLOADRECEIPTSINFASTSYNC="false" \
		-v /root/polis-chains/configs/sparta/static-nodes.json:/nethermind/Data/static-nodes.json \
		-v /root/passwords/:/nethermind/passwords/ \
 		-v /root/nethermind_db/:/nethermind/nethermind_db/ \
 		-v /root/keystore/:/nethermind/keystore \
 		-v /root/logs/:/nethermind/logs/ \
 		ghcr.io/polischain/polis-chains:main

