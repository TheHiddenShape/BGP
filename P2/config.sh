#!/bin/bash
mode="$1"

if [ "$#" -ne 1 ]; then
  echo "You should provide mode arg."
  exit 1
fi

for container_id in $(docker ps -q); do
  node_type=$(docker inspect --format='{{ index .Config.Labels "node_type" }}' "$container_id")

  if [[ "$node_type" == "router" || "$node_type" == "host" ]]; then
    hostname=$(docker inspect --format='{{ .Config.Hostname }}' "$container_id")
    echo "Checking container $container_id with hostname '$hostname' and node_type '$node_type'"
    if [[ "$node_type" == "router" && "$hostname" =~ -1$ ]]; then
      echo "Container $container_id ($hostname): executing router-1 vxlan config"
      cat /router/router1.sh | docker exec -i $container_id bash -s -- $mode
    elif [[ "$node_type" == "router" && "$hostname" =~ -2$ ]]; then
      echo "Container $container_id ($hostname): executing router-2 vxlan config"
      cat /router/router2.sh | docker exec -i $container_id bash -s -- $mode
    elif [[ "$node_type" == "host" && "$hostname" =~ -1$ ]]; then
      echo "Container $container_id ($hostname): executing host-1 ip addr config"
      cat /host/host1.sh | docker exec -i $container_id bash -s -- $mode
    elif [[ "$node_type" == "host" && "$hostname" =~ -2$ ]]; then
      echo "Container $container_id ($hostname): executing host-2 ip addr config"
      cat /host/host2.sh | docker exec -i $container_id bash -s -- $mode
    else
      echo "Container $container_id ($hostname): hostname does not match -1 or -2 pattern"
    fi
  fi
done
