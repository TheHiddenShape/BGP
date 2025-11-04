#!/bin/bash

MAX_RETRIES=5
RETRY_INTERVAL=30

check_bgp_status() {
  local container_id=$1
  local hostname=$2
  
  echo "Checking BGP status on $hostname..."

  for ((attempt=1; attempt<=MAX_RETRIES; attempt++)); do
    bgp_summary=$(docker exec -i "$container_id" vtysh -c "show bgp summary" 2>/dev/null)
    if echo "$bgp_summary" | grep -q "Established"; then
      echo "BGP is UP on $hostname."
      return 0
    else
      echo "Attempt $attempt/$MAX_RETRIES: BGP not established yet on $hostname."
      if (( attempt < MAX_RETRIES )); then
        sleep "$RETRY_INTERVAL"
      fi
    fi
  done

  echo "BGP did not come up on $hostname after $MAX_RETRIES attempts."
  return 1
}

# SPINE CONFIG
for container_id in $(docker ps -q); do
  node_type=$(docker inspect --format='{{ index .Config.Labels "node_type" }}' "$container_id")
  hostname=$(docker inspect --format='{{ .Config.Hostname }}' "$container_id")

  if [[ "$node_type" == "router" && "$hostname" =~ -4$ ]]; then
    echo "Container $container_id ($hostname): executing router-4 (spine router) bgp evpn vxlan config"
    cat ./router/spine_router4.sh | docker exec -i $container_id bash -s
    check_bgp_status "$container_id" "$hostname" || exit 1
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
      check_bgp_status "$container_id" "$hostname" || exit 1
    elif [[ "$hostname" =~ -2$ ]]; then
      echo "Container $container_id ($hostname): executing router-2 (leaf router) bgp evpn vxlan config"
      cat ./router/leaf_router2.sh | docker exec -i $container_id bash -s
      check_bgp_status "$container_id" "$hostname" || exit 1
    elif [[ "$hostname" =~ -3$ ]]; then
      echo "Container $container_id ($hostname): executing router-3 (leaf router) bgp evpn vxlan config"
      cat ./router/leaf_router3.sh | docker exec -i $container_id bash -s
      check_bgp_status "$container_id" "$hostname" || exit 1
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
