# TP 3 : We do a little scripting

📁 **Fichier `/srv/idcard/idcard.sh`**

🌞 **Vous fournirez dans le compte-rendu**, en plus du fichier, **un exemple d'exécution avec une sortie**, dans des balises de code.

[IDcard script](srv/idcard/idcard.sh)

```
[fmaxance@localhost ~]$ /srv/idcard/idcard.sh
Machine name : localhost
OS Rocky Linux 9.0 (Blue Onyx) and kernel version is #1 SMP PREEMPT Tue Sep 20 17:53:31 UTC 2022
IP : 10.4.1.15/24
RAM : 2368 memory available on 2721 total memory
Disk : 760260 space left
Top 5 processes by RAM usage :
  - 2.1 657 /usr/bin/python3 -s /usr/sbin/firewalld --nofork --nopid
  - 1.1 686 /usr/sbin/NetworkManager --no-daemon
  - 0.8 1 /usr/lib/systemd/systemd --switched-root --system --deserialize 28
  - 0.7 1190 /usr/lib/systemd/systemd --user
  - 0.7 662 /usr/lib/systemd/systemd-logind
Listening ports :
  - 323 udp :
  - 22 tcp :
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 45837  100 45837    0     0   139k      0 --:--:-- --:--:-- --:--:--  139k
Here is your random cat : ./cat.jpg
```

# II. Script youtube-dl

📁 **Le script `/srv/yt/yt.sh`**

📁 **Le fichier de log `/var/log/yt/download.log`**, avec au moins quelques lignes

🌞 Vous fournirez dans le compte-rendu, en plus du fichier, **un exemple d'exécution avec une sortie**, dans des balises de code.

[YT script](srv/yt/yt.sh)

[YT log](var/log/yt/download.log)

```
[fmaxance@localhost ~]$ /srv/yt/yt.sh https://www.youtube.com/watch?v=37ftuqBA5C0
[youtube] 37ftuqBA5C0: Downloading webpage
[download] Destination: /srv/yt/downloads/Ohayo Pokko VO vs VF/Ohayo Pokko VO vs VF.mp4
[download] 100% of 612.42KiB in 00:10
Video https://www.youtube.com/watch?v=37ftuqBA5C0 was downloaded.
File path : /srv/yt/downloads/Ohayo Pokko VO vs VF/Ohayo Pokko VO vs VF.mp4
```

# III. MAKE IT A SERVICE

📁 **Le script `/srv/yt/yt-v2.sh`**

📁 **Fichier `/etc/systemd/system/yt.service`**

🌞 Vous fournirez dans le compte-rendu, en plus des fichiers :

- un `systemctl status yt` quand le service est en cours de fonctionnement
- un extrait de `journalctl -xe -u yt`

[YT-v2 script](srv/yt/yt-v2.sh)

[SystemFile](etc/systemd/system/yt.service)

```
● yt.service - Automatique youtube downloader
     Loaded: loaded (/etc/systemd/system/yt.service; disabled; vendor preset: disabled)
     Active: active (running) since Mon 2023-01-16 16:23:15 CET; 2s ago
   Main PID: 1964 (yt-v2.sh)
      Tasks: 2 (limit: 11118)
     Memory: 392.0K
        CPU: 2.425s
     CGroup: /system.slice/yt.service
             └─1964 /bin/bash /srv/yt/yt-v2.sh
```

```
[fmaxance@localhost ~]$ journalctl -xe -u yt
░░
░░ A start job for unit yt.service has finished successfully.
░░
░░ The job identifier is 1217.
Jan 16 16:12:38 localhost.localdomain systemd[1937]: yt.service: Failed to locate executable /srv/yt/yt-v2.sh: Permission denied
░░ Subject: Process /srv/yt/yt-v2.sh could not be executed
░░ Defined-By: systemd
░░ Support: https://access.redhat.com/support
░░
░░ The process /srv/yt/yt-v2.sh could not be executed and failed.
░░
░░ The error number returned by this process is ERRNO.
Jan 16 16:12:38 localhost.localdomain systemd[1937]: yt.service: Failed at step EXEC spawning /srv/yt/yt-v2.sh: Permission denied
░░ Subject: Process /srv/yt/yt-v2.sh could not be executed
░░ Defined-By: systemd
░░ Support: https://access.redhat.com/support
░░
░░ The process /srv/yt/yt-v2.sh could not be executed and failed.
░░
░░ The error number returned by this process is ERRNO.
Jan 16 16:12:38 localhost.localdomain systemd[1]: yt.service: Main process exited, code=exited, status=203/EXEC
░░ Subject: Unit process exited
░░ Defined-By: systemd
░░ Support: https://access.redhat.com/support
░░
░░ An ExecStart= process belonging to unit yt.service has exited.
░░
░░ The process' exit code is 'exited' and its exit status is 203.
Jan 16 16:12:38 localhost.localdomain systemd[1]: yt.service: Failed with result 'exit-code'.
░░ Subject: Unit failed
░░ Defined-By: systemd
░░ Support: https://access.redhat.com/support
░░
░░ The unit yt.service has entered the 'failed' state with result 'exit-code'.
Jan 16 16:23:15 localhost.localdomain systemd[1]: Started Automatique youtube downloader.
░░ Subject: A start job for unit yt.service has finished successfully
░░ Defined-By: systemd
░░ Support: https://access.redhat.com/support
░░
░░ A start job for unit yt.service has finished successfully.
░░
░░ The job identifier is 1304.
Jan 16 16:23:15 localhost.localdomain yt-v2.sh[1965]: mkdir: cannot create directory ‘/srv/yt/downloads’: File exists
```