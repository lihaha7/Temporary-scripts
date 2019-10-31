#!/bin/bash
#Temporary-scripts
#Author:Lzy

read -p "输入ip 如50 " ip


/etc/init.d/redis_63$ip stop

sed -i "s/# cluster-enabled yes/cluster-enabled yes/" /etc/redis/63$ip\.conf
sed -i "s/# cluster-config-file nodes-6379.conf/cluster-config-file nodes-6379.conf/" /etc/redis/63$ip\.conf
sed -i "s/# cluster-node-timeout 15000/cluster-node-timeout 5000/" /etc/redis/63$ip\.conf

/etc/init.d/redis_63$ip start 
netstat -anput  | grep 63


