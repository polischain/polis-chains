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
		-e NETHERMIND_CONFIG=sparta \
		-e NETHERMIND_MININGCONFIG_ENABLED=true \
		-e NETHERMIND_INITCONFIG_ISMINING=true \
		-e NETHERMIND_KEYSTORECONFIG_PASSWORDFILES=/nethermind/passwords/node.pwd \
		-e NETHERMIND_KEYSTORECONFIG_UNLOCKACCOUNTS=$(ACCOUNT) \
		-e NETHERMIND_KEYSTORECONFIG_BLOCKAUTHORACCOUNT=$(ACCOUNT) \
		-v /root/passwords/:/nethermind/passwords/ \
 		-v /root/nethermind_db/:/nethermind/nethermind_db/ \
 		-v /root/keystore/:/nethermind/keystore \
 		-v /root/logs/:/nethermind/logs/ \
 		ghcr.io/polischain/polis-chains:main

