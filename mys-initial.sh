#!/bin/bash
#Temporary-scripts
#Author:Lzy

if [ -f /root/mysql-5.7.17.tar  ];then
                [ -d /root/mysql-5.7.17 ] || mkdir /root/mysql-5.7.17
                echo -e "\033[1;34m正在解压文件,请稍后...\033[0m"
                tar -xf /root/mysql-5.7.17.tar -C /root/mysql-5.7.17
                echo -e "\033[1;34m正在安装MySQL,请稍后...\033[0m"
                yum -y localinstall /root/mysql-5.7.17/mysql-community-* &> /dev/null
                echo -e "\033[1;34m正在启动MySQL,请稍后...\033[0m"
                systemctl restart mysqld

fi

echo -e "\033[1;36m初始化完成.密码为123qqq...A\033[0m"
echo "SET PASSWORD  = PASSWORD('123qqq...A');" | mysql -u root --password=$(grep 'password is' /var/log/mysqld.log | awk '{print $11}') -b --connect-expired-password &> /dev/null

