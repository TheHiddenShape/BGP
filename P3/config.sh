#!/bin/bash

SLEEP_CONVERGENCE=5

sleep_for_bgp_convergence() {
  local hostname=$1
  echo "Waiting $SLEEP_CONVERGENCE seconds for BGP to converge on $hostname..."
  sleep "$SLEEP_CONVERGENCE"
}

# SPINE CONFIG
for container_id in $(docker ps -q); do
  node_type=$(docker inspect --format='{{ index .Config.Labels "node_type" }}' "$container_id")
  hostname=$(docker inspect --format='{{ .Config.Hostname }}' "$container_id")

  if [[ "$node_type" == "router" && "$hostname" =~ -4$ ]]; then
    echo "Container $container_id ($hostname): executing router-4 (spine router) bgp evpn vxlan config"
    cat ./router/spine_router4.sh | docker exec -i $container_id bash -s
    sleep_for_bgp_convergence "$hostname"
  fi
done

# LEAFS CONFIG
for container_id in $(docker ps -q); do
  node_type=$(docker inspect --format='{{ index .Config.Labels "node_type" }}' "$container_id")
  hostname=$(docker inspect --format='{{ .Config.Hostname }}' "$container_id")

  if [[ "$node_type" == "router" ]]; then
    if [[ "$hostname" =~ -1$ ]]; then
      echo "Container $container_id ($hostname): executing router-1 (leaf router) bgp evpn vxlan config"
      cat ./router/leaf_router1.sh | docker exec -i $container_id bash -s
      sleep_for_bgp_convergence "$hostname"
    elif [[ "$hostname" =~ -2$ ]]; then
      echo "Container $container_id ($hostname): executing router-2 (leaf router) bgp evpn vxlan config"
      cat ./router/leaf_router2.sh | docker exec -i $container_id bash -s
      sleep_for_bgp_convergence "$hostname"
    elif [[ "$hostname" =~ -3$ ]]; then
      echo "Container $container_id ($hostname): executing router-3 (leaf router) bgp evpn vxlan config"
      cat ./router/leaf_router3.sh | docker exec -i $container_id bash -s
      sleep_for_bgp_convergence "$hostname"
    fi
  fi
done

# HOST CONFIG
for container_id in $(docker ps -q); do
  node_type=$(docker inspect --format='{{ index .Config.Labels "node_type" }}' "$container_id")
  hostname=$(docker inspect --format='{{ .Config.Hostname }}' "$container_id")

  if [[ "$node_type" == "host" ]]; then
    if [[ "$hostname" =~ -1$ ]]; then
      echo "Container $container_id ($hostname): executing host-1 ip addr config"
      cat ./host/host1.sh | docker exec -i $container_id bash -s
    elif [[ "$hostname" =~ -2$ ]]; then
      echo "Container $container_id ($hostname): executing host-2 ip addr config"
      cat ./host/host2.sh | docker exec -i $container_id bash -s
    elif [[ "$hostname" =~ -3$ ]]; then
      echo "Container $container_id ($hostname): executing host-3 ip addr config"
      cat ./host/host3.sh | docker exec -i $container_id bash -s
    fi
  fi
done
