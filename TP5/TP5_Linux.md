# TP5 : Self-hosted cloud

# Partie 1 : Mise en place et maîtrise du serveur Web

🌞 **TEST**

```
[fmaxance@weblinuxtp5 ~]$ systemctl status httpd
● httpd.service - The Apache HTTP Server
     Loaded: loaded (/usr/lib/systemd/system/httpd.service; enabled; vendor preset: disabled)
     Active: active (running) since Tue 2023-01-17 11:18:50 CET; 10min ago
       Docs: man:httpd.service(8)
   Main PID: 690 (httpd)
     Status: "Total requests: 6; Idle/Busy workers 100/0;Requests/sec: 0.01; Bytes served/sec:  79 B/sec"
      Tasks: 213 (limit: 11118)
     Memory: 28.5M
        CPU: 244ms
     CGroup: /system.slice/httpd.service
             ├─690 /usr/sbin/httpd -DFOREGROUND
             ├─717 /usr/sbin/httpd -DFOREGROUND
             ├─719 /usr/sbin/httpd -DFOREGROUND
             ├─720 /usr/sbin/httpd -DFOREGROUND
             └─721 /usr/sbin/httpd -DFOREGROUND

Jan 17 11:18:50 weblinuxtp5 systemd[1]: Starting The Apache HTTP Server...
Jan 17 11:18:50 weblinuxtp5 httpd[690]: AH00558: httpd: Could not reliably determine the server's fully qualified domai>
Jan 17 11:18:50 weblinuxtp5 systemd[1]: Started The Apache HTTP Server.
Jan 17 11:18:50 weblinuxtp5 httpd[690]: Server configured, listening on: port 80
```

```
maxfe@MSI MINGW64 ~
$ curl 10.105.1.11 | head -n 15
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  7620  100  7620    0     0  4136k      0 --:--:-- --:--:-- --:--:-- 7441k
<!doctype html>
<html>
  <head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
    <title>HTTP Server Test Page powered by: Rocky Linux</title>
    <style type="text/css">
      /*<![CDATA[*/

      html {
        height: 100%;
        width: 100%;
      }
        body {
  background: rgb(20,72,50);
```

## 2. Avancer vers la maîtrise du service

🌞 **Le service Apache...**

```
[fmaxance@weblinuxtp5 ~]$ cat /usr/lib/systemd/system/httpd.service
# See httpd.service(8) for more information on using the httpd service.

# Modifying this file in-place is not recommended, because changes
# will be overwritten during package upgrades.  To customize the
# behaviour, run "systemctl edit httpd" to create an override unit.

# For example, to pass additional options (such as -D definitions) to
# the httpd binary at startup, create an override unit (as is done by
# systemctl edit) and enter the following:

#       [Service]
#       Environment=OPTIONS=-DMY_DEFINE

[Unit]
Description=The Apache HTTP Server
Wants=httpd-init.service
After=network.target remote-fs.target nss-lookup.target httpd-init.service
Documentation=man:httpd.service(8)

[Service]
Type=notify
Environment=LANG=C

ExecStart=/usr/sbin/httpd $OPTIONS -DFOREGROUND
ExecReload=/usr/sbin/httpd $OPTIONS -k graceful
# Send SIGWINCH for graceful stop
KillSignal=SIGWINCH
KillMode=mixed
PrivateTmp=true
OOMPolicy=continue

[Install]
WantedBy=multi-user.target
```

🌞 **Déterminer sous quel utilisateur tourne le processus Apache**

```
[fmaxance@weblinuxtp5 ~]$ cat /etc/httpd/conf/httpd.conf | grep User
User apache
```

```
[fmaxance@weblinuxtp5 ~]$ ps -ef | grep httpd
root         690       1  0 11:18 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache       717     690  0 11:18 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache       719     690  0 11:18 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache       720     690  0 11:18 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache       721     690  0 11:18 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
```

