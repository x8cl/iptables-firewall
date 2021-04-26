#!/bin/sh
#####VPN
##Aceptamos todo en tap_soft
iptables -A INPUT -i tap_soft -j ACCEPT
iptables -A OUTPUT -o tap_soft -j ACCEPT

##Aceptamos FORWARD tap_soft-eth0
iptables -A FORWARD -i tap_soft -o eth0 -j ACCEPT
iptables -A FORWARD -d 192.168.50.0/24 -i eth0 -o tap_soft -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT

#Acepto solo IPs del ipset "permitidas" para administración SoftEther TCP 4500 en eth0
iptables -A INPUT -i eth0 -m set --match-set permitidas src -m tcp -p tcp --dport 4500 -j ACCEPT

###IPsec
#Acepto IPs para IPSec ESP encryption and authentication
iptables -A INPUT -i eth0 -m set --match-set permitidas src -p 50 -j ACCEPT
#Acepto IPs para IPSec AH authentication header
#iptables -A INPUT -i eth0 -p 51 -j ACCEPT
#Acepto solo IPs del ipset "permitidas" para L2TP UDP 1701 en eth0
#iptables -A INPUT -i eth0 -m set --match-set permitidas src -m udp -p udp --dport 1701 -j ACCEPT

#Acepto solo IPs del ipset "permitidas" para IPSec UDP 500 en eth0
iptables -A INPUT -i eth0 -m set --match-set permitidas src -m udp -p udp --dport 500 -j ACCEPT
#Acepto solo IPs del ipset "permitidas" para IPSec UDP 4500 en eth0
iptables -A INPUT -i eth0 -m set --match-set permitidas src -m udp -p udp --dport 4500 -j ACCEPT

##NAT
iptables -t nat -A POSTROUTING -s 192.168.50.0/24 -o eth0 -j MASQUERADE
