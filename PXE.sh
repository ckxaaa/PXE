#!/bin/bash
#安装PXE所需要的服务
yum install -y vsftpd* tftp-server dhcp system-config-kickstart syslinux wget vim
yum install -y net-tools
yum install -y bridge-utils
systemctl stop friewalld
systemclt disable friewalld
getenforce 0
#禁用virbr0(虚拟环境)
#ifconfig virbr0
#brctl delbr virbr0
#systemctl disable libvirtd
#获取centos源
##http://mirrors.163.com/centos/7.6.1810/isos/x86_64/CentOS-7-x86_64-DVD-1810.iso(备用源)
cd /opt
wget https://mirrors.aliyun.com/centos/7.6.1810/isos/x86_64/CentOS-7-x86_64-DVD-1810.iso
mount /opt/CentOS-7-x86_64-DVD-1810.iso /media/
mkdir /var/ftp/centos7
cp -rf /media/* /var/ftp/centos7/
sed -i '14s/yes/no/' /etc/xinetd.d/tftp
cp /media/images/pxeboot/vmlinuz /var/lib/tftpboot/
cp /media/images/pxeboot/initrd.img /var/lib/tftpboot/
cp /usr/share/syslinux/pxelinux.0 /var/lib/tftpboot/
mkdir /var/lib/tftpboot/pxelinux.cfg
read -p "输入 subnet :" subNet
read -p "输入 子网掩码 :" netMask
read -p "输入地址池起始ip :" rangeHead
read -p "输入地址池结束ip :" rangeEnd
read -p "输入路由器地址 :" route
read -p "输入本机IP地址 :" ip
read -p "输入广播地址 :" broadcast
cd /var/lib/tftpboot/pxelinux.cfg/
echo -e 'default auto \n prompt 0 \n label auto \n Kernel             vmlinuz \n append initrd=initrd.img method=ftp://'$ip'/centos7 ks=ftp://'$ip'/ks.cfg' >> default

cd /etc/dhcp

echo -e 'subnet' $subNet 'netmask' $netMask'{ \n range' $rangeHead $rangeEnd'; \n option domain-name-servers 8.8.8.8; \n option domain-name "lidailao.org"; \n option routers' $route'; \n option broadcast-address' $broadcast'; \n default-lease-time 21600; \n max-lease-time 43200; next-server' $ip ';\n  filename "pxelinux.0"; \n }' >> dhcpd.conf
systemctl restart vsftpd
systemctl enable vsftpd
systemctl restart tftp
systemctl enable tftp
systemctl restart dhcpd
systemctl enable dhcpd
sed -i 's/ftp:\/\/192.168.123.2/ftp:\/\/'$ip'/' /root/ks.cfg
cp /root/ks.cfg /var/ftp/
