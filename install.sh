#!/bin/bash
apt-get update
#apt-get upgrade -y
apt-get install -y \
  apache2 \
  php7.0 \
  php7.0-sqlite \
  php7.0-gd \
  php7.0-mbstring \
  libapache2-mod-php7.0
systemctl restart apache2

iptables -F
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -j ACCEPT

iptables -A OUTPUT -i lo -j ACCEPT
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP

iptables-save
