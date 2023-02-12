# TP4 : Real services

# Partie 1 : Partitionnement du serveur de stockage

🌞 **Partitionner le disque à l'aide de LVM**

```
[fmaxance@storage ~]$ lsblk
NAME        MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sda           8:0    0    8G  0 disk
├─sda1        8:1    0    1G  0 part /boot
└─sda2        8:2    0    7G  0 part
  ├─rl-root 253:0    0  6.2G  0 lvm  /
  └─rl-swap 253:1    0  820M  0 lvm  [SWAP]
sdb           8:16   0    2G  0 disk
sr0          11:0    1 1024M  0 rom
sr1          11:1    1 1024M  0 rom
```

```
[fmaxance@storage ~]$ sudo pvcreate /dev/sdb
[sudo] password for fmaxance:
  Physical volume "/dev/sdb" successfully created.
```

```
[fmaxance@storage ~]$ sudo pvs
  Devices file sys_wwid t10.ATA_____VBOX_HARDDISK___________________________VB89ec5d3b-5728a15a_ PVID DxP2Y1leKoh4lQlag4E8anxQtLwl1cCI last seen on /dev/sda2 not found.
  PV         VG Fmt  Attr PSize PFree
  /dev/sdb      lvm2 ---  2.00g 2.00g
```

```
[fmaxance@storage ~]$ sudo pvdisplay
  Devices file sys_wwid t10.ATA_____VBOX_HARDDISK___________________________VB89ec5d3b-5728a15a_ PVID DxP2Y1leKoh4lQlag4E8anxQtLwl1cCI last seen on /dev/sda2 not found.
  "/dev/sdb" is a new physical volume of "2.00 GiB"
  --- NEW Physical volume ---
  PV Name               /dev/sdb
  VG Name
  PV Size               2.00 GiB
  Allocatable           NO
  PE Size               0
  Total PE              0
  Free PE               0
  Allocated PE          0
  PV UUID               r8srh1-QHAY-3ICN-oJXG-AO8h-XMsh-2sz1Pt
```

```
[fmaxance@storage ~]$ sudo vgcreate storage /dev/sdb
  Volume group "storage" successfully created
```

```
[fmaxance@storage ~]$ sudo vgs
  Devices file sys_wwid t10.ATA_____VBOX_HARDDISK___________________________VB89ec5d3b-5728a15a_ PVID DxP2Y1leKoh4lQlag4E8anxQtLwl1cCI last seen on /dev/sda2 not found.
  VG      #PV #LV #SN Attr   VSize  VFree
  storage   1   0   0 wz--n- <2.00g <2.00g
```

```
[fmaxance@storage ~]$ sudo vgdisplay
  Devices file sys_wwid t10.ATA_____VBOX_HARDDISK___________________________VB89ec5d3b-5728a15a_ PVID DxP2Y1leKoh4lQlag4E8anxQtLwl1cCI last seen on /dev/sda2 not found.
  --- Volume group ---
  VG Name               storage
  System ID
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  1
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                0
  Open LV               0
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               <2.00 GiB
  PE Size               4.00 MiB
  Total PE              511
  Alloc PE / Size       0 / 0
  Free  PE / Size       511 / <2.00 GiB
  VG UUID               e8GnYS-9vu1-jfhI-w76s-dJgG-5XeK-AvP8LC
```

```
[fmaxance@storage ~]$ sudo lvcreate -l 100%FREE storage -n last_data
  Logical volume "last_data" created.
```

```
[fmaxance@storage ~]$ sudo lvs
  Devices file sys_wwid t10.ATA_____VBOX_HARDDISK___________________________VB89ec5d3b-5728a15a_ PVID DxP2Y1leKoh4lQlag4E8anxQtLwl1cCI last seen on /dev/sda2 not found.
  LV        VG      Attr       LSize  Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  last_data storage -wi-a----- <2.00g
```

```
[fmaxance@storage ~]$ sudo lvdisplay
  Devices file sys_wwid t10.ATA_____VBOX_HARDDISK___________________________VB89ec5d3b-5728a15a_ PVID DxP2Y1leKoh4lQlag4E8anxQtLwl1cCI last seen on /dev/sda2 not found.
  --- Logical volume ---
  LV Path                /dev/storage/last_data
  LV Name                last_data
  VG Name                storage
  LV UUID                bMlTzb-zoPu-Aktb-fasO-ccji-BwLR-cOfwMh
  LV Write Access        read/write
  LV Creation host, time storage.tp4.linux, 2023-01-22 12:26:01 +0100
  LV Status              available
  # open                 0
  LV Size                <2.00 GiB
  Current LE             511
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           253:2
```

