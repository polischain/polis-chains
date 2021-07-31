sparta-rpc:
	@echo "==> Starting nethermind"
	@docker run -d --name $(NODE_CONTAINER_NAME) ghcr.io/polischain/nodes-dockerized:main \
		-v ./nethermind_db/:/nethermind/nethermind_db/ \
		-v ./keystore/:/nethermind/keystore/ \
		-v ./logs/:/nethermind/logs/ \
		/bin/sh -c "--config sparta"