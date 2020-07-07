#!/bin/bash
#
source /root/tools/func.sh
# 编译安装php-5.5.38

# 路径配置
INSTALL_DIR=/usr/local
S_NAME=php
REMOTE_URL=http://mirrors.sohu.com/php/
SOURCE_DIR=/usr/local/src
FILE_NAME=php-5.5.38.tar.gz

H_PREFIX=/usr/local/apache/

if [[ "$1" -eq "1" ]];then
	# 安装依赖
	yum install -y epel-release bzip2 bzip2-devel libmcrypt-devel openssl-devel libxml2-devel
	 

	# 检测二进制文件是否存在，不存在下载
	if [ ! -f ${SOURCE_DIR}/${FILE_NAME} ]; then
		wget -P ${SOURCE_DIR} ${REMOTE_URL}/${FILE_NAME}
	fi

	# 解压二进制文件
	tar xvf ${SOURCE_DIR}/${FILE_NAME} -C ${SOURCE_DIR}  && cd ${SOURCE_DIR}/${FILE_NAME%.tar*}

	if [ $? -eq 0 ]; then
		./configure --prefix=${INSTALL_DIR}/${S_NAME} --with-apxs2=$H_PREFIX/bin/apxs --with-openssl --enable-mbstring --enable-sockets --with-freetype-dir --with-jpeg-dir --with-png-dir --with-libxml-dir=/usr --enable-xml --with-zlib --with-mcrypt --with-bz2 --with-mhash --with-config-file-path=/etc --with-config-file-scan-dir=/etc/php.d --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --enable-fpm
		make && make install	
		success " PHP Install Successfully!"
	else
		fail "Unzip File Failed!"
	fi
fi

if [[ "$1" -eq "2" ]];then
	sed -i '/DirectoryIndex/s/index.html/index.php index.html/g' $H_PREFIX/conf/httpd.conf
	echo "AddType application/x-httpd-php .php" >> $H_PREFIX/conf/httpd.conf
	service httpd restart
	#IP=`ifconfig eth0|grep "Bcast"|awk '{print $2}'| cut -d: -f2`
	#IP=`ifconfig ens33|grep "broadcast"|awk '{print $2}'`	
	success " PHP Config Successfully!"
	service httpd restart
fi