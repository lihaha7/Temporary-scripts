#!/bin/bash
#Temporary-scripts
#Author:Lzy

yum -y install gcc pcre-devel openssl-devel php php-fpm.x86_64 php-mysql  mariadb mariadb-server.x86_64 mariadb-devel

cd /root
tar -xf lnmp_soft.tar.gz
cd lnmp_soft/
tar -xf nginx-1.12.2.tar.gz
cd nginx-1.12.2/
./configure --with-http_ssl_module --with-stream --with-http_stub_status_module
make
make install
#ln -s /usr/local/nginx/sbin/nginx /bin/


sed -i '45s/index.html/index.php/' /usr/local/nginx/conf/nginx.conf
sed -i '65,71s/#//' /usr/local/nginx/conf/nginx.conf
sed -i '/SCRIPT_FILENAME/d' /usr/local/nginx/conf/nginx.conf
sed -i 's/fastcgi_params/fastcgi.conf/' /usr/local/nginx/conf/nginx.conf

#nginx
echo "[Unit]
Description=The Nginx HTTP Server
After=network.target remote-fs.target nss-lookup.target
[Service]
Type=forking
ExecStart=/usr/local/nginx/sbin/nginx
ExecReload=/usr/local/nginx/sbin/nginx -s reload
ExecStop=/bin/kill -s QUIT ${MAINPID}
[Install]
WantedBy=multi-user.target" >  /usr/lib/systemd/system/nginx.service

systemctl start mariadb
systemctl start php-fpm
systemctl start nginx
systemctl enable nginx php-fpm mariadb




