#!/bin/sh
###Descargar el archivo desde iblocklist
echo "Descargando el archivo desde iblocklist..."
curl -L -A "Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:59.0) Gecko/20100101 Firefox/59.0" "http://list.iblocklist.com/?list=qssnpurblcxquvmnepba&fileformat=cidr&archiveformat=gz&username=netvoiss&pin=913915" | gunzip | grep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' > iblocklist.zone

###Descargar el archivo otras.zone
echo "Descargando el archivo otras.zone..."
curl "https://datacenter.netvoiss.cl/firewall/lista_blanca/otras.zone" | grep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' > otras.zone

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

##Aceptamos todo en eth3
iptables -A INPUT -i eth3 -j ACCEPT
iptables -A OUTPUT -o eth3 -j ACCEPT

##Aceptamos todo en eth4
iptables -A INPUT -i eth4 -j ACCEPT
iptables -A OUTPUT -o eth4 -j ACCEPT

##Aceptamos DNS1
iptables -A INPUT -s 8.8.8.8 -p udp -m udp --sport 53 -m state --state ESTABLISHED -j ACCEPT

##Aceptamos DNS2
iptables -A INPUT -s 8.8.4.4 -p udp -m udp --sport 53 -m state --state ESTABLISHED -j ACCEPT

##Acepto ping (reply) hacia el exterior
#iptables -A INPUT -p icmp --icmp-type echo-reply -m state --state ESTABLISHED,RELATED -j ACCEPT

##Aceptamos respuesta a las conexiones ya establecidas en eth0
iptables -A INPUT -i eth0 -m state --state ESTABLISHED,RELATED -j ACCEPT

##Abrimos puertos de los servicios
#Acepto Ping desde "permitidas" en eth0
iptables -A INPUT -i eth0 -m set --match-set permitidas src -p icmp --icmp-type echo-request -j ACCEPT
#Acepto solo IPs del ipset "permitidas" para SSH TCP 10041 en eth0
iptables -A INPUT -i eth0 -m set --match-set permitidas src -m tcp -p tcp --dport 10041 -j ACCEPT
#Acepto solo IPs del ipset "permitidas" para SIP en UDP 5060 en eth0
iptables -A INPUT -i eth0 -m set --match-set permitidas src -m udp -p udp --dport 5060 -j ACCEPT
#Acepto paquetes RTP de cualquir parte en UDP 10000:20000 en eth0
iptables -A INPUT -i eth0 -m udp -p udp --dport 10000:20000 -j ACCEPT
#Acepto solo IPs del ipset "permiItidas" para HTTP TCP 11180 en eth0
iptables -A INPUT -i eth0 -m set --match-set permitidas src -m tcp -p tcp --dport 11180 -j ACCEPT

##Paranoico en eth0(esto ya esta cubierto por la policy INPUT DROP)
iptables -A INPUT -i eth0 -j DROP


##IPv6
#echo "Limpiando Reglas de Firewall ipv6..."
#ip6tables -F
#ip6tables -X
#ip6tables -t nat -F
#ip6tables -t nat -X
#ip6tables -t mangle -F
#ip6tables -t mangle -X
#ip6tables -t filter -F
#ip6tables -t filter -X
#ip6tables -P INPUT ACCEPT
#ip6tables -P FORWARD ACCEPT
#ip6tables -P OUTPUT ACCEPT

#echo "Aplicando POLICY DROP por defecto ipv6..."
#ip6tables -P INPUT DROP
#ip6tables -P FORWARD DROP
#ip6tables -P OUTPUT ACCEPT

##Creando nuevas reglas del firewall
#echo "Aplicando Reglas de Firewall ipv6..."
##Aceptamos todo en loopback
#ip6tables -A INPUT -i lo -j ACCEPT
#ip6tables -A OUTPUT -o lo -j ACCEPT
