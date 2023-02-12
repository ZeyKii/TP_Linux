# Module 1 : Reverse Proxy


# I. Setup

🌞 **On utilisera NGINX comme reverse proxy**

```
[fmaxance@proxy ~]$ sudo dnf install nginx -y
```
```
[fmaxance@proxy ~]$ sudo systemctl start nginx
[fmaxance@proxy ~]$ sudo systemctl enable nginx
```
```
[fmaxance@proxy ~]$ sudo ss -ltunp | grep nginx
tcp   LISTEN 0      511          0.0.0.0:80        0.0.0.0:*    users:(("nginx",pid=1376,fd=6),("nginx",pid=1375,fd=6))
tcp   LISTEN 0      511             [::]:80           [::]:*    users:(("nginx",pid=1376,fd=7),("nginx",pid=1375,fd=7))
```
```
[fmaxance@proxy ~]$ sudo firewall-cmd --add-port=80/tcp --permanent
success
```
```
[fmaxance@proxy ~]$ sudo firewall-cmd --reload
success
```
```
[fmaxance@proxy ~]$ ps -ef | grep nginx
root        1375       1  0 15:31 ?        00:00:00 nginx: master process /usr/sbin/nginx
nginx       1376    1375  0 15:31 ?        00:00:00 nginx: worker process
fmaxance       1407    1180  0 15:33 pts/0    00:00:00 grep --color=auto nginx
```

```
maxfe@MSI MINGW64:~$ curl 10.105.1.15:80 | tail
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  7620  100  7620    0     0  4691k      0 --:--:-- --:--:-- --:--:-- 7441k
      </div>
      </div>
      
      <footer class="col-sm-12">
      <a href="https://apache.org">Apache&trade;</a> is a registered trademark of <a href="https://apache.org">the Apache Software Foundation</a> in the United States and/or other countries.<br />
      <a href="https://nginx.org">NGINX&trade;</a> is a registered trademark of <a href="https://">F5 Networks, Inc.</a>.
      </footer>
      
  </body>
</html>
```


🌞 **Configurer NGINX**

```
[fmaxance@proxy ~]$ cat /etc/nginx/conf.d/nginx.conf 
server {
    # On indique le nom que client va saisir pour accéder au service
    # Pas d'erreur ici, c'est bien le nom de web, et pas de proxy qu'on veut ici !
    server_name web.tp6.linux;

    # Port d'écoute de NGINX
    listen 80;

    location / {
        # On définit des headers HTTP pour que le proxying se passe bien
        proxy_set_header  Host $host;
        proxy_set_header  X-Real-IP $remote_addr;
        proxy_set_header  X-Forwarded-Proto https;
        proxy_set_header  X-Forwarded-Host $remote_addr;
        proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;

        # On définit la cible du proxying 
        proxy_pass http://10.105.1.11:80;
    }

    # Deux sections location recommandés par la doc NextCloud
    location /.well-known/carddav {
      return 301 $scheme://$host/remote.php/dav;
    }

    location /.well-known/caldav {
      return 301 $scheme://$host/remote.php/dav;
    }
}
```


➜ **Modifier votre fichier `hosts` de VOTRE PC**

```
maxfe@MSI MINGW64:~$ curl http://web.tp5.linux/
<!DOCTYPE html>
<html>
<head>
	<script> window.location.href="index.php"; </script>
	<meta http-equiv="refresh" content="0; URL=index.php">
</head>
</html>
```


🌞 **Faites en sorte de**

```
[fmaxance@web ~]$ sudo firewall-cmd --permanent --zone=drop --change-interface=enp0s8
The interface is under control of NetworkManager, setting zone to 'drop'.
success
```
```
[fmaxance@web ~]$ sudo firewall-cmd --permanent --zone=home --add-source=10.105.1.15
success
```
```
[fmaxance@web ~]$ sudo firewall-cmd --reload
success
```


🌞 **Une fois que c'est en place**

```
maxfe@MSI MINGW64:~$ ping 10.105.1.11
PING 10.105.1.11 (10.105.1.11) 56(84) bytes of data.
^C
--- 10.105.1.11 ping statistics ---
2 packets transmitted, 0 received, 100% packet loss, time 1028ms
```
```
maxfe@MSI MINGW64:~$ ping 10.105.1.15
PING 10.105.1.15 (10.105.1.15) 56(84) bytes of data.
64 bytes from 10.105.1.15: icmp_seq=1 ttl=64 time=0.496 ms
64 bytes from 10.105.1.15: icmp_seq=2 ttl=64 time=0.475 ms
^C
--- 10.105.1.15 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1015ms
rtt min/avg/max/mdev = 0.475/0.485/0.496/0.010 ms
```



