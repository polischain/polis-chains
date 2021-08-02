sparta-explorer:
	@echo "==> Starting a Polis Explorer with its own node and database"

	@echo "==> Installing Rust"
	curl https://sh.rustup.rs -sSf | sh -s -- -y &> /dev/null

	@echo "==> Installing Node"
	curl --silent https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash &> /dev/null
	source ~/.bashrc
	nvm install 14.17.0 &> /dev/null
	@echo "==> Installing Elixir"
	@echo "==> Installing Erlang"
	@docker run -d \
    		-e NETHERMIND_CONFIG=sparta \
    		-e NETHERMIND_INITCONFIG_WEBSOCKETSENABLED=true \
    		-e NETHERMIND_JSONRPCCONFIG_WEBSOCKETSPORT=8546 \
    		-e NETHERMIND_JSONRPCCONFIG_ENABLEDMODULES=eth,subscribe,trace,txpool,web3,proof,net,parity,health \
    		-e NETHERMIND_JSONRPCCONFIG_ENABLED=true \
    		-e NETHERMIND_JSONRPCCONFIG_HOST=127.0.0.1 \
    		-p 8545:8545 \
    		-p 8546:8546 \
    		-v /root/polis-chains/configs/sparta/static-nodes.json:/nethermind/Data/static-nodes.json \
     		-v /root/nethermind_db/:/nethermind/nethermind_db/ \
     		-v /root/logs/:/nethermind/logs/ \
     		ghcr.io/polischain/polis-chains:main

sparta:
	@echo "==> Starting a Polis node with Sparta config"
	@docker run -d \
		-e NETHERMIND_CONFIG=sparta \
		-v /root/polis-chains/configs/sparta/static-nodes.json:/nethermind/Data/static-nodes.json \
 		-v /root/nethermind_db/:/nethermind/nethermind_db/ \
 		-v /root/logs/:/nethermind/logs/ \
 		-e NETHERMIND_MININGCONFIG_MINGASPRICE="1000000000" \
 		ghcr.io/polischain/polis-chains:main

sparta-rpc:
	@echo "==> Starting a Polis node with Sparta config and JSON RPC exposed"
	@docker run -d \
		-e NETHERMIND_CONFIG=sparta \
		-e NETHERMIND_INITCONFIG_WEBSOCKETSENABLED=true \
		-e NETHERMIND_JSONRPCCONFIG_WEBSOCKETSPORT=8546 \
		-e NETHERMIND_JSONRPCCONFIG_ENABLEDMODULES=eth,subscribe,trace,txpool,web3,proof,net,parity,health \
		-e NETHERMIND_JSONRPCCONFIG_ENABLED=true \
		-e NETHERMIND_JSONRPCCONFIG_HOST=127.0.0.1 \
		-p 8545:8545 \
		-p 8546:8546 \
		-v /root/polis-chains/configs/sparta/static-nodes.json:/nethermind/Data/static-nodes.json \
 		-v /root/nethermind_db/:/nethermind/nethermind_db/ \
 		-v /root/logs/:/nethermind/logs/ \
 		ghcr.io/polischain/polis-chains:main

sparta-validator:
	@echo "==> Starting a Polis node with Sparta config and enabled for mining"
	@docker run -d \
		-p 30303:30303 \
		-e NETHERMIND_CONFIG=sparta \
		-e NETHERMIND_INITCONFIG_ISMINING="true" \
		-e NETHERMIND_MININGCONFIG_ENABLED="true" \
		-e NETHERMIND_MININGCONFIG_MINGASPRICE="1000000000" \
		-e NETHERMIND_MININGCONFIG_TARGETBLOCKGASLIMIT="20000000" \
		-e NETHERMIND_KEYSTORECONFIG_BLOCKAUTHORACCOUNT=$(ACCOUNT) \
		-e NETHERMIND_KEYSTORECONFIG_UNLOCKACCOUNTS=$(ACCOUNT) \
		-e NETHERMIND_KEYSTORECONFIG_PASSWORDFILES=/nethermind/passwords/node.pwd \
		-v /root/polis-chains/configs/sparta/static-nodes.json:/nethermind/Data/static-nodes.json \
		-v /root/passwords/:/nethermind/passwords/ \
 		-v /root/nethermind_db/:/nethermind/nethermind_db/ \
 		-v /root/keystore/:/nethermind/keystore \
 		-v /root/logs/:/nethermind/logs/ \
 		ghcr.io/polischain/polis-chains:main