```
[fmaxance@weblinuxtp5 ~]$ ls -al /usr/share/testpage/
total 12
drwxr-xr-x.  2 root root   24 Jan 17 11:02 .
drwxr-xr-x. 82 root root 4096 Jan 17 11:02 ..
-rw-r--r--.  1 root root 7620 Jul 27 20:05 index.html
```

On voit le "r" signifiant "read" et sur : proriétaire, group et autre.
Donc tout son contenu est accessible en lecture pour l'utilisateur "apache".

🌞 **Changer l'utilisateur utilisé par Apache**

```
[fmaxance@weblinuxtp5 ~]$ cat /etc/passwd | grep MaxouApache
MaxouApache:x:48:48:Apache:/usr/share/httpd:/sbin/nologin
```

```
[fmaxance@weblinuxtp5 ~]$ cat /etc/httpd/conf/httpd.conf | grep User
User MaxouApache
```

```
[fmaxance@weblinuxtp5 ~]$ ps -ef | grep httpd
root        1541       1  0 12:08 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
MaxouAp+    1542    1541  0 12:08 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
MaxouAp+    1543    1541  0 12:08 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
MaxouAp+    1544    1541  0 12:08 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
MaxouAp+    1545    1541  0 12:08 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
fmaxance    1760    1424  0 12:09 pts/0    00:00:00 grep --color=auto httpd
```

🌞 **Faites en sorte que Apache tourne sur un autre port**

On choisit un nouveau port :

```
[fmaxance@weblinuxtp5 ~]$ echo $RANDOM
16753
```

```
[fmaxance@weblinuxtp5 ~]$ sudo firewall-cmd --add-port=16753/tcp --permanent
success
```

```
[fmaxance@weblinuxtp5 ~]$ sudo firewall-cmd --remove-port=80/tcp --permanent
success
```

```
[fmaxance@weblinuxtp5 ~]$ sudo ss -ltunp | grep httpd
tcp   LISTEN 0      511                *:16753            *:*    users:(("httpd",pid=1787,fd=4),("httpd",pid=1786,fd=4),("httpd",pid=1785,fd=4),("httpd",pid=1783,fd=4))
```

```
maxfe@MSI MINGW64 ~
$ curl 10.105.1.11:16753 | head -n 15
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  7620  100  7620    0     0  7020k      0 --:--:-- --:--:-- --:--:-- 7441k<!doctype html>
<html>
  <head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
    <title>HTTP Server Test Page powered by: Rocky Linux</title>
    <style type="text/css">
      /*<![CDATA[*/

      html {
        height: 100%;
        width: 100%;
      }
        body {

  background: rgb(20,72,50);
```

📁 **Fichier `/etc/httpd/conf/httpd.conf`**

[ApacheConfig File](/TP5/etc/httpd/conf/httpd.conf)

# Partie 2 : Mise en place et maîtrise du serveur de base de données

🌞 **Install de MariaDB sur `db.tp5.linux`**

```
[fmaxance@dblinuxtp5 ~]$ sudo dnf install mariadb-server
[sudo] password for fmaxance:
Rocky Linux 9 - BaseOS                                                                  9.4 kB/s | 3.6 kB     00:00
Rocky Linux 9 - AppStream                                                               783  B/s | 4.1 kB     00:05
Rocky Linux 9 - AppStream                                                               8.7 MB/s | 6.4 MB     00:00
Rocky Linux 9 - Extras                                                                   10 kB/s | 2.9 kB     00:00
Dependencies resolved.
========================================================================================================================
 Package                                 Architecture      Version                           Repository            Size
========================================================================================================================
Installing:
 mariadb-server                          x86_64            3:10.5.16-2.el9_0                 appstream            9.4 M
 ```
 
 ```
 [fmaxance@dblinuxtp5 ~]$ sudo systemctl enable mariadb
Created symlink /etc/systemd/system/mysql.service → /usr/lib/systemd/system/mariadb.service.
Created symlink /etc/systemd/system/mysqld.service → /usr/lib/systemd/system/mariadb.service.
Created symlink /etc/systemd/system/multi-user.target.wants/mariadb.service → /usr/lib/systemd/system/mariadb.service.
```

