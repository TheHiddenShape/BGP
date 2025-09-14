HOST_DIR := host/
ROUTER_DIR := router/

HOST1_CONFIG := $(HOST_DIR)/host1.sh
HOST2_CONFIG := $(HOST_DIR)/host2.sh

ROUTER1_CONFIG := $(ROUTER_DIR)/router1.sh
ROUTER2_CONFIG := $(ROUTER_DIR)/router2.sh

static_mode:
	@read -p "Container ID for host_h1: " ch1; \
	docker exec $$ch1 bash -c "bash $(HOST1_CONFIG) static"
	@read -p "Container ID for host_h2: " ch2; \
	docker exec $$ch2 bash -c "bash $(HOST2_CONFIG) static"
	@read -p "Container ID for router_r1: " cr1; \
	docker exec $$cr1 bash -c "bash $(ROUTER1_CONFIG) static"
	@read -p "Container ID for router_r2: " cr2; \
	docker exec $$cr2 bash -c "bash $(ROUTER2_CONFIG) static"

dynamic_multicast_mode:
	@read -p "Container ID for host_h1: " ch1; \
	docker exec $$ch1 bash -c "bash $(HOST1_CONFIG) dynamic"
	@read -p "Container ID for host_h2: " ch2; \
	docker exec $$ch2 bash -c "bash $(HOST2_CONFIG) dynamic"
	@read -p "Container ID for router_r1: " cr1; \
	docker exec $$cr1 bash -c "bash $(ROUTER1_CONFIG) dynamic"
	@read -p "Container ID for router_r2: " cr2; \
	docker exec $$cr2 bash -c "bash $(ROUTER2_CONFIG) dynamic"

.PHONY: static_mode dynamic_multicast_mode
