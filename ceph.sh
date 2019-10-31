#!/bin/bash
#Temporary-scripts
#Author:Lzy

#Define default variables, you can modify the value.
client_hostname=c1
node1_hostname=n1
node2_hostname=n2
node3_hostname=n3

client_ip=192.168.4.30
node1_ip=192.168.4.31
node2_ip=192.168.4.32
node3_ip=192.168.4.33

#Determine the language environment
language(){
        echo $LANG |grep -q zh
        if [ $? -eq 0 ];then
                return 0
        else
                return 1
        fi
}
#Define a user portal menu.
menu(){
        clear
        language
        if [ $? -eq 0 ];then
           echo "  ##############----Menu----##############"
           echo "# 1. 安装Initial"
           echo "# 2. 安装Mon"
           echo "# 3. 安装Osd"
           #echo "# 4. 安装Memcached"
           #echo "# 5. 安装memcache for php"
           #echo "# 6. 安装Java,Tomcat"
           #echo "# 7. 安装Varnish"
           #echo "# 8. 安装Session共享库"
           echo "# 9. 退出程序"
           echo "  ########################################"
        else
           echo "  ##############----Menu----##############"
           echo "# 1. Install Initial"
           echo "# 2. Install Mon"
           echo "# 3. Install Osd"
           echo "# 4. Install Memcached"
           echo "# 5. Install memcache for php"
           echo "# 6. Install Java,Tomcat"
           echo "# 7. Install Varnish"
           echo "# 8. Install Session Share Libarary"
           echo "# 9. Exit Program"
           echo "  ########################################"
        fi
}

#Read user's choice
choice(){
        language
        if [ $? -eq 0 ];then
                read -p "请选择一个菜单[1-9]:" select
        else
                read -p "Please choice a menu[1-9]:" select
        fi
}
error_yum(){
        language
        if [ $? -eq 0 ];then
                clear
                echo
                echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
                echo "错误:本机YUM不可用，请正确配置YUM后重试."
                echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
                echo
                exit
        else
                clear
                echo
                echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
                echo "ERROR:Yum is disable,please modify yum repo file then try again."
                echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
                echo
                exit
        fi
}

#Test target system whether have yum repo.
#Return 0 dedicate yum is enable.
#Return 1 dedicate yum is disable.
test_yum(){
#set yum configure file do not display Red Hat Subscription Management info.
        if [ -f /etc/yum/pluginconf.d/subscription-manager.conf ];then
        sed -i '/enabled/s/1/0/' /etc/yum/pluginconf.d/subscription-manager.conf
        fi
        yum clean all &>/dev/null
        repolist=$(yum repolist 2>/dev/null |awk '/repolist:/{print $2}'|sed 's/,//')
        if [ $repolist -le 0 ];then
                error_yum
        fi
}




install_initial(){

#初始环境准备
[ -f /root/.ssh/id_rsa ] || ssh-keygen -f /root/.ssh/id_rsa -N ''
echo "$client_ip $client_hostname
$node1_ip $node1_hostname
$node2_ip $node2_hostname
$node3_ip $node3_hostname" >> /etc/hosts

#向各个服务器发送公钥
rpm -qa | grep expect || yum -y install expect
for i in $client_ip $node1_ip $node2_ip $node3_ip
do
 #ssh-copy-id $i
 expect << EOF
 spawn ssh-copy-id $i
 expect "password:" { send "123456\r" } 
 expect "password:" { send "123456\r" } 
EOF
done

#向各个服务器发送hosts文件
for i in $client_ip $node1_ip $node2_ip $node3_ip
do
 scp  /etc/hosts   $i:/etc/
done

#向各个服务器发送yum源
echo "[mon]
name=mon
baseurl=ftp://192.168.4.254/ceph/MON
gpgcheck=0
[osd]
name=osd
baseurl=ftp://192.168.4.254/ceph/OSD
gpgcheck=0
[tools]
name=tools
baseurl=ftp://192.168.4.254/ceph/Tools
gpgcheck=0" > /etc/yum.repos.d/ceph.repo

for i in $client_ip $node1_ip $node2_ip $node3_ip
do
 scp  /etc/yum.repos.d/ceph.repo   $i:/etc/yum.repos.d/
done

#所有节点与ntp服务器同步时间
sed -i '6c server 192.168.4.254 iburst' /etc/chrony.conf

for i in $client_ip $node1_ip $node2_ip $node3_ip
do
 scp /etc/chrony.conf $i:/etc/
 ssh  $i  "systemctl restart chronyd"
done
}

install_mon(){

#安装部署软件ceph-deploy
rpm -qa | grep ceph-deploy || yum -y install ceph-deploy
cd ~
mkdir ceph-cluster
cd ceph-cluster/



#在ceph.conf配置文件中定义monitor主机是谁。
ceph-deploy new $node1_hostname  $node2_hostname $node3_hostname

#给所有节点安装ceph相关软件包
for i in $node1_ip $node2_ip $node3_ip
do
 ssh  $i "yum -y install ceph-mon ceph-osd ceph-mds ceph-radosgw"
done

#初始化mon服务(启服务)
ceph-deploy mon create-initial
}

install_osd(){

#创建osd
for i in $node1_ip $node2_ip $node3_ip
do
     ssh $i "parted /dev/vdb mklabel gpt"
     ssh $i "parted /dev/vdb mkpart primary 1 50%"
     ssh $i "parted /dev/vdb mkpart primary 50% 100%"
done

#修改分区权限为ceph
echo 'ENV{DEVNAME}=="/dev/vdb1",OWNER="ceph",GROUP="ceph"
ENV{DEVNAME}=="/dev/vdb2",OWNER="ceph",GROUP="ceph"' > /etc/udev/rules.d/70-vdb.rules

for i in $node1_ip $node2_ip $node3_ip
do
     ssh $i "chown  ceph.ceph  /dev/vdb1"
     ssh $i "chown  ceph.ceph  /dev/vdb2"
     scp /etc/udev/rules.d/70-vdb.rules $i:/etc/udev/rules.d/
done

#初始化清空磁盘数据
ceph-deploy disk  zap  $node1_ip:vdc   $node1_ip:vdd    
ceph-deploy disk  zap  $node2_ip:vdc   $node2_ip:vdd
ceph-deploy disk  zap  $node3_ip:vdc   $node3_ip:vdd  

#创建osd存储空间
ceph-deploy osd create \
$node1_ip:vdc:/dev/vdb1 $node1_ip:vdd:/dev/vdb2  $node2_ip:vdc:/dev/vdb1 $node2_ip:vdd:/dev/vdb2 $node3_ip:vdc:/dev/vdb1 $node3_ip:vdd:/dev/vdb2 
}



while :
do
menu
choice
case $select in
1)
        install_initial
        ;;
2)
        install_mon
        ;;
3)
        install_osd
        ;;
#4)
#        install_memcached
#        ;;
#5)
#        install_memcache
#        ;;
#6)
#        install_java
#        install_tomcat
#        ;;
#7)
#        install_varnish
#        ;;
#8)
#        install_session
#        ;;
9)
        exit
        ;;
*)
        echo Sorry!
esac
done













































