# iptables-firewall
Un simple script en bash que permite mediante curl, ipset e iptables descargar listas de IPs para bloquear TODO en un principio y luego abrir los puertos, por servicio y por lista de IPs (individuales, segmentos, listas de paises)

Uso:
1. descargar el archivo (Ej: /root/firewall/firewall.sh)
2. editar archivo /root/firewall/firewall.sh y verificar que al menos el puerto SSH esté permitido (IMPORTANTE!!!)
3. chmod +x /root/firewall/firewall.sh
4. 

2.- cambiar permisos
chmod +x /root/firewall/firewall.sh

3.- editar archivo /root/firewall/firewall.sh y verificar que al menos el puerto SSH esté permitido (IMPORTANTE!!!)

4.- editar crond
crontab -e

5.- agragar
0 0 * * * sh /root/firewall/firewall.sh >/dev/null 2>&1