```
[fmaxance@dblinuxtp5 ~]$ sudo systemctl start mariadb
```

```
[fmaxance@dblinuxtp5 ~]$ sudo mysql_secure_installation

NOTE: RUNNING ALL PARTS OF THIS SCRIPT IS RECOMMENDED FOR ALL MariaDB
      SERVERS IN PRODUCTION USE!  PLEASE READ EACH STEP CAREFULLY!

In order to log into MariaDB to secure it, we'll need the current
password for the root user. If you've just installed MariaDB, and
haven't set the root password yet, you should just press enter here.

Enter current password for root (enter for none):
OK, successfully used password, moving on...

Setting the root password or using the unix_socket ensures that nobody
can log into the MariaDB root user without the proper authorisation.

You already have your root account protected, so you can safely answer 'n'.

Switch to unix_socket authentication [Y/n] n
 ... skipping.

You already have your root account protected, so you can safely answer 'n'.

Change the root password? [Y/n]
New password:
Re-enter new password:
Password updated successfully!
Reloading privilege tables..
 ... Success!


By default, a MariaDB installation has an anonymous user, allowing anyone
to log into MariaDB without having to have a user account created for
them.  This is intended only for testing, and to make the installation
go a bit smoother.  You should remove them before moving into a
production environment.

Remove anonymous users? [Y/n]
 ... Success!

Normally, root should only be allowed to connect from 'localhost'.  This
ensures that someone cannot guess at the root password from the network.

Disallow root login remotely? [Y/n]
 ... Success!

By default, MariaDB comes with a database named 'test' that anyone can
access.  This is also intended only for testing, and should be removed
before moving into a production environment.

Remove test database and access to it? [Y/n]
 - Dropping test database...
 ... Success!
 - Removing privileges on test database...
 ... Success!

Reloading the privilege tables will ensure that all changes made so far
will take effect immediately.

Reload privilege tables now? [Y/n]
 ... Success!

Cleaning up...

All done!  If you've completed all of the above steps, your MariaDB
installation should now be secure.

Thanks for using MariaDB!
```

```
sudo systemctl enable mariadb.service
```

🌞 **Port utilisé par MariaDB**

```
[fmaxance@dblinuxtp5 ~]$ sudo ss -ltunp | grep maria
tcp   LISTEN 0      80                 *:3306            *:*    users:(("mariadbd",pid=13249,fd=19))
```

```
[fmaxance@dblinuxtp5 ~]$ sudo firewall-cmd --add-port=3306/tcp --permanent
success
```

🌞 **Processus liés à MariaDB**

```
[fmaxance@dblinuxtp5 ~]$ ps -ef | grep mariadb
mysql      13249       1  0 14:06 ?        00:00:00 /usr/libexec/mariadbd --basedir=/usr
fmaxance   13480    1239  0 14:27 pts/0    00:00:00 grep --color=auto mariadb
```

# Partie 3 : Configuration et mise en place de NextCloud

## 1. Base de données

🌞 **Préparation de la base pour NextCloud**

```
[fmaxance@dblinuxtp5 ~]$ sudo mysql -u root -p
[sudo] password for fmaxance:
Enter password:
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 23
Server version: 10.5.16-MariaDB MariaDB Server

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]>
MariaDB [(none)]> CREATE USER 'nextcloud'@'10.105.1.11' IDENTIFIED BY 'pewpewpew';
Query OK, 0 rows affected (0.003 sec)

MariaDB [(none)]> CREATE DATABASE IF NOT EXISTS nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
Query OK, 1 row affected (0.000 sec)

MariaDB [(none)]> GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextcloud'@'10.105.1.11';
Query OK, 0 rows affected (0.001 sec)

MariaDB [(none)]> FLUSH PRIVILEGES;
Query OK, 0 rows affected (0.000 sec)

MariaDB [(none)]> Ctrl-C -- exit!
Aborted
```

🌞 **Exploration de la base de données**

