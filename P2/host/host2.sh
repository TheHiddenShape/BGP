#!/bin/bash
ip addr add 30.1.1.2/24 dev eth1
ip link set dev eth1 mtu 1450
