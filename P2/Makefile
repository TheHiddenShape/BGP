HOST_DIR := host/
ROUTER_DIR := router/

HOST1_CONFIG := $(HOST_DIR)/host1.sh
HOST2_CONFIG := $(HOST_DIR)/host2.sh

ROUTER1_CONFIG := $(ROUTER_DIR)/router1.sh
ROUTER2_CONFIG := $(ROUTER_DIR)/router2.sh

run_config:
	@read -p "vxlan mode: " vmode; \
	bash config.sh $$vmode

.PHONY: run_config