```
[fmaxance@weblinuxtp5 ~]$ sudo dnf install mysql
[sudo] password for fmaxance:
Rocky Linux 9 - BaseOS                                                                   12 kB/s | 3.6 kB     00:00
Rocky Linux 9 - AppStream                                                                16 kB/s | 4.1 kB     00:00
Rocky Linux 9 - Extras                                                                   11 kB/s | 2.9 kB     00:00
Rocky Linux 9 - Extras                                                                   15 kB/s | 8.5 kB     00:00
Dependencies resolved.
========================================================================================================================
 Package                                 Architecture        Version                       Repository              Size
========================================================================================================================
Installing:
 mysql                                   x86_64              8.0.30-3.el9_0                appstream              2.8 M
```

```
[fmaxance@weblinuxtp5 ~]$ mysql -u nextcloud -h 10.105.1.12 -p
Enter password:
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 5
Server version: 5.5.5-10.5.16-MariaDB MariaDB Server

Copyright (c) 2000, 2022, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> SHOW DATABASES;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| nextcloud          |
+--------------------+
2 rows in set (0.00 sec)

mysql> USE nextcloud;
Database changed
mysql> SHOW TABLES;
Empty set (0.00 sec)

mysql>
```

🌞 **Trouver une commande SQL qui permet de lister tous les utilisateurs de la base de données**

```
[fmaxance@dblinuxtp5 ~]$ sudo mysql -u root -p
[sudo] password for fmaxance:
Enter password:
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 6
Server version: 10.5.16-MariaDB MariaDB Server

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> SELECT user FROM mysql.user;
+-------------+
| User        |
+-------------+
| nextcloud   |
| mariadb.sys |
| mysql       |
| root        |
+-------------+
4 rows in set (0.004 sec)
```

## 2. Serveur Web et NextCloud

🌞 **Install de PHP**

```
[fmaxance@weblinuxtp5 ~]$ sudo dnf config-manager --set-enabled crb
```

```
[fmaxance@weblinuxtp5 ~]$ sudo dnf install dnf-utils http://rpms.remirepo.net/enterprise/remi-release-9.rpm -y
Rocky Linux 9 - BaseOS                                                                  6.4 kB/s | 3.6 kB     00:00
Rocky Linux 9 - AppStream                                                               8.6 kB/s | 4.1 kB     00:00
Rocky Linux 9 - CRB                                                                     1.9 MB/s | 2.0 MB     00:01
remi-release-9.rpm                                                                      164 kB/s |  28 kB     00:00
Dependencies resolved.
========================================================================================================================
 Package                               Architecture        Version                      Repository                 Size
========================================================================================================================
Installing:
 remi-release                          noarch              9.1-2.el9.remi               @commandline               28 k
 yum-utils                             noarch              4.1.0-3.el9                  baseos                     36 k
```

```
[fmaxance@weblinuxtp5 ~]$ dnf module list php
Extra Packages for Enterprise Linux 9 - x86_64                                          2.9 MB/s |  13 MB     00:04
Remi's Modular repository for Enterprise Linux 9 - x86_64                               2.4 kB/s | 833  B     00:00
Remi's Modular repository for Enterprise Linux 9 - x86_64                               3.0 MB/s | 3.1 kB     00:00
Importing GPG key 0x478F8947:
 Userid     : "Remi's RPM repository (https://rpms.remirepo.net/) <remi@remirepo.net>"
 Fingerprint: B1AB F71E 14C9 D748 97E1 98A8 B195 27F1 478F 8947
 From       : /etc/pki/rpm-gpg/RPM-GPG-KEY-remi.el9
```

