# no ipv6 forwarding -> Disable IPv6 routing (IPv4 only configuration)

# interfaces ethX -> link to leaf N
# interfaces lo -> loopback BGP / OSPF

# router bgp 1 -> Configure BGP with AS number 1

## neighbor ibgp peer-group -> Create a peer group named ibgp for easier management of multiple BGP neighbors
## neighbor ibgp remote-as 1 -> All peers in this group belong to AS 1 (iBGP)
## neighbor ibgp update-source lo -> Use loopback as source IP for all BGP sessions in this peer group
## bgp listen range 1.1.1.0/29 peer-group ibgp -> Dynamically accept BGP connections from any IP in range 1.1.1.0-1.1.1.7 and assign them to ibgp peer group

## address-family l2vpn evpn -> Enter EVPN address family configuration mode
### neighbor ibgp activate -> Enable EVPN address family for all peers in the ibgp peer group
### neighbor ibgp route-reflector-client -> Configure this Spine as a Route Reflector for all ibgp peers (reflects EVPN routes between Leafs)

# router ospf -> Enable OSPF process for underlay routing
## network 0.0.0.0/0 area 0 -> Advertise all interfaces into OSPF area 0 (ensures loopback and all physical links are included)

vtysh <<-EOF
configure terminal
  no ipv6 forwarding

  interface eth0
    ip address 10.1.1.1/30
  exit

  interface eth1
    ip address 10.1.1.5/30
  exit

  interface eth2
    ip address 10.1.1.9/30
  exit

  interface lo
    ip address 1.1.1.1/32
  exit

  router bgp 1
    neighbor ibgp peer-group
    neighbor ibgp remote-as 1
    neighbor ibgp update-source lo
    bgp listen range 1.1.1.0/29 peer-group ibgp

    address-family l2vpn evpn
      neighbor ibgp activate
      neighbor ibgp route-reflector-client
    exit-address-family
  exit

  router ospf
    network 0.0.0.0/0 area 0
  exit
  
  line vty
  exit
EOF
