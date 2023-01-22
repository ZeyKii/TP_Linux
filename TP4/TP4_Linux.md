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

**Dans cette partie, le but sera de monter un serveur de stockage.** Un serveur de stockage, ici, désigne simplement un serveur qui partagera un dossier ou plusieurs aux autres machines de son réseau.

Ce dossier sera hébergé sur la partition dédiée sur la machine **`storage.tp4.linux`**.

Afin de partager le dossier, **nous allons mettre en place un serveur NFS** (pour Network File System), qui est prévu à cet effet. Comme d'habitude : c'est un programme qui écoute sur un port, et les clients qui s'y connectent avec un programme client adapté peuvent accéder à un ou plusieurs dossiers partagés.

Le **serveur NFS** sera **`storage.tp4.linux`** et le **client NFS** sera **`web.tp4.linux`**.

L'objectif :

- avoir deux dossiers sur **`storage.tp4.linux`** partagés
  - `/storage/site_web_1/`
  - `/storage/site_web_2/`
- la machine **`web.tp4.linux`** monte ces deux dossiers à travers le réseau
  - le dossier `/storage/site_web_1/` est monté dans `/var/www/site_web_1/`
  - le dossier `/storage/site_web_2/` est monté dans `/var/www/site_web_2/`

🌞 **Donnez les commandes réalisées sur le serveur NFS `storage.tp4.linux`**

- contenu du fichier `/etc/exports` dans le compte-rendu notamment

🌞 **Donnez les commandes réalisées sur le client NFS `web.tp4.linux`**

- contenu du fichier `/etc/fstab` dans le compte-rendu notamment

> Je vous laisse vous inspirer de docs sur internet **[comme celle-ci](https://www.digitalocean.com/community/tutorials/how-to-set-up-an-nfs-mount-on-rocky-linux-9)** pour mettre en place un serveur NFS.

**Ok, on a fini avec la partie 2, let's head to [the part 3](./../part3/README.md).**