```
[fmaxance@weblinuxtp5 ~]$ sudo dnf module enable php:remi-8.1 -y
Extra Packages for Enterprise Linux 9 - x86_64                                          3.8 MB/s |  13 MB     00:03
Remi's Modular repository for Enterprise Linux 9 - x86_64                               2.9 kB/s | 833  B     00:00
Remi's Modular repository for Enterprise Linux 9 - x86_64                               3.0 MB/s | 3.1 kB     00:00
Importing GPG key 0x478F8947:
 Userid     : "Remi's RPM repository (https://rpms.remirepo.net/) <remi@remirepo.net>"
 Fingerprint: B1AB F71E 14C9 D748 97E1 98A8 B195 27F1 478F 8947
 From       : /etc/pki/rpm-gpg/RPM-GPG-KEY-remi.el9
Remi's Modular repository for Enterprise Linux 9 - x86_64                               1.1 MB/s | 837 kB     00:00
Safe Remi's RPM repository for Enterprise Linux 9 - x86_64                              3.0 kB/s | 833  B     00:00
Safe Remi's RPM repository for Enterprise Linux 9 - x86_64                              3.0 MB/s | 3.1 kB     00:00
Importing GPG key 0x478F8947:
 Userid     : "Remi's RPM repository (https://rpms.remirepo.net/) <remi@remirepo.net>"
 Fingerprint: B1AB F71E 14C9 D748 97E1 98A8 B195 27F1 478F 8947
 From       : /etc/pki/rpm-gpg/RPM-GPG-KEY-remi.el9
Safe Remi's RPM repository for Enterprise Linux 9 - x86_64                              1.2 MB/s | 889 kB     00:00
Dependencies resolved.
========================================================================================================================
 Package                     Architecture               Version                       Repository                   Size
========================================================================================================================
Enabling module streams:
 php                                                    remi-8.1

Transaction Summary
========================================================================================================================

Complete!
```

```
[fmaxance@weblinuxtp5 ~]$ sudo dnf install -y php81-php
Last metadata expiration check: 0:00:48 ago on Fri 20 Jan 2023 02:56:36 PM CET.
Dependencies resolved.
========================================================================================================================
 Package                                  Architecture       Version                        Repository             Size
========================================================================================================================
Installing:
 php81-php                                x86_64             8.1.14-1.el9.remi              remi-safe             1.7 M
```

🌞 **Install de tous les modules PHP nécessaires pour NextCloud**

```
[fmaxance@weblinuxtp5 ~]$ sudo dnf install -y libxml2 openssl php81-php php81-php-ctype php81-php-curl php81-php-gd php81-php-iconv php81-php-json php81-php-libxml php81-php-mbstring php81-php-openssl php81-php-posix php81-php-session php81-php-xml php81-php-zip php81-php-zlib php81-php-pdo php81-php-mysqlnd php81-php-intl php81-php-bcmath php81-php-gmp
Last metadata expiration check: 0:02:08 ago on Fri 20 Jan 2023 02:56:36 PM CET.
Package libxml2-2.9.13-1.el9_0.1.x86_64 is already installed.
Package openssl-1:3.0.1-41.el9_0.x86_64 is already installed.
Package php81-php-8.1.14-1.el9.remi.x86_64 is already installed.
Package php81-php-common-8.1.14-1.el9.remi.x86_64 is already installed.
Package php81-php-common-8.1.14-1.el9.remi.x86_64 is already installed.
Package php81-php-common-8.1.14-1.el9.remi.x86_64 is already installed.
Package php81-php-common-8.1.14-1.el9.remi.x86_64 is already installed.
Package php81-php-common-8.1.14-1.el9.remi.x86_64 is already installed.
Package php81-php-mbstring-8.1.14-1.el9.remi.x86_64 is already installed.
Package php81-php-common-8.1.14-1.el9.remi.x86_64 is already installed.
Package php81-php-common-8.1.14-1.el9.remi.x86_64 is already installed.
Package php81-php-xml-8.1.14-1.el9.remi.x86_64 is already installed.
Package php81-php-common-8.1.14-1.el9.remi.x86_64 is already installed.
Package php81-php-pdo-8.1.14-1.el9.remi.x86_64 is already installed.
Dependencies resolved.
========================================================================================================================
 Package                          Architecture         Version                            Repository               Size
========================================================================================================================
Installing:
 php81-php-bcmath                 x86_64               8.1.14-1.el9.remi                  remi-safe                38 k
 php81-php-gd                     x86_64               8.1.14-1.el9.remi                  remi-safe                45 k
 php81-php-gmp                    x86_64               8.1.14-1.el9.remi                  remi-safe                35 k
 php81-php-intl                   x86_64               8.1.14-1.el9.remi                  remi-safe               155 k
 php81-php-mysqlnd                x86_64               8.1.14-1.el9.remi                  remi-safe               147 k
 php81-php-pecl-zip               x86_64               1.21.1-1.el9.remi                  remi-safe                58 k
 php81-php-process                x86_64               8.1.14-1.el9.remi                  remi-safe                44 k
```

