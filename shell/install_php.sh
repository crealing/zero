#!/bin/bash

# ���밲װphp-5.5.38

# ·������
INSTALL_DIR=/usr/local
S_NAME=php
REMOTE_URL=http://mirrors.sohu.com/php/
SOURCE_DIR=/usr/local/src
FILE_NAME=php-5.5.38.tar.gz


# ��װ����
yum install -y epel-release bzip2 bzip2-devel libmcrypt-devel openssl-devel libxml2-devel
 

# ���������ļ��Ƿ���ڣ�����������
if [ ! -f ${SOURCE_DIR}/${FILE_NAME} ]; then
	wget -P ${SOURCE_DIR} ${REMOTE_URL}/${FILE_NAME}
fi

# ��ѹ�������ļ�
tar xvf ${SOURCE_DIR}/${FILE_NAME} -C ${SOURCE_DIR}  && cd ${SOURCE_DIR}/${FILE_NAME%.tar*}

if [ $? -eq 0 ]; then
	./configure --prefix=${INSTALL_DIR}/${S_NAME} --with-openssl --enable-mbstring --enable-sockets --with-freetype-dir --with-jpeg-dir --with-png-dir --with-libxml-dir=/usr --enable-xml --with-zlib --with-mcrypt --with-bz2 --with-mhash --with-config-file-path=/etc --with-config-file-scan-dir=/etc/php.d --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --enable-fpm --with-apxs2=/usr/local/apache/bin/apxs
	make && make install
	cp php.ini-production /etc/php.ini
	cp sapi/fpm/init.d.php-fpm /etc/init.d/php-fpmd
    chmod +x /etc/init.d/php-fpmd

	cd ${INSTALL_DIR}/${S_NAME}
	cp etc/php-fpm.conf.default etc/php-fpm.conf
	service php-fpmd start
	
	if netstat -ntdl | grep 9000; then
		echo -e "\033[32m PHP Install Successfully! \033[0m"
	else
		echo -e "\033[32m PHP Install Failed! \033[0m"
	fi
else
	echo -e "\033[31m Unzip File Failed! \033[0m"
fi
