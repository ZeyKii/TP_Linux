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

Petite section de mise en place du serveur de base de données sur `db.tp5.linux`. On ira pas aussi loin qu'Apache pour lui, simplement l'installer, faire une configuration élémentaire avec une commande guidée (`mysql_secure_installation`), et l'analyser un peu.

🖥️ **VM db.tp5.linux**

**N'oubliez pas de dérouler la [📝**checklist**📝](#checklist).**

| Machines        | IP            | Service                 |
|-----------------|---------------|-------------------------|
| `web.tp5.linux` | `10.105.1.11` | Serveur Web             |
| `db.tp5.linux`  | `10.105.1.12` | Serveur Base de Données |

🌞 **Install de MariaDB sur `db.tp5.linux`**

- déroulez [la doc d'install de Rocky](https://docs.rockylinux.org/guides/database/database_mariadb-server/)
- je veux dans le rendu **toutes** les commandes réalisées
- faites en sorte que le service de base de données démarre quand la machine s'allume
  - pareil que pour le serveur web, c'est une commande `systemctl` fiez-vous au mémo

🌞 **Port utilisé par MariaDB**

- vous repérerez le port utilisé par MariaDB avec une commande `ss` exécutée sur `db.tp5.linux`
  - filtrez les infos importantes avec un `| grep`
- il sera nécessaire de l'ouvrir dans le firewall

> La doc vous fait exécuter la commande `mysql_secure_installation` c'est un bon réflexe pour renforcer la base qui a une configuration un peu *chillax* à l'install.

🌞 **Processus liés à MariaDB**

- repérez les processus lancés lorsque vous lancez le service MariaDB
- utilisz une commande `ps`
  - filtrez les infos importantes avec un `| grep`

➜ **Une fois la db en place, go sur [la partie 3.](../part3/README.md)**