🌞 **Récupérer NextCloud**

```
[fmaxance@weblinuxtp5 ~]$ sudo mkdir /var/www/tp5_nextcloud/
```

```
[fmaxance@weblinuxtp5 /]$ ls /var/www/tp5_nextcloud/ | grep index.html
index.html
```

```
[fmaxance@weblinuxtp5 /]$ ls -al /var/www/tp5_nextcloud/
total 140
drwxr-xr-x. 14 apache root      4096 Jan 20 15:11 .
drwxr-xr-x.  5 root   root        54 Jan 20 15:00 ..
drwxr-xr-x. 47 apache fmaxance  4096 Oct  6 14:47 3rdparty
drwxr-xr-x. 50 apache fmaxance  4096 Oct  6 14:44 apps
-rw-r--r--.  1 apache fmaxance 19327 Oct  6 14:42 AUTHORS
drwxr-xr-x.  2 apache fmaxance    67 Oct  6 14:47 config
-rw-r--r--.  1 apache fmaxance  4095 Oct  6 14:42 console.php
-rw-r--r--.  1 apache fmaxance 34520 Oct  6 14:42 COPYING
drwxr-xr-x. 23 apache fmaxance  4096 Oct  6 14:47 core
-rw-r--r--.  1 apache fmaxance  6317 Oct  6 14:42 cron.php
drwxr-xr-x.  2 apache fmaxance  8192 Oct  6 14:42 dist
-rw-r--r--.  1 apache fmaxance  3253 Oct  6 14:42 .htaccess
-rw-r--r--.  1 apache fmaxance   156 Oct  6 14:42 index.html
-rw-r--r--.  1 apache fmaxance  3456 Oct  6 14:42 index.php
drwxr-xr-x.  6 apache fmaxance   125 Oct  6 14:42 lib
-rw-r--r--.  1 apache fmaxance   283 Oct  6 14:42 occ
drwxr-xr-x.  2 apache fmaxance    23 Oct  6 14:42 ocm-provider
drwxr-xr-x.  2 apache fmaxance    55 Oct  6 14:42 ocs
drwxr-xr-x.  2 apache fmaxance    23 Oct  6 14:42 ocs-provider
-rw-r--r--.  1 apache fmaxance  3139 Oct  6 14:42 public.php
-rw-r--r--.  1 apache fmaxance  5426 Oct  6 14:42 remote.php
drwxr-xr-x.  4 apache fmaxance   133 Oct  6 14:42 resources
-rw-r--r--.  1 apache fmaxance    26 Oct  6 14:42 robots.txt
-rw-r--r--.  1 apache fmaxance  2452 Oct  6 14:42 status.php
drwxr-xr-x.  3 apache fmaxance    35 Oct  6 14:42 themes
drwxr-xr-x.  2 apache fmaxance    43 Oct  6 14:44 updater
-rw-r--r--.  1 apache fmaxance   101 Oct  6 14:42 .user.ini
-rw-r--r--.  1 apache fmaxance   387 Oct  6 14:47 version.php
```

🌞 **Adapter la configuration d'Apache**

```
[fmaxance@weblinuxtp5 /]$ cat /etc/httpd/conf/httpd.conf | grep IncludeOptional
IncludeOptional conf.d/*.conf
```

