#!/bin/bash
#Temporary-scripts
#Author:Lzy

read -p "输入ip 如:50 " ip
tar -xf redis-4.0.8.tar.gz
cd redis-4.0.8/
yum -y install gcc
rpm -qa | grep expect || yum -y install expect

make && make install
cd /root/redis-4.0.8/utils/

expect << EOF
spawn /root/redis-4.0.8/utils/install_server.sh
 expect "instance:" { send "63$ip\r" } 
 expect "file name" { send "\r" } 
 expect "file name" { send "\r" } 
 expect "this instance" { send "\r" } 
 expect "executable path" { send "\r" } 
 expect "abort" { send "\r" } 
 expect "abort." { send "\r" } 
EOF

/etc/init.d/redis_63$ip stop
sed -i "70s/bind 127.0.0.1/bind 192.168.4.$ip/" /etc/redis/63$ip\.conf
sed -i "43 c \$CLIEXEC -p 63$ip -h 192.168.4.$ip shutdown" /etc/init.d/redis_63$ip
#pkill redis
#/etc/init.d/redis_63$ip start
#/etc/init.d/redis_63$ip stop
/etc/init.d/redis_63$ip start

netstat -lnput | grep 63$ip
