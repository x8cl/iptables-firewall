#!/bin/sh
###Descargar el archivo desde iblocklist
echo "Descargando el archivo desde iblocklist..."
##Gratis (P2P/gz) Chile
curl -L 'http://list.iblocklist.com/?list=cl&fileformat=p2p&archiveformat=gz' | gunzip | grep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | awk -F ':' '{print $2}' > cl.zone
##Pagado (CIDR/gz)
#curl -L -A "Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:59.0) Gecko/20100101 Firefox/59.0" "http://list.iblocklist.com/?list=qssnpurblcxquvmnepba&fileformat=cidr&archiveformat=gz&username=netvoiss&pin=913915" | gunzip | grep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' > iblocklist.zone

###Descargar el archivo otras.zone
#echo "Descargando el archivo otras.zone..."
#curl "https://datacenter.netvoiss.cl/firewall/lista_blanca/otras.zone" | grep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' > otras.zone

###IPSET by MAB
echo "Creando ipset \"temporal\"..."
ipset create temporal hash:net
echo "Agregando IPs permitidas al ipset \"temporal\"..."
for IP in $(cat /root/firewall/*.zone | grep -v \# | grep -v '^[[:space:]]*$') ; do ipset -A temporal $IP -exist ; done
echo "Creando el ipset \"permitidas\"..."
ipset create permitidas hash:net -exist
echo "Volacando las IPs del ipset \"temporal\" al ipset \"permitidas\"..."
ipset swap permitidas temporal
echo "Eliminando el ipset \"temporal\"..."
ipset destroy temporal

###IPTables By MAB
##Limpiando Reglas anteriores
echo "Limpiando Reglas de Firewall ipv4..."
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X
iptables -t filter -F
iptables -t filter -X
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT

##Creando nuevas POLICY con DROP
echo "Aplicando POLICY DROP por defecto ipv4..."
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

##Creando nuevas reglas del firewall
echo "Aplicando Reglas de Firewall ipv4..."
##Aceptamos todo en loopback
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

##Aceptamos todo en ens256 (LAN)
iptables -A INPUT -i ens265 -j ACCEPT
iptables -A OUTPUT -o ens256 -j ACCEPT

##DNS
##Aceptamos DNS1
#iptables -A INPUT -s 8.8.8.8 -p udp -m udp --sport 53 -m state --state ESTABLISHED -j ACCEPT
##Aceptamos DNS2
#iptables -A INPUT -s 8.8.4.4 -p udp -m udp --sport 53 -m state --state ESTABLISHED -j ACCEPT

##PING
##Acepto ping (reply) hacia el exterior
iptables -A INPUT -p icmp --icmp-type echo-reply -m state --state ESTABLISHED,RELATED -j ACCEPT
##Aceptamos respuesta a las conexiones ya establecidas
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
#Acepto solo IPs del ipset "permitidas" para Ping
iptables -A INPUT -m set --match-set permitidas src -p icmp --icmp-type echo-request -j ACCEPT

##Abrimos puertos de los servicios
#Acepto solo IPs del ipset "permitidas" para SSH TCP 10041
iptables -A INPUT -m set --match-set permitidas src -m tcp -p tcp --dport 10041 -j ACCEPT
#Acepto solo IPs del ipset "permitidas" para SIP en UDP 5060 en eth0
#iptables -A INPUT -m set --match-set permitidas src -m udp -p udp --dport 5060 -j ACCEPT
#Acepto paquetes RTP de cualquir parte en UDP 10000:20000 en eth0
#iptables -A INPUT -m udp -p udp --dport 10000:20000 -j ACCEPT

##IPv6
echo "Limpiando Reglas de Firewall ipv6..."
ip6tables -F
ip6tables -X
ip6tables -t nat -F
ip6tables -t nat -X
ip6tables -t mangle -F
ip6tables -t mangle -X
ip6tables -t filter -F
ip6tables -t filter -X
ip6tables -P INPUT ACCEPT
ip6tables -P FORWARD ACCEPT
ip6tables -P OUTPUT ACCEPT

#echo "Aplicando POLICY DROP por defecto ipv6..."
ip6tables -P INPUT DROP
ip6tables -P FORWARD DROP
ip6tables -P OUTPUT ACCEPT

##Creando nuevas reglas del firewall
echo "Aplicando Reglas de Firewall ipv6..."
##Aceptamos todo en loopback
ip6tables -A INPUT -i lo -j ACCEPT
ip6tables -A OUTPUT -o lo -j ACCEPT