```
[fmaxance@weblinuxtp5 /]$ ls /etc/httpd/conf.d/ | grep webroot.conf
webroot.conf
```

```
[fmaxance@weblinuxtp5 /]$ cat /etc/httpd/conf.d/webroot.conf
<VirtualHost *:80>
  # on indique le chemin de notre webroot
  DocumentRoot /var/www/tp5_nextcloud/
  # on précise le nom que saisissent les clients pour accéder au service
  ServerName  web.tp5.linux

  # on définit des règles d'accès sur notre webroot
  <Directory /var/www/tp5_nextcloud/>
    Require all granted
    AllowOverride All
    Options FollowSymLinks MultiViews
    <IfModule mod_dav.c>
      Dav off
    </IfModule>
  </Directory>
</VirtualHost>
```

🌞 **Redémarrer le service Apache** pour qu'il prenne en compte le nouveau fichier de conf

```
[fmaxance@weblinuxtp5 /]$ sudo systemctl stop httpd
[fmaxance@weblinuxtp5 /]$
[fmaxance@weblinuxtp5 /]$ sudo systemctl start httpd
[fmaxance@weblinuxtp5 /]$
[fmaxance@weblinuxtp5 /]$ systemctl status httpd
● httpd.service - The Apache HTTP Server
     Loaded: loaded (/usr/lib/systemd/system/httpd.service; enabled; vendor preset: disabled)
    Drop-In: /usr/lib/systemd/system/httpd.service.d
             └─php81-php-fpm.conf
     Active: active (running) since Fri 2023-01-20 15:25:27 CET; 7s ago
       Docs: man:httpd.service(8)
   Main PID: 5232 (httpd)
     Status: "Started, listening on: port 80"
      Tasks: 213 (limit: 11118)
     Memory: 22.8M
        CPU: 43ms
     CGroup: /system.slice/httpd.service
             ├─5232 /usr/sbin/httpd -DFOREGROUND
             ├─5239 /usr/sbin/httpd -DFOREGROUND
             ├─5240 /usr/sbin/httpd -DFOREGROUND
             ├─5241 /usr/sbin/httpd -DFOREGROUND
             └─5242 /usr/sbin/httpd -DFOREGROUND

Jan 20 15:25:26 weblinuxtp5 systemd[1]: Starting The Apache HTTP Server...
Jan 20 15:25:27 weblinuxtp5 httpd[5232]: AH00558: httpd: Could not reliably determine the server's fully qualified doma>
Jan 20 15:25:27 weblinuxtp5 systemd[1]: Started The Apache HTTP Server.
Jan 20 15:25:27 weblinuxtp5 httpd[5232]: Server configured, listening on: port 80
```

## 3. Finaliser l'installation de NextCloud

➜ **Sur votre PC**

- modifiez votre fichier `hosts` (oui, celui de votre PC, de votre hôte)
  - pour pouvoir joindre l'IP de la VM en utilisant le nom `web.tp5.linux`
- avec un navigateur, visitez NextCloud à l'URL `http://web.tp5.linux`
  - c'est possible grâce à la modification de votre fichier `hosts`
- on va vous demander un utilisateur et un mot de passe pour créer un compte admin
  - ne saisissez rien pour le moment
- cliquez sur "Storage & Database" juste en dessous
  - choisissez "MySQL/MariaDB"
  - saisissez les informations pour que NextCloud puisse se connecter avec votre base
- saisissez l'identifiant et le mot de passe admin que vous voulez, et validez l'installation

🌴 **C'est chez vous ici**, baladez vous un peu sur l'interface de NextCloud, faites le tour du propriétaire :)

🌞 **Exploration de la base de données**

- connectez vous en ligne de commande à la base de données après l'installation terminée
- déterminer combien de tables ont été crées par NextCloud lors de la finalisation de l'installation
  - ***bonus points*** si la réponse à cette question est automatiquement donnée par une requête SQL

➜ **NextCloud est tout bo, en place, vous pouvez aller sur [la partie 4.](../part4/README.md)**