# II. HTTPS


🌞 **Faire en sorte que NGINX force la connexion en HTTPS plutôt qu'HTTP**

```
[fmaxance@proxy ~]$ openssl genrsa -aes128 2048 > server.key 
[fmaxance@proxy ~]$ openssl rsa -in server.key -out server.key 
[fmaxance@proxy ~]$ openssl req -utf8 -new -key server.key -out server.csr
[fmaxance@proxy ~]$ openssl x509 -in server.csr -out server.crt -req -signkey server.key -days 3650 
[fmaxance@proxy ~]$ chmod 600 server.key
```

```
[fmaxance@proxy ~]$ cat /etc/nginx/conf.d/nginx.conf 
server {
    # On indique le nom que client va saisir pour accéder au service
    # Pas d'erreur ici, c'est bien le nom de web, et pas de proxy qu'on veut ici !
    server_name web.tp6.linux;

    # Port d'écoute de NGINX
    listen 443 ssl;
    server_name example.yourdomain.com;
    ssl_certificate  /home/fmaxance/server.crt;
    ssl_certificate_key  /home/fmaxance/server.key; 
    ssl_prefer_server_ciphers on;

    location / {
        # On définit des headers HTTP pour que le proxying se passe bien
        proxy_set_header  Host $host;
        proxy_set_header  X-Real-IP $remote_addr;
        proxy_set_header  X-Forwarded-Proto https;
        proxy_set_header  X-Forwarded-Host $remote_addr;
        proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;

        # On définit la cible du proxying 
        proxy_pass http://10.105.1.11:80;
    }

    # Deux sections location recommandés par la doc NextCloud
    location /.well-known/carddav {
      return 301 $scheme://$host/remote.php/dav;
    }

    location /.well-known/caldav {
      return 301 $scheme://$host/remote.php/dav;
    }
}
```
```
[fmaxance@proxy ~]$ sudo systemctl restart nginx
[fmaxance@proxy ~]$ sudo firewall-cmd --add-port=443/tcp --permanent
success
[fmaxance@proxy ~]$ sudo firewall-cmd --reload
success
[fmaxance@proxy ~]$ sudo firewall-cmd --remove-port=80/tcp --permanent
success
[fmaxance@proxy ~]$ sudo firewall-cmd --reload
success
```

```
maxfe@MSI MINGW64:~$ curl http://web.tp5.linux/
curl: (7) Failed to connect to web.tp5.linux port 80 after 1 ms: No route to host
maxfe@MSI MINGW64:~$ curl https://web.tp5.linux/
curl: (60) SSL certificate problem: self-signed certificate
More details here: https://curl.se/docs/sslcerts.html

curl failed to verify the legitimacy of the server and therefore could not
establish a secure connection to it. To learn more about this situation and
how to fix it, please visit the web page mentioned above.
```

# Module 2 : Sauvegarde du système de fichiers

## I. Script de backup

🌞 **Ecrire le script `bash`**

```
[fmaxance@web ~]$ cat /srv/tp6_backup.sh 
#!/bin/bash

# The script places the backup in the /srv/backup folder

[[ -d /srv/backup ]] || mkdir /srv/backup
dnf install tar -y
cd /var/www/tp5_nextcloud/
tar -czf /srv/backup/nextcloud_$( date '+%Y-%m-%d_%H-%M-%S' ).tar.gz themes/ data/ config/
```

➜ **Environnement d'exécution du script**

### 3. Service et timer

🌞 **Créez un *service*** système qui lance le script

```
[fmaxance@web ~]$ cat /etc/systemd/system/backup.service
[Unit]
Description=Backs up nextcloud files

[Service]
ExecStart=/srv/tp6_backup.sh
Type=oneshot

[Install]
WantedBy=multi-user.target
```

🌞 **Créez un *timer*** système qui lance le *service* à intervalles réguliers

```
[fmaxance@web ~]$ cat /etc/systemd/system/backup.timer
[Unit]
Description=Run backup service

[Timer]
OnCalendar=*-*-* 4:00:00

[Install]
WantedBy=timers.target
```
```
[fmaxance@web ~]$ sudo systemctl list-timers
NEXT                        LEFT         LAST                        PASSED       UNIT              >
Fri 2023-02-10 16:00:30 CET 1h 5min left Fri 2023-02-10 14:21:17 CET 34min ago    dnf-makecache.time>
Sat 2023-02-11 00:00:00 CET 9h left      Fri 2023-02-10 13:45:04 CET 1h 10min ago logrotate.timer   >
Sat 2023-02-11 04:00:00 CET 13h left     n/a                         n/a          backup.timer      >
Sat 2023-02-11 14:00:07 CET 23h left     Fri 2023-02-10 14:00:07 CET 55min ago    systemd-tmpfiles-c>

4 timers listed.
Pass --all to see loaded but inactive timers, too.
```

