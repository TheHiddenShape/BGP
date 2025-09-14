#!/bin/bash
mode="$1"

ip link add br0 type bridge
ip link set dev br0 up

ip addr add 10.1.1.2/24 dev eth0
# ip addr show eth0

if [ "$1" = "static" ]; then
    ip link add name vxlan10 type vxlan id 10 dev eth0 remote 10.1.1.1 local 10.1.1.2 dstport 4789
elif [ "$1" = "dynamic" ]; then
    ip link add name vxlan10 type vxlan id 10 dev eth0 group 239.1.1.1 dstport 4789
else
    echo "Unknown mode: $1"
    exit 1
fi

ip addr add 20.1.1.2/24 dev vxlan10
# ip -d link show vxlan10

brctl addif br0 eth1
brctl addif br0 vxlan10
ip link set dev vxlan10 up