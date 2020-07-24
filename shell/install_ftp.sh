#!/bin/bash
#Author: xiaowen
#Time:2020-07-24 09:42:33

. ./func.sh
#success "vsftpd安装成功"
#exit 0

#安装vsftpd和db4-utils
yum install vsftpd db4-utils db4 -y
if [ $? -ne 0 ]; then
	fail "vsftpd安装失败"
	exit 1
else
	success "vsftpd安装成功";
fi

#如果用户ftp不存在就添加
if [ ! `id -u ftp &> /dev/null` ]; then
	useradd -s /sbin/nologin ftp &> /dev/null
	if [ $? -eq 0 ]; then
		success "用户ftp添加成功"
	fi
fi

chown ftp.ftp /home/www/ -R


#修改vsftpd配置文件
mv /etc/vsftpd/vsftpd.conf /etc/vsftpd/vsftpd.conf.bak
cat >> /etc/vsftpd/vsftpd.conf << EOF
anonymous_enable=NO
local_enable=YES
local_umask=022
connect_from_port_20=YES
use_localtime=YES
write_enable=YES
anon_upload_enable=NO
anon_mkdir_write_enable=NO
anon_other_write_enable=NO
guest_enable=YES
guest_username=ftp
user_config_dir=/etc/vsftpd/vuser_dir
#listen=YES
listen_port=21
pam_service_name=vsftpd
userlist_enable=YES
tcp_wrappers=YES
allow_writeable_chroot=YES
ascii_download_enable=YES
chroot_list_enable=YES
chroot_list_file=/etc/vsftpd/chroot_list
xferlog_file=/var/log/vsftpd.log
xferlog_enable=YES
xferlog_std_format=YES
pasv_enable=NO
#pasv_enable=YES
#pasv_min_port=10030
#pasv_max_port=10035
EOF
if [ $? -eq 0 ]; then
	success "配置文件修改成功"
else
	fail "配置文件修改失败"
	exit 2
fi

#配置PAM
mv /etc/pam.d/vsftpd /etc/pam.d/vsftpd.bak
cat >> /etc/pam.d/vsftpd << EOF
auth required /lib64/security/pam_userdb.so db=/etc/vsftpd/vsftpd_vuser
account required /lib64/security/pam_userdb.so db=/etc/vsftpd/vsftpd_vuser
EOF
if [ $? -eq 0 ]; then
	success "PAM配置成功"
else
	fail "PAM配置失败"
	exit 3
fi

#创建chroot_list
touch /etc/vsftpd/chroot_list
#创建日志文件
touch /var/log/vsftpd.log; chown ftp.ftp /var/log/vsftpd.log

#添加虚拟用户
cat >> /etc/vsftpd/vuser << EOF
xiaowen
123123
crealing
123123
EOF
#将虚拟用户数据库文件转换为认证模块识别的数据文件
db_load -T -t hash -f /etc/vsftpd/vuser /etc/vsftpd/vsftpd_vuser.db

if [ ! -d /etc/vsftpd/vuser_dir ]; then
	mkdir -p /etc/vsftpd/vuser_dir
	if [ $? -eq 0 ]; then
		success "虚拟用户目录创建成功"
	else
		fail "虚拟用户目录创建失败"
		exit 2
	fi
fi

mkdir -p /home/www/abc.com; chown ftp.ftp /home/www/abc.com -R
cat >> /etc/vsftpd/vuser_dir/xiaowen << EOF
local_root=/home/www/abc.com
write_enable=YES
download_enable=YES
anon_world_readable_only=NO
anon_upload_enable=YES
anon_mkdir_write_enable=YES
anon_other_write_enable=YES
EOF

systemctl restart vsftpd
if [ $? -eq 0 ]; then
	success "FTP配置成功"
else
	fail "FTP配置失败"
	exit 3
fi