🌞 **Formater la partition**

```
[fmaxance@storage ~]$ sudo mkfs -t ext4 /dev/storage/last_data
mke2fs 1.46.5 (30-Dec-2021)
Creating filesystem with 523264 4k blocks and 130816 inodes
Filesystem UUID: 1015f1c8-77c0-4165-bd39-5c17f35a3369
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912

Allocating group tables: done
Writing inode tables: done
Creating journal (8192 blocks): done
Writing superblocks and filesystem accounting information: done
```

🌞 **Monter la partition**

```
[fmaxance@storage ~]$ sudo mkdir /mnt/storage
```

```
[fmaxance@storage ~]$ sudo mount /dev/storage/last_data /mnt/storage/
```

```
[fmaxance@storage ~]$ df -h | grep /storage
/dev/mapper/storage-last_data  2.0G   24K  1.9G   1% /mnt/storage
```

```
[fmaxance@storage ~]$ ls -la /dev/mapper/storage-last_data
lrwxrwxrwx. 1 root root 7 Jan 22 12:34 /dev/mapper/storage-last_data -> ../dm-2
```
On peut bien lire et écrire des données sur cette partition.

```
[fmaxance@storage ~]$ cat /etc/fstab | grep storage
/dev/storage/last_data /mnt/storage/ ext4 defaults 0 0
```

```
[fmaxance@storage ~]$ sudo umount /mnt/storage/
```

```
[fmaxance@storage ~]$ sudo mount -av
/                        : ignored
/boot                    : already mounted
none                     : ignored
mount: /mnt/storage does not contain SELinux labels.
       You just mounted a file system that supports labels which does not
       contain labels, onto an SELinux box. It is likely that confined
       applications will generate AVC messages and not be allowed access to
       this file system.  For more details see restorecon(8) and mount(8).
/mnt/storage/            : successfully mounted
```

# Partie 2 : Serveur de partage de fichiers

🌞 **Donnez les commandes réalisées sur le serveur NFS `storage.tp4.linux`**

```
[fmaxance@storage ~]$ sudo dnf install nfs-utils
```

```
[fmaxance@storage ~]$ sudo mkdir /mnt/storage/site_web_1
[fmaxance@storage ~]$ sudo mkdir /mnt/storage/site_web_2
```

```
[fmaxance@storage ~]$ sudo systemctl enable nfs-server
[fmaxance@storage ~]$ sudo systemctl start nfs-server
[fmaxance@storage ~]$ sudo !!
sudo firewall-cmd --permanent --add-service=nfs
success
[fmaxance@storage ~]$ sudo firewall-cmd --permanent --add-service=mountd
success
[fmaxance@storage ~]$ sudo firewall-cmd --permanent --add-service=rpc-bind
success
[fmaxance@storage ~]$ sudo firewall-cmd --reload
success
[fmaxance@storage ~]$ sudo firewall-cmd --permanent --list-all | grep services
  services: cockpit dhcpv6-client mountd nfs rpc-bind ssh
```


```
[fmaxance@storage ~]$ cat /etc/exports
/mnt/storage/site_web_1/	192.168.1.2(rw,sync,no_root_squash,no_subtree_check)
/mnt/storage/site_web_2/	192.168.1.2(rw,sync,no_root_squash,no_subtree_check)
```


🌞 **Donnez les commandes réalisées sur le client NFS `web.tp4.linux`**
```
[fmaxance@web ~]$ sudo dnf install nfs-utils
```

```
[fmaxance@web ~]$ sudo mkdir -p /var/www/site_web_1/
[fmaxance@web ~]$ sudo mkdir -p /var/www/site_web_2/
[fmaxance@web ~]$ sudo mount 192.168.1.3:/mnt/storage/site_web_1/ /var/www/site_web_1/
[fmaxance@web ~]$ sudo mount 192.168.1.3:/mnt/storage/site_web_2/ /var/www/site_web_2/
```