## II. NFS

### 1. Serveur NFS

🌞 **Préparer un dossier à partager sur le réseau** (sur la machine `storage.tp6.linux`)

```
[fmaxance@storage ~]$ sudo mkdir -p /srv/nfs_shares/web.tp6.linux/
```

🌞 **Installer le serveur NFS** (sur la machine `storage.tp6.linux`)

```
[fmaxance@storage ~]$ sudo dnf install nfs-utils -y
```
```
[fmaxance@storage ~]$ sudo systemctl enable nfs-server
```
```
[fmaxance@storage ~]$ sudo systemctl start nfs-server
Created symlink /etc/systemd/system/multi-user.target.wants/nfs-server.service → /usr/lib/systemd/system/nfs-server.service.
```
```
[fmaxance@storage ~]$ sudo systemctl start nfs-server
```
```
[fmaxance@storage ~]$ sudo firewall-cmd --permanent --add-service=nfs
success
```
```
[fmaxance@storage ~]$ sudo firewall-cmd --permanent --add-service=mountd
success
```
```
[fmaxance@storage ~]$ sudo firewall-cmd --permanent --add-service=rpc-bind
success
```
```
[fmaxance@storage ~]$ sudo firewall-cmd --reload
success
```
```
[fmaxance@storage ~]$ cat /etc/exports
/srv/nfs_shares/web.tp6.linux/	10.105.1.11(rw,sync,no_root_squash,insecure)
```

### 2. Client NFS

🌞 **Installer un client NFS sur `web.tp6.linux`**

```
[fmaxance@web ~]$ sudo dnf install nfs-utils -y
```
```
[fmaxance@web ~]$ sudo firewall-cmd --permanent --zone=home --add-source=10.105.1.20
success
```
```
[fmaxance@web ~]$ sudo firewall-cmd --reload
```
```
[fmaxance@web ~]$ sudo mount 10.105.1.20:/srv/nfs_shares/web.tp6.linux/ /srv/backup/
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

10.105.1.20:/srv/nfs_shares/web.tp6.linux/ /srv/backup/ ext4 defaults 0 0
```

# Module 3 : Fail2Ban

🌞 Faites en sorte que :

```
[fmaxance@db ~]$ sudo systemctl status fail2ban
● fail2ban.service - Fail2Ban Service
     Loaded: loaded (/usr/lib/systemd/system/fail2ban.service; enabled; vendor preset: disabled)
     Active: active (running) since Fri 2023-02-10 15:53:09 CET; 37min ago
       Docs: man:fail2ban(1)
    Process: 2290 ExecStartPre=/bin/mkdir -p /run/fail2ban (code=exited, status=0/SUCCESS)
   Main PID: 2291 (fail2ban-server)
      Tasks: 5 (limit: 4638)
     Memory: 18.4M
        CPU: 1.660s
     CGroup: /system.slice/fail2ban.service
             └─2291 /usr/bin/python3 -s /usr/bin/fail2ban-server -xf start

Jan 06 15:53:09 db systemd[1]: Starting Fail2Ban Service...
Jan 06 15:53:09 db systemd[1]: Started Fail2Ban Service.
Jan 06 15:53:09 db fail2ban-server[2291]: 2023-02-11 15:53:09,111 fail2ban.configreader   [2291]: WA>
Jan 06 15:53:09 db fail2ban-server[2291]: Server ready
```

```
[fmaxance@db ~]$ cat /etc/fail2ban/jail.local | head -n 108 | tail -n 9
# "bantime" is the number of seconds that a host is banned.
bantime  = 1000m

# A host is banned if it has generated "maxretry" during the last "findtime"
# seconds.
findtime  = 1m

# "maxretry" is the number of failures before a host get banned.
maxretry = 3
```

```
[fmaxance@web ~]$ ssh fmaxance@10.105.1.12
ssh: connect to host 10.105.1.12 port 22: Connection refused
```

