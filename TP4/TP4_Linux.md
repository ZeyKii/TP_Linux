# TP4 : Real services

Dans ce TP4, on va s'approcher de plus en plus vers de la gestion de serveur, commen on le fait dans le monde réel.

Le but de ce TP :

➜ **monter un serveur de stockage** VM `storage.tp4.linux`

- le serveur de stockage possède une partition dédiée
- sur cette partition, plusieurs dossiers sont créés
- chaque dossier contient un site web
- ces dossiers sont partagés à travers le réseau pour rendre leur contenu disponible à notre serveur web

➜ **monter un serveur web** VM `web.tp4.linux`

- il accueillera deux sites web
- il ne sera (malheureusement) pas publié sur internet : c'est juste une VM
- les sites web sont stockés sur le serveur de stockage, le serveur web y accède à travers le réseau

---

➜ Plutôt que de monter des petits services de test, ou analyser les services déjà existants sur la machine, on va donc passer à l'étape supérieure et **monter des trucs vraiment utilisés dans le monde réel** :)

Rien de sorcier cela dit, et **à la fin vous aurez appris à monter un petit serveur Web.** Ce serait exactement la même chose si vous voulez publier un site web, et que vous voulez gérer vous-mêmes le serveur Web.

**Le serveur de stockage** c'est pour rendre le truc un peu plus fun (oui j'ai osé dire *fun*), et voir un service de plus, qui est utilisé dans le monde réel. En plus, il est parfaitement adapté pour pratiquer et s'exercer sur le partitionnement de façon pertinente.

➜ On aura besoin de deux VMs dans ce TP : 🖥️ **VM `web.tp4.linux`** et 🖥️ **VM `storage.tp4.linux`**.

> Pour une meilleure lisibilité, j'ai éclaté le TP en 3 parties.

## Checklist

![Checklist](./pics/checklist_is_here.jpg)

- [x] IP locale, statique ou dynamique
- [x] hostname défini
- [x] firewall actif, qui ne laisse passer que le strict nécessaire
- [x] SSH fonctionnel
- [x] accès Internet (une route par défaut, une carte NAT c'est très bien)
- [x] résolution de nom
- [x] SELinux activé en mode *"permissive"* (vérifiez avec `sestatus`, voir [mémo install VM tout en bas](https://gitlab.com/it4lik/b1-reseau-2022/-/blob/main/cours/memo/install_vm.md#4-pr%C3%A9parer-la-vm-au-clonage))

**Les éléments de la 📝checklist📝 sont STRICTEMENT OBLIGATOIRES à réaliser mais ne doivent PAS figurer dans le rendu.**

## Sommaire

- [Partie 1 : Partitionnement du serveur de stockage](./part1/README.md)
- [Partie 2 : Serveur de partage de fichiers](./part2/README.md)
- [Partie 3 : Serveur web](./part3/README.md)

![glhf](./pics/glhf.png)