```
[fmaxance@web ~]$ df -h | grep storage
192.168.1.3:/mnt/storage/site_web_1  2.0G     0  1.9G   0% /var/www/site_web_1
192.168.1.3:/mnt/storage/site_web_2  2.0G     0  1.9G   0% /var/www/site_web_2
```

```
[fmaxance@web ~]$ cat /etc/fstab 

#
# /etc/fstab
# Created by anaconda on Sat Oct 15 12:47:23 2022
#
# Accessible filesystems, by reference, are maintained under '/dev/disk/'.
# See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info.
#
# After editing this file, run 'systemctl daemon-reload' to update systemd
# units generated from this file.
#
/dev/mapper/rl-root     /                       xfs     defaults        0 0
UUID=2df805a9-4569-4da4-8afe-e3ee298680df /boot                   xfs     defaults        0 0
/dev/mapper/rl-swap     none                    swap    defaults        0 0
192.168.1.3:/mnt/storage/site_web_1 /var/www/site_web_1/ ext4 defaults 0 0
192.168.1.3:/mnt/storage/site_web_2 /var/www/site_web_2/ ext4 defaults 0 0
```

# Partie 3 : Serveur web

## 1. Intro NGINX

## 2. Install
🌞 **Installez NGINX**

```
[fmaxance@web ~]$ sudo dnf install nginx
```

## 3. Analyse

```
[fmaxance@web ~]$ sudo systemctl start nginx
[fmaxance@web ~]$ sudo systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
     Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
     Active: active (running) since Tue 2022-12-06 14:06:53 CET; 4s ago
    Process: 2168 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
    Process: 2169 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
    Process: 2170 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
   Main PID: 2171 (nginx)
      Tasks: 2 (limit: 4638)
     Memory: 1.9M
        CPU: 12ms
     CGroup: /system.slice/nginx.service
             ├─2171 "nginx: master process /usr/sbin/nginx"
             └─2172 "nginx: worker process"

Dec 06 14:06:53 web systemd[1]: Starting The nginx HTTP and reverse proxy server...
Dec 06 14:06:53 web nginx[2169]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
Dec 06 14:06:53 web nginx[2169]: nginx: configuration file /etc/nginx/nginx.conf test is successful
Dec 06 14:06:53 web systemd[1]: Started The nginx HTTP and reverse proxy server.
```

🌞 **Analysez le service NGINX**

```
[fmaxance@web ~]$ ps -ef | grep nginx
root        2171       1  0 14:06 ?        00:00:00 nginx: master process /usr/sbin/nginx
nginx       2172    2171  0 14:06 ?        00:00:00 nginx: worker process
fmaxance       2183    1210  0 14:07 pts/0    00:00:00 grep --color=auto nginx
```
```
[fmaxance@web ~]$ sudo ss -lntup | grep nginx
tcp   LISTEN 0      511          0.0.0.0:80        0.0.0.0:*    users:(("nginx",pid=2172,fd=6),("nginx",pid=2171,fd=6))
tcp   LISTEN 0      511             [::]:80           [::]:*    users:(("nginx",pid=2172,fd=7),("nginx",pid=2171,fd=7))
```
```
[fmaxance@web ~]$ ls -al /usr/share/nginx/html/index.html 
lrwxrwxrwx. 1 root root 25 Oct 31 16:37 /usr/share/nginx/html/index.html -> ../../testpage/index.html
```

## 4. Visite du service web

🌞 **Configurez le firewall pour autoriser le trafic vers le service NGINX**

```
[fmaxance@web ~]$ sudo firewall-cmd --zone=public --permanent --add-service=http
success
[fmaxance@web ~]$ sudo firewall-cmd --reload
success
```

🌞 **Accéder au site web**

```
maxfe@MSI MINGW64:~$ curl http://192.168.1.2
<!doctype html>
<html>
  <head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
    <title>HTTP Server Test Page powered by: Rocky Linux</title>
```

🌞 **Vérifier les logs d'accès**

