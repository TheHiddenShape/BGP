HOST_DIR := host/
ROUTER_DIR := router/

HOST1_CONFIG := $(HOST_DIR)/host1.sh
HOST2_CONFIG := $(HOST_DIR)/host2.sh

ROUTER1_CONFIG := $(ROUTER_DIR)/router1.sh
ROUTER2_CONFIG := $(ROUTER_DIR)/router2.sh

static_mode:
	docker exec aschiffe_host_h1 bash -c "bash $(HOST1_CONFIG) static"
	docker exec aschiffe_host_h2 bash -c "bash $(HOST2_CONFIG) static"
	docker exec aschiffe_router_r1 bash -c "bash $(ROUTER1_CONFIG) static"
	docker exec aschiffe_router_r2 bash -c "bash $(ROUTER2_CONFIG) static"

dynamic_multicast_mode:
	docker exec aschiffe_host_h1 bash -c "bash $(HOST1_CONFIG) dynamic"
	docker exec aschiffe_host_h2 bash -c "bash $(HOST2_CONFIG) dynamic"
	docker exec aschiffe_router_r1 bash -c "bash $(ROUTER1_CONFIG) dynamic"
	docker exec aschiffe_router_r2 bash -c "bash $(ROUTER2_CONFIG) dynamic"

.PHONY: static_mode dynamic_multicast_mode