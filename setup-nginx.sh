#!/bin/bash
#Temporary-scripts
#Author:Lzy


#本脚本默认nginx源码包的路径为/root
#默认的nginx编译安装的位置为/usr/local/nginx
function cecho {
echo -e "\033[$1m$2\033[0m"
}
#nginx=`echo $1 |cut -b 1-12`
#a=$1
nginx=`echo ${1/.tar.gz/}`

if [ $# -ne 1 ];then
	cecho 31 "$0 nginx压缩包"
	exit 10
elif [ ! -f /root/$1 ];then
	cecho 31 "$0 nginx压缩包"
	exit 20
fi

[ -d /usr/local/nginx ] && cecho 31 "重复安装;文件残余" &&  exit 100 

rpm -q  make gcc gcc-c++ pcre-devel openssl-devel || cecho 31 "正在安装依赖软件..."
yum -y install make gcc gcc-c++ pcre-devel openssl-devel &> /dev/null

[ -f /root/$1 ] && (cecho 31 "正在解压nginx压缩包..." ; tar -xf /root/$1 ) || exit 11 
[ -d /root/$nginx ] &&  cd /root/$nginx || exit 1

id nginx &> /dev/null  || useradd -s /sbin/nologin nginx

cecho 31 "正在配置..."
./configure --prefix=/usr/local/nginx --user=nginx --group=nginx  --with-http_ssl_module &> /dev/null

[ $? -eq 0 ] &&  cecho 31  "正在编译..." 
make &> /dev/null || exit 2

cecho 31 "正在安装..."
make install &> /dev/null || exit 3
sleep 3

if [ -f /bin/nginx ];then
	cecho 32  "$nginx setup successful"
else
	ln -s /usr/local/nginx/sbin/nginx /bin/ &> /dev/null 
	cecho 32  "$nginx setup successful"
fi