```
[fmaxance@web ~]$ sudo cat /var/log/nginx/access.log | tail -n 3
192.168.1.0 - - [06/Dec/2022:14:19:40 +0100] "GET /poweredby.png HTTP/1.1" 200 368 "http://192.168.1.2/" "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:107.0) Gecko/20100101 Firefox/107.0" "-"
192.168.1.0 - - [06/Dec/2022:14:19:41 +0100] "GET /favicon.ico HTTP/1.1" 404 3332 "http://192.168.1.2/" "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:107.0) Gecko/20100101 Firefox/107.0" "-"
192.168.1.0 - - [06/Dec/2022:14:20:06 +0100] "GET / HTTP/1.1" 200 7620 "-" "curl/7.81.0" "-"
```

## 5. Modif de la conf du serveur web

🌞 **Changer le port d'écoute**

```
listen       8080;
listen       [::]:8080;
```
```
[fmaxance@web ~]$ sudo ss -lntup | grep nginx
tcp   LISTEN 0      511          0.0.0.0:8080      0.0.0.0:*    users:(("nginx",pid=2387,fd=6),("nginx",pid=2386,fd=6))
tcp   LISTEN 0      511             [::]:8080         [::]:*    users:(("nginx",pid=2387,fd=7),("nginx",pid=2386,fd=7))
```

```
[fmaxance@web ~]$ sudo firewall-cmd --zone=public --permanent --remove-service=http
success
[fmaxance@web ~]$ sudo firewall-cmd --zone=public --permanent --add-port 8080/tcp
success
[fmaxance@web ~]$ sudo firewall-cmd --reload
success
```

```
maxfe@MSI MINGW64:~$ curl http://192.168.1.2:8080
<!doctype html>
<html>
  <head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
    <title>HTTP Server Test Page powered by: Rocky Linux</title>
    <style type="text/css">
      /*<![CDATA[*/
      
```

🌞 **Changer l'utilisateur qui lance le service**

```
[fmaxance@web ~]$ sudo useradd web
[fmaxance@web ~]$ sudo passwd web
Changing password for user web.
```
```
[fmaxance@web ~]$ sudo cat /etc/nginx/nginx.conf | grep user
user web;
[fmaxance@web ~]$ ps -ef | grep nginx
root        2587       1  0 14:35 ?        00:00:00 nginx: master process /usr/sbin/nginx
web         2588    2587  0 14:35 ?        00:00:00 nginx: worker process
fmaxance       2596    1210  0 14:35 pts/0    00:00:00 grep --color=auto nginx
```

**Il est temps d'utiliser ce qu'on a fait à la partie 2 !**

🌞 **Changer l'emplacement de la racine Web**

```
[fmaxance@web ~]$ sudo cat /etc/nginx/nginx.conf | grep web
        root         /var/www/site_web_1/;
```

## 6. Deux sites web sur un seul serveur


🌞 **Repérez dans le fichier de conf**

```
[fmaxance@web ~]$ sudo cat /etc/nginx/nginx.conf | grep conf.d
    # Load modular configuration files from the /etc/nginx/conf.d directory.
    include /etc/nginx/conf.d/*.conf;
```
🌞 **Créez le fichier de configuration pour le premier site**

```
[fmaxance@web ~]$ cat /etc/nginx/conf.d/site_web_1.conf 
server {
	listen       8080;
        listen       [::]:8080;
        server_name  _;
        root         /var/www/site_web_1/;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        error_page 404 /404.html;
        location = /404.html {
        }

        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
        }

}
```

🌞 **Créez le fichier de configuration pour le deuxième site**

```
[fmaxance@web ~]$ cat /etc/nginx/conf.d/site_web_2.conf 
server {
        listen       8888;
        listen       [::]:8888;
        server_name  _;
        root         /var/www/site_web_2/;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        error_page 404 /404.html;
        location = /404.html {
        }

	error_page 500 502 503 504 /50x.html;
        location = /50x.html {
        }

}
```

```
[fmaxance@web ~]$ sudo firewall-cmd --zone=public --permanent --add-port 8888/tcp
success
[fmaxance@web ~]$ sudo systemctl restart nginx
[fmaxance@web ~]$ sudo firewall-cmd --reload
success
```

🌞 **Prouvez que les deux sites sont disponibles**

```
maxfe@MSI MINGW64:~$ curl http://192.168.1.2:8080
 <!DOCTYPE html>
<html>
<body>

<h1>HEHEHE</h1>

</body>
</html> 
maxfe@MSI MINGW64:~$ curl http://192.168.1.2:8888
 <!DOCTYPE html>
<html>
<body>

<h1>2</h1>

</body>
</html>
```