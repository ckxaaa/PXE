必须将应答文件以及pxe执行脚本放在/root目录下，  
关闭防火墙   
sed -i '7s/enforcing/disabled/' /etc/selinux/config  
systemctl stop firewalld  
systemctl diable firewalld  
reboot  
tftpf无法设置开机自启，所以在重启之后请手动打开tftp服务  
可以自行创建一个root密码  
# grub-crypt  



PXE服务器搭建  
PXE远程服务器（192.168.123.2）所需准备:    
1.安装源（系统盘文件）;  
2.TFTP服务；  
3.DHCP服务；  
4.Linux内核；  
5.能够向客户机裸机发送PXE引导程序；  
6.启动菜单及无人应答文件等。  
客户端要求：  
1.客户端的网卡支持PXE协议，且主板支持网络引导（现在多数都支持）；  
2.设置BIOS允许从Network或LAN启动；  

1、搭建PXE远程安装服务器：  
1、装DHCP、tftp、vsftpd、system-config-kickstar、syslinux服务（如果安装服务找不到包，请将yum源更换为本地yum源）  
[root@localhost yum.repos.d]# yum -y install vsftpd*  
[root@localhost yum.repos.d]# yum -y install tftp-server  
[root@localhost pxeboot]# yum -y install dhcp  
[root@localhost pxeboot]# yum -y install system-config-kickstart  
[root@localhost pxeboot]# yum -y install syslinux    #安装引导程序  
2、禁用virbr0  
[root@localhost ~]# ifconfig virbr0 down  
[root@localhost ~]# brctl delbr virbr0  
[root@localhost ~]# systemctl disable libvirtd  
Removed symlink /etc/systemd/system/multi-user.target.wants/libvirtd.service.  
Removed symlink /etc/systemd/system/sockets.target.wants/virtlogd.socket.  
Removed symlink /etc/systemd/system/sockets.target.wants/virtlockd.socket.  


2、全部服务启动并且设置开机自启（更改配置文件之后记得重新启动服务）  

3、传输centos镜像到PXE服务器  

4、挂载centos镜像到/media目录下  
[root@localhost opt]# mount CentOS-7-x86_64-DVD-1810.iso  /media/  
5、准备centos7安装源  
[root@localhost yum.repos.d]# mkdir /var/ftp/centos7  
[root@localhost yum.repos.d]# cp -rf  /media/* /var/ftp/centos7/  
6、修改tftp配置文件  
[root@localhost yum.repos.d]# vim /etc/xinetd.d/tftp   
service  tftp  
{  
        socket_type             = dgram  
        protocol                = udp  
        wait                    = yes  
        user                    = root  
        server                  = /usr/sbin/in.tftpd  
        server_args             = -s /var/lib/tftpboot  
        disable                 = no               #将此处默认的yes改为no即可  
        per_source              = 11  
        cps                     = 100 2  
        flags                   = IPv4  
}
7、准备Linux内核、初始化镜像文件  
[root@localhost ~]# cd /media/images/pxeboot/  
[root@localhost pxeboot]# cp vmlinuz initrd.img /var/lib/tftpboot/  

8、准备PXE引导程序  
[root@localhost pxeboot]# cp /usr/share/syslinux/pxelinux.0  /var/lib/tftpboot/  
9、配置启动菜单  
[root@localhost pxeboot]# mkdir /var/lib/tftpboot/pxelinux.cfg   
无人值守安装的启动菜单：  
[root@localhost pxeboot]# vim /var/lib/tftpboot/pxelinux.cfg/default   
default auto  
prompt 0  
label auto  
        Kernel             vmlinuz  
        append initrd=initrd.img method=ftp://192.168.1.1/centos7 ks=ftp://192.168.1.1/ks.cfg  
10、启用DHCP服务器更改配置文件  
[root@localhost opt]# vim /etc/dhcp/dhcpd.conf   
subnet 192.168.123.0 netmask 255.255.255.0 {     
    range 192.168.123.4 192.168.123.10;      #客户地ip范围  
    option domain-name-servers 8.8.8.8;      #dns地址  
    option domain-name "lidailao.org";  
    option routers 192.168.123.1;			#路由器地址  
    option broadcast-address 192.168.123.255;  
    default-lease-time 21600;  
    max-lease-time 43200;  
    next-server 192.168.123.2;                 #指定TFTP服务器的地址  
    filename "pxelinux.0";                     #指定PXE引导程序的文件名  

}  
11、准备安装应答文件  
配置完成之后再配置文件之后加入三行，来选择最小安装  
%packages  
@^minimal  
%end  
可以使用ksvalidator程序验证kickstart文件中是否有语法错误  
#[root@localhost ~]#  ksvalidator  ks.cfg   

加入之后将自动应答文件复制到指定目录  
[root@localhost ~]# cp /root/ks.cfg /var/ftp/  



OK，结束。
