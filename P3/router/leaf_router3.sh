ip link add br0 type bridge
ip link set dev br0 up
ip link add vxlan10 type vxlan id 10 dstport 4789
ip link set dev vxlan10 up
brctl addif br0 vxlan10
brctl addif br0 eth0

# no ipv6 forwarding -> Disable IPv6 routing (IPv4 only configuration)

# router bgp 1 -> Configure BGP with AS number 1

## neighbor 1.1.1.1 remote-as 1 -> Establish a BGP session with the router whose IP address is 1.1.1.1, which belongs to Autonomous System (AS) number 1
## neighbor 1.1.1.1 update-source lo -> Use the IP address of the loopback interface (lo) as the source address to establish the BGP TCP connection to this neighbor

## address-family l2vpn evpn -> Enter EVPN address family configuration mode for Layer 2 VPN over BGP
### neighbor 1.1.1.1 activate -> Enable EVPN address family for this BGP neighbor
### advertise-all-vni -> Automatically advertise all locally configured VNIs via EVPN (Type 3 IMET routes)

# router ospf -> Enable OSPF process for underlay IP connectivity

vtysh <<-EOF
configure terminal
  no ipv6 forwarding

  interface eth2
    ip address 10.1.1.10/30
    ip ospf area 0
  exit

  interface lo
    ip address 1.1.1.4/32
    ip ospf area 0
  exit

  router bgp 1
    neighbor 1.1.1.1 remote-as 1
    neighbor 1.1.1.1 update-source lo

    address-family l2vpn evpn 
      neighbor 1.1.1.1 activate
      advertise-all-vni
    exit-address-family
  exit

  router ospf
  exit
EOF
