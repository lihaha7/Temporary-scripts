#!/bin/bash
#Temporary-scripts
#Author:Lzy

#后台web集群的ip地址
web1_ip=192.168.2.11
web2_ip=192.168.2.12
web3_ip=192.168.2.13
virtual_ip=192.168.4.80
interface=ens33


master () {
#haproxy安装及配置，用户名admin 密码admin

yum -y install haproxy.x86_64
sed -i "63,86d" /etc/haproxy/haproxy.cfg
echo "listen wordpress *:80
  balance roundrobin
  server web1 $web1_ip:80 check inter 2000 rise 2 fall 3
  server web2 $web2_ip:80 check inter 2000 rise 2 fall 3
  server web3 $web3_ip:80 check inter 2000 rise 2 fall 3
listen stats 0.0.0.0:1080
    stats refresh 30s 
    stats uri /stats 
    stats realm Haproxy Manager
    stats auth admin:admin" >> /etc/haproxy/haproxy.cfg
systemctl start haproxy
systemctl enable haproxy

#keepalive 安装及配置[master]
yum -y install keepalived.x86_64
echo "global_defs {
  #notification_email {
  #  acassen@firewall.loc
  #  failover@firewall.loc
  #  sysadmin@firewall.loc
  #}
  #notification_email_from Alexandre.Cassen@firewall.loc
  #smtp_server 192.168.200.1
  #smtp_connect_timeout 30
  #vrrp_skip_check_adv_addr
  #vrrp_strict
  #vrrp_garp_interval 0
  #vrrp_gna_interval 0

  router_id  proxy1
  vrrp_iptables 
}
vrrp_instance VI_1 {
  state MASTER 
  interface $interface
  virtual_router_id 51                
  priority 100
  advert_int 1
  authentication {
    auth_type pass
    auth_pass 1111
  }
  virtual_ipaddress {
$virtual_ip 
}    
}" > /etc/keepalived/keepalived.conf
systemctl start keepalived
systemctl enable keepalived
}


slave () {
#haproxy安装及配置，用户名admin 密码admin

yum -y install haproxy.x86_64
sed -i "63,86d" /etc/haproxy/haproxy.cfg
echo "listen wordpress *:80
  balance roundrobin
  server web1 $web1_ip:80 check inter 2000 rise 2 fall 3
  server web2 $web2_ip:80 check inter 2000 rise 2 fall 3
  server web3 $web3_ip:80 check inter 2000 rise 2 fall 3
listen stats 0.0.0.0:1080
    stats refresh 30s 
    stats uri /stats 
    stats realm Haproxy Manager
    stats auth admin:admin" >> /etc/haproxy/haproxy.cfg
systemctl start haproxy
systemctl enable haproxy

#keepalive 安装及配置[slave]
yum -y install keepalived.x86_64
echo "global_defs {
  #notification_email {
  #  acassen@firewall.loc
  #  failover@firewall.loc
  #  sysadmin@firewall.loc
  #}
  #notification_email_from Alexandre.Cassen@firewall.loc
  #smtp_server 192.168.200.1
  #smtp_connect_timeout 30
  #vrrp_skip_check_adv_addr
  #vrrp_strict
  #vrrp_garp_interval 0
  #vrrp_gna_interval 0

  router_id  proxy1
  vrrp_iptables 
}
vrrp_instance VI_1 {
  state MASTER 
  interface $interface
  virtual_router_id 51                
  priority 90
  advert_int 1
  authentication {
    auth_type pass
    auth_pass 1111
  }
  virtual_ipaddress {
$virtual_ip 
}    
}" > /etc/keepalived/keepalived.conf
systemctl start keepalived
systemctl enable keepalived
}


read -p "请输入proxy的类型,1为主2为从, 1|2 " num
if [ -z $num ];then
	read -p "请输入proxy的类型,1为主2为从, 1|2 " num
elif [ $num -eq 1 ];then
	master 
elif [ $num -eq 2 ];then
	slave
else
	echo "请输入proxy的类型,1为主2为从, 1|2"
fi












