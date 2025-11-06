# BGP EVPN VXLAN
This project is divided into three parts: Part 1 covers GNS3 configuration with Docker, Part 2 explores VXLAN, and Part 3 focuses on discovering BGP with EVPN.

You can find the complete documentation for this project at https://ammons-organization-1.gitbook.io/thehiddenshape/system-and-networks/building-networks-with-gns3

The purpose of this README is to compile useful commands and demonstrations, along with the associated concepts for each part.

## GNS3 configuration with Docker
The first step is to configure our foundation machines, which will serve as the base for building our networks.
We will need hosts and routers running FRRouting (FRR), an open-source routing protocol suite for Linux/Unix systems that implements various protocols such as BGP, OSPF and more.

set up: https://ammons-organization-1.gitbook.io/thehiddenshape/system-and-networks/building-networks-with-gns3#gns3-configuration-with-docker

> router instance, this list shows essentially the FRR (Free Range Routing)  routing daemons and supporting scripts.
```bash
/ # ps
PID   USER     COMMAND
    1 root     /sbin/tini -- /usr/lib/frr/docker-start
  310 root     /gns3/bin/busybox sh -c while true; do TERM=vt100 /gns3/bin/busy
  316 root     /gns3/bin/busybox sh
  330 root     {docker-start} /bin/bash /usr/lib/frr/docker-start
  339 root     /usr/lib/frr/watchfrr zebra bgpd ospfd isisd staticd
  355 frr      /usr/lib/frr/zebra -d -F traditional -A 127.0.0.1 -s 90000000
  360 frr      /usr/lib/frr/bgpd -d -F traditional -A 127.0.0.1
  367 frr      /usr/lib/frr/ospfd -d -F traditional -A 127.0.0.1
  370 frr      /usr/lib/frr/isisd -d -F traditional -A 127.0.0.1
  373 frr      /usr/lib/frr/staticd -d -F traditional -A 127.0.0.1
  377 root     {ps} /gns3/bin/busybox sh
```
> host instance, busybox is a lightweight collection of Unix utilities bundled into a single executable, often used in embedded systems and minimal environments.
```bash
/ # ps
PID   USER     COMMAND
    1 root     /bin/sh
  309 root     /gns3/bin/busybox sh -c while true; do TERM=vt100 /gns3/bin/busy
  315 root     /gns3/bin/busybox sh
  322 root     {ps} /gns3/bin/busybox sh
```

## Discovering a VXLAN
In this section, we set up a VXLAN (Virtual Extensible LAN) network topology. VXLAN is a tunneling technology that allows the creation of extended virtual local area networks (VLANs) over existing IP infrastructures. VXLAN encapsulates Layer 2 Ethernet frames within Layer 3 UDP packets, creating an overlay network that tunnels L2 traffic over an L3 underlay infrastructure, enabling scalable multi-tenant isolation across data centers by adding a 24-bit VXLAN Network Identifier (VNI) header.

Our topology contains two remote hosts, each connected to their own router, with an L2 switch between the routers.

set up: https://ammons-organization-1.gitbook.io/thehiddenshape/system-and-networks/building-networks-with-gns3#discovering-a-vxlan

### Packet transmission
>host instance
```bash
# ping host 2 from host 1
/ # ping 30.1.1.2
PING 30.1.1.2 (30.1.1.2): 56 data bytes
64 bytes from 30.1.1.2: seq=0 ttl=64 time=0.325 ms
64 bytes from 30.1.1.2: seq=1 ttl=64 time=1.441 ms

# check learned MAC addr, this cmd displays the ARP/NDP cache
/ # ip neigh show
30.1.1.2 dev eth1 lladdr 02:42:2a:1f:32:01 used 0/0/0 probes 4 STALE
```

### VXLAN setup
> VTEP instance
```bash
# vxlan details
ip -d link show vxlan10
# VNI & params
bridge fdb show dev vxlan10
```
### Forwarding table
> VTEP instance
```bash
# show FDB
bridge fdb show dev vxlan10
# learned MAC addr
bridge fdb show | grep <VNI>
```

## Discovering BGP with EVPN
In this section, we will deploy a BGP EVPN with VXLAN solution in a Spine-Leaf architecture. 1 RR, 3 leafs, each associated with 1 host.

BGP EVPN (Ethernet VPN) is a control plane protocol that uses MP-BGP (Multi-Protocol BGP) to distribute MAC addresses, IP addresses, and other reachability information for overlay networks (typically VXLAN).

> In any VTEP instance, we ensure visibility of other VTEPs by identifying them through their loopback interface identifiers.
```bash
/ # vtysh -c "show ip route"
O>* 1.1.1.1/32 [110/10] via 10.1.1.1, eth0, weight 1, 00:00:18
O   1.1.1.2/32 [110/0] is directly connected, lo, weight 1, 00:01:08
C>* 1.1.1.2/32 is directly connected, lo, 00:01:08
O>* 1.1.1.3/32 [110/20] via 10.1.1.1, eth0, weight 1, 00:00:18
O>* 1.1.1.4/32 [110/20] via 10.1.1.1, eth0, weight 1, 00:00:18
O   10.1.1.0/30 [110/10] is directly connected, eth0, weight 1, 00:01:08
C>* 10.1.1.0/30 is directly connected, eth0, 00:01:08
O>* 10.1.1.4/30 [110/20] via 10.1.1.1, eth0, weight 1, 00:00:18
O>* 10.1.1.8/30 [110/20] via 10.1.1.1, eth0, weight 1, 00:00:18
```
For a network with N VTEPs, the total number of BGP connections required in a **full mesh** (i.e., without RR) is given by the following formula:

$$
C = \frac{n(n-1)}{2}
$$

Where n is the total number of nodes and C is the number of unique links, this results in exponential growth of BGP sessions, causing scalability issues and higher resource overhead.

In order to generate a summary of the current bgp session & checking the state of our BGP pairs we use the following command

```bash
/ # vtysh -c "show bgp summary"
```

This command allows us to check the BGP EVPN table, the routes used for VXLAN/L2VPN routing
```bash
/ # vtysh -c "show bgp l2vpn evpn"
```
set up configuration: https://ammons-organization-1.gitbook.io/thehiddenshape/system-and-networks/building-networks-with-gns3#discovering-bgp-with-evpn
