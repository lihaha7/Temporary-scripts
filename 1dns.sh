#!/bin/bash
#Temporary-scripts
#Author:Lzy

#$1为要解析的域名如"jc.com"
if [ $# -ne 1 ];then
	echo "./1dns 要解析的域名如dns.com"
	exit 2
fi
function cecho {
echo -e "\033[$1m$2\033[0m"
}

ip=`ifconfig | sed -n '2p' | awk '{print $2}'`

rpm -q bind bind-chroot &> /dev/null || cecho 31 "正在安装bind"
yum -y install bind bind-chroot &> /dev/null

##编辑主配置文件
cecho 31 "正在编辑主配置文件..."
#改动之前先备份一下主配置文件
\cp /etc/named.conf{,.bak}
sed  -i  "/listen-on port 53/s/127.0.0.1/$ip/" /etc/named.conf
sed  -i  "/allow-query/s/localhost/any/" /etc/named.conf
sed  -i  "/include/s/^include/#include/" /etc/named.conf
#sed  -i  "/^zone/s/\./$1/" /etc/named.conf
#sed  -i  "/type/s/hint/master/" /etc/named.conf
#sed  -i  "/file/s/named.ca/$1.zone/" /etc/named.conf
sed -i "52c #zone \"\.\" IN {" /etc/named.conf
#sed -i "53s/type hint/#type hint/" /etc/named.conf
#sed -i "54s/file/#file/" /etc/named.conf
sed -i "53c #       type hint;" /etc/named.conf
sed -i "54c #       file \"named.ca\";" /etc/named.conf
sed -i "55s/^}/#}/" /etc/named.conf
echo "zone \"$1\" IN {
        type master;
        file \"$1.zone\";
};" >> /etc/named.conf

sleep 2

##编辑地址库文件
cecho  31 "正在编辑地址库文件..."
cat /var/named/named.localhost | head -7 > /var/named/$1.zone
chown :named /var/named/$1.zone
echo "$1.         NS      dnsserver
dnsserver       A       $ip
www             A       $ip" >> /var/named/$1.zone
sleep 3

##启动服务
cecho 31  "正在启动服务..."
systemctl restart named &> /dev/null && cecho 32 "$1 success" || cecho 31  "$1 failed"

systemctl enable named &> /dev/null

grep "nameserver $ip" /etc/resolv.conf &> /dev/null   ||  echo "nameserver $ip" >> /etc/resolv.conf


