#!/bin/bash

for container_id in $(docker ps -q); do
  node_type=$(docker inspect --format='{{ index .Config.Labels "node_type" }}' "$container_id")

  if [[ "$node_type" == "router" || "$node_type" == "host" ]]; then
    hostname=$(docker inspect --format='{{ .Config.Hostname }}' "$container_id")
    echo "Checking container $container_id with hostname '$hostname' and node_type '$node_type'"
    if [[ "$node_type" == "router" && "$hostname" =~ -1$ ]]; then
      echo "Container $container_id ($hostname): executing router-1 (leaf router) vxlan config"
      cat ./router/leaf_router1.sh | docker exec -i $container_id bash -s -- $mode
    elif [[ "$node_type" == "router" && "$hostname" =~ -2$ ]]; then
      echo "Container $container_id ($hostname): executing router-2 (leaf router) vxlan config"
      cat ./router/leaf_router2.sh | docker exec -i $container_id bash -s -- $mode
    elif [[ "$node_type" == "router" && "$hostname" =~ -3$ ]]; then
      echo "Container $container_id ($hostname): executing router-3 (leaf router) vxlan config"
      cat ./router/leaf_router3.sh | docker exec -i $container_id bash -s -- $mode
    elif [[ "$node_type" == "router" && "$hostname" =~ -4$ ]]; then
      echo "Container $container_id ($hostname): executing router-4 (spine router) vxlan config"
      cat ./router/spine_router4.sh | docker exec -i $container_id bash -s -- $mode
    elif [[ "$node_type" == "host" && "$hostname" =~ -1$ ]]; then
      echo "Container $container_id ($hostname): executing host-1 ip addr config"
      cat ./host/host1.sh | docker exec -i $container_id bash -s -- $mode
    elif [[ "$node_type" == "host" && "$hostname" =~ -2$ ]]; then
      echo "Container $container_id ($hostname): executing host-2 ip addr config"
      cat ./host/host2.sh | docker exec -i $container_id bash -s -- $mode
    elif [[ "$node_type" == "host" && "$hostname" =~ -3$ ]]; then
      echo "Container $container_id ($hostname): executing host-3 ip addr config"
      cat ./host/host3.sh | docker exec -i $container_id bash -s -- $mode
    else
      echo "Container $container_id ($hostname): hostname does not match -1 / -2 / -3 / -4 pattern"
    fi
  fi
done
