#!/bin/bash
#Temporary-scripts
#Author:Lzy

read -p "请输入需要初始化的机器ip " client_ip
read -p "请输入需要初始化的机器hostname " client_hostname

rpm -qa | grep expect || yum -y install expect
for i in $client_ip 
do
 expect << EOF
 spawn ssh-copy-id $i
 expect "password:" { send "123456\r" } 
 expect "password:" { send "123456\r" } 
EOF
done

echo "$client_ip $client_hostname" >> /etc/hosts

for i in $client_ip 
do
 scp  /etc/hosts   $i:/etc/
done


for i in $client_ip
do
 scp  /etc/yum.repos.d/ceph.repo   $i:/etc/yum.repos.d/
done

for i in $client_ip 
do
 scp /etc/chrony.conf $i:/etc/
 ssh  $i  "systemctl restart chronyd"
done

ssh $client_ip yum -y install ceph-common
scp /etc/ceph/ceph.c* $client_ip:/etc/ceph/





