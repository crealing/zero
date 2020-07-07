#!/bin/bash
#

# 二进制安装mysql5.7
#路径，文件名等配置信息
UNZIP_DIR=/usr/local
INSTALL_DIR=/usr/local/mysql
SOURCE_DIR=/usr/local/src
#REMOTE_URL=https://downloads.mysql.com/archives/get/file
REMOTE_URL=http://192.168.0.150/zip
FILE_NAME=mysql-5.7.17-linux-glibc2.5-x86_64.tar.gz

DATA_DIR="/mydata/data"

if [ ! -f "${SOURCE_DIR}/${FILE_NAME}" ]; then
	wget -P  ${SOURCE_DIR} ${REMOTE_URL}/${FILE_NAME}
fi

tar xvf ${SOURCE_DIR}/${FILE_NAME} -C ${UNZIP_DIR} && ln -s ${UNZIP_DIR}/${FILE_NAME%.tar*} ${INSTALL_DIR} && cd ${INSTALL_DIR}

if [ $? -eq 0 ];then
	if [ ! -d "$DATA_DIR" ]; then
		mkdir -p "$DATA_DIR"
	fi

	if ! id -u mysql &>/dev/null; then
		useradd -r -s /sbin/nologin mysql
	fi

	chown -R mysql.mysql ${INSTALL_DIR}
	chown -R mysql.mysql $DATA_DIR

	bin/mysqld --initialize-insecure --datadir=/mydata/data --user=mysql

	/bin/cp -af  support-files/mysql.server /etc/init.d/mysqld

	/bin/cp -af support-files/my-default.cnf /etc/my.cnf

	sed -i '$a\datadir=/mydata/data' /etc/my.cnf

	ln -s /usr/local/mysql/bin/mysql /usr/sbin/mysql
	service mysqld restart
	if [ $? -eq 0 ];then
		echo -e "\033[32m Mysql Install Successfully! \033[0m"
	else
		echo -e "\033[31m Mysql Install Failed,Please check! \033[0m"
		exit 2
	fi
else
	echo -e "\033[31m Error,Please check! \033[0m"
	exit 2
fi

