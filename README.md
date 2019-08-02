必须将应答文件以及pxe执行脚本放在/root目录下， \n
关闭防火墙 \n
sed -i '7s/enforcing/disabled/' /etc/selinux/config
systemctl stop firewalld
systemctl diable firewalld
reboot
tftpf无法设置开机自启，所以在重启之后请手动打开tftp服务