```
[fmaxance@db ~]$ sudo iptables -L -n
[sudo] password for fmaxance: 
Chain INPUT (policy ACCEPT)
target     prot opt source               destination         
f2b-sshd   tcp  --  0.0.0.0/0            0.0.0.0/0            multiport dports 22

Chain FORWARD (policy ACCEPT)
target     prot opt source               destination         

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination         

Chain f2b-sshd (1 references)
target     prot opt source               destination         
REJECT     all  --  10.105.1.11          0.0.0.0/0            reject-with icmp-port-unreachable
RETURN     all  --  0.0.0.0/0            0.0.0.0/0           
```

```
[fmaxance@db ~]$ sudo fail2ban-client banned
[{'sshd': ['10.105.1.11']}]
```

```
sudo fail2ban-client set sshd unbanip 10.105.1.11
1
```

```
[fmaxance@db ~]$ sudo fail2ban-client banned
[{'sshd': []}]
```

```
The same config was installed on all 4 machines
```

# Module 4 : Monitoring

🌞 **Installer Netdata**

```
[fmaxance@db ~]$ wget -O /tmp/netdata-kickstart.sh https://my-netdata.io/kickstart.sh && sh /tmp/netdata-kickstart.sh 
[fmaxance@db ~]$ sudo systemctl start netdata
[fmaxance@db ~]$ sudo systemctl enable netdata
[fmaxance@db ~]$ sudo firewall-cmd --permanent --add-port=19999/tcp
success
[fmaxance@db ~]$ sudo firewall-cmd --reload
success
[fmaxance@db ~]$ sudo ss -ltunp | grep netdata
udp   UNCONN 0      0          127.0.0.1:8125       0.0.0.0:*    users:(("netdata",pid=3296,fd=47))
udp   UNCONN 0      0              [::1]:8125          [::]:*    users:(("netdata",pid=3296,fd=46))
tcp   LISTEN 0      4096       127.0.0.1:8125       0.0.0.0:*    users:(("netdata",pid=3296,fd=49))
tcp   LISTEN 0      4096         0.0.0.0:19999      0.0.0.0:*    users:(("netdata",pid=3296,fd=6)) 
tcp   LISTEN 0      4096           [::1]:8125          [::]:*    users:(("netdata",pid=3296,fd=48))
tcp   LISTEN 0      4096            [::]:19999         [::]:*    users:(("netdata",pid=3296,fd=7)) 
```



🌞 **Une fois Netdata installé et fonctionnel, déterminer :**

```
[fmaxance@db ~]$ ps -ef | grep netdata | head -n 5 | tail -n 1
netdata     3296       1  0 16:47 ?        00:00:03 /usr/sbin/netdata -P /run/netdata/netdata.pid -D

[fmaxance@db ~]$ sudo ss -ltunp | grep netdata
udp   UNCONN 0      0          127.0.0.1:8125       0.0.0.0:*    users:(("netdata",pid=3296,fd=47))
udp   UNCONN 0      0              [::1]:8125          [::]:*    users:(("netdata",pid=3296,fd=46))
tcp   LISTEN 0      4096       127.0.0.1:8125       0.0.0.0:*    users:(("netdata",pid=3296,fd=49))
tcp   LISTEN 0      4096         0.0.0.0:19999      0.0.0.0:*    users:(("netdata",pid=3296,fd=6)) 
tcp   LISTEN 0      4096           [::1]:8125          [::]:*    users:(("netdata",pid=3296,fd=48))
tcp   LISTEN 0      4096            [::]:19999         [::]:*    users:(("netdata",pid=3296,fd=7)) 
```

🌞 **Configurer Netdata pour qu'il vous envoie des alertes** 

```
[fmaxance@db ~]$ cd /etc/netdata/
[fmaxance@db ~]$ ./edit-config health_alarm_notify.conf

```

🌞 **Vérifier que les alertes fonctionnent**

```
[fmaxance@db netdata]$ sudo dnf install stress
[fmaxance@db netdata]$ stress --cpu 1
stress: info: [5218] dispatching hogs: 1 cpu, 0 io, 0 vm, 0 hdd
```
```
[fmaxance@db netdata]$ cat health.d/cpu.conf | head -n 19

# you can disable an alarm notification by setting the 'to' line to: silent

 template: 10min_cpu_usage
       on: system.cpu
    class: Utilization
     type: System
component: CPU
       os: linux
    hosts: *
   lookup: average -10m unaligned of user,system,softirq,irq,guest
    units: %
    every: 1min
     warn: $this > 10
     crit: $this > (($status == $CRITICAL) ? (85) : (95))
    delay: down 15m multiplier 1.5 max 1h
     info: average CPU utilization over the last 10 minutes (excluding iowait, nice and steal)
       to: sysadmin
```