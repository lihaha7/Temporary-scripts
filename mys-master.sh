#!/bin/bash
#Temporary-scripts
#Author:Lzy


#if [ -f /root/mysql-5.7.17.tar  ];then
#                [ -d /root/mysql-5.7.17 ] || mkdir /root/mysql-5.7.17
#                echo -e "\033[1;34m正在解压文件,请稍后...\033[0m"
#                tar -xf /root/mysql-5.7.17.tar -C /root/mysql-5.7.17
#                echo -e "\033[1;34m正在安装MySQL,请稍后...\033[0m"
#                yum -y localinstall /root/mysql-5.7.17/mysql-community-* &> /dev/null
#                echo -e "\033[1;34m正在启动MySQL,请稍后...\033[0m"
#                systemctl restart mysqld
#
#fi
#
#echo -e "\033[1;36m正在初始化.密码为123qqq...A\033[0m"
#echo "SET PASSWORD  = PASSWORD('123qqq...A');" | mysql -u root --password=$(grep 'password is' /var/log/mysqld.log | awk '{print $11}') -b --connect-expired-password &> /dev/null
#
master_id=master$(hostname | awk -F'.' '{print $1}' | sed  -r  's/(.*)(..$)/\2/')
server_id=$(hostname | awk -F'.' '{print $1}' | sed  -r  's/(.*)(..$)/\2/')
master_ip=`ifconfig | sed -n '2p' | awk '{print $2}'`
mys_defa_passwd=123qqq...A


                sed -i "4a log_bin=$master_id" /etc/my.cnf
                sed -i "4a server_id=$server_id" /etc/my.cnf
systemctl restart mysqld

mysql -uroot -p"$mys_defa_passwd" -e "grant replication slave on *.* to repluser@'%'  identified by '$mys_defa_passwd';"
mysql -p"$mys_defa_passwd" -uroot -e "grant all on *.* to root@'%' identified by '$mys_defa_passwd' with grant option; "












