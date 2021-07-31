sparta:
	@echo "==> Starting a Polis node with Sparta config"
	@docker run -d \
		-e NETHERMIND_CONFIG=sparta \
 		-v /root/nethermind_db/:/nethermind/nethermind_db/ \
 		-v /root/logs/:/nethermind/logs/ \
 		ghcr.io/polischain/polis-chains:main

sparta-rpc:
	@echo "==> Starting a Polis node with Sparta config and JSON RPC exposed"
	@docker run -d \
		-e NETHERMIND_CONFIG=sparta \
		-e NETHERMIND_JSONRPCCONFIG_ENABLED=true \
		-e NETHERMIND_JSONRPCCONFIG_HOST=0.0.0.0 \
		-p 8545:8545 \
 		-v /root/nethermind_db/:/nethermind/nethermind_db/ \
 		-v /root/logs/:/nethermind/logs/ \
 		ghcr.io/polischain/polis-chains:main

sparta-validator:
	@echo "==> Starting a Polis node with Sparta config and enabled for mining"
	@docker run -d \
		-e NETHERMIND_CONFIG=sparta \
		-e NETHERMIND_MININGCONFIG_ENABLED=true \
		-e NETHERMIND_KEYSTORECONFIG_PASSWORD_FILES=/nethermind/passwords/ \
		-e NETHERMIND_KEYSTORECONFIG_UNLOCK_ACCOUNTS=($ACCOUNT) \
		-e NETHERMIND_KEYSTORECONFIG_BLOCK_AUTHOR_ACCOUNT=($ACCOUNT) \
		-v /root/passwords/:/nethermind/passwords/ \
 		-v /root/nethermind_db/:/nethermind/nethermind_db/ \
 		-v /root/keystore/:/nethermind/keystore \
 		-v /root/logs/:/nethermind/logs/ \
 		ghcr.io/polischain/polis-chains:main

