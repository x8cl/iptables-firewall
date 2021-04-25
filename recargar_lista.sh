#!/bin/sh
###Descargar el archivo desde iblocklist
echo "Descargando el archivo desde iblocklist..."
curl -L -A "Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:59.0) Gecko/20100101 Firefox/59.0" "http://list.iblocklist.com/?list=qssnpurblcxquvmnepba&fileformat=cidr&archiveformat=gz&username=netvoiss&pin=913915" | gunzip | grep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' > iblocklist.zone

###Descargar el archivo otras.zone
echo "Descargando el archivo otras.zone..."
curl "https://datacenter.netvoiss.cl/firewall/lista_blanca/otras.zone" | grep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' > otras.zone

###IPSET by MAB
echo "Limpiando el ipset \"permitidas\"..."
ipset flush permitidas
echo "Agregando IPs permitidas al ipset \"permitidas\"..."
for IP in $(cat /root/firewall/*.zone | grep -v \# | grep -v '^[[:space:]]*$') ; do ipset -A permitidas $IP -exist ; done
