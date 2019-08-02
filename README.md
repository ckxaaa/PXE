必须将应答文件以及pxe执行脚本放在/root目录下，
关闭防火墙
sed -i '7s/enforcing/disabled/' config
systemctl stop firewalld
systemctl diable firewalld
reboot
