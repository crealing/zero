#!/bin/bash

# 编译安装nginx-1.16.1

# 路径配置
INSTALL_DIR=/usr/local
S_NAME=nginx
REMOTE_URL=https://nginx.org/download/
SOURCE_DIR=/usr/local/src
FILE_NAME=nginx-1.16.1.tar.gz

# 安装依赖

yum -y install gcc gcc-c++
yum -y install zlib zlib-devel openssl openssl-devel pcre-devel

# 检测二进制文件是否存在，不存在下载
if [ ! -f ${SOURCE_DIR}/${FILE_NAME} ]; then
	wget -P ${SOURCE_DIR} ${REMOTE_URL}/${FILE_NAME}
fi

if id -u ${S_NAME}; then
	groupadd ${S_NAME}
	useradd -r -s /sbin/nologin -g ${S_NAME} -M ${S_NAME}
fi

# 解压二进制文件
#tar xvf ${SOURCE_DIR}/${FILE_NAME} -C ${UNZIP_DIR} && ln -s ${UNZIP_DIR}/${FILE_NAME%.tar*} ${INSTALL_DIR} && cd ${INSTALL_DIR}
tar xvf ${SOURCE_DIR}/${FILE_NAME} -C ${SOURCE_DIR}  && cd ${SOURCE_DIR}/${FILE_NAME%.tar*}

if [ $? -eq 0 ]; then
	./configure --user=${S_NAME} --group=${S_NAME} --prefix=${INSTALL_DIR}/${S_NAME} --with-http_stub_status_module --with-http_ssl_module --with-http_realip_module --with-http_gzip_static_module
	make && make install
	if ${INSTALL_DIR}/${S_NAME}/sbin/nginx; then
		echo -e "\033[32m Nginx Install Successfully! \033[0m"
	else
		echo -e "\033[31m Nginx Install Failed! \033[0m"
	fi
else
	echo -e "\033[31m Unzip File Failed! \033[0m"
fi
