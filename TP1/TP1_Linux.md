# TP1 : Are you dead yet ?

# 1ère façon

Idée : Changer les différentes permissions du répértoire racine " / ".

Comment qu'on fait :
1. On se rend dans la racine de notre machine : ``cd /``
2. On vérifie que des fichiers sont bien la : ``ls``
3. On utilise la commande *chmod* pour modifier les permissions : ``sudo chmod a-x /`` (ici on refuse l'autorisation d'exécution à tout le monde.)
4. On essaye d'éxécuter certaine commande : ``ls`` , ``sudo su`` , ...

Résultat :

![](/TP1/Images/%C3%A7a_marche_plus.png)

PS : Même si on se *logout* c'est cassé
![](/TP1/Images/%C3%A7a_marche_plus_1.png)

# 2ème façon

Idée : Supprimer le noyau.

Comment qu'on fait :
1. On se rend dans le dossier boot de notre machine : ``cd /boot/``
2. On supprime les fichiers à l'intérieur : ``sudo rm vmlinuz- ...`` (on supprime les 3)
3. On relance la machine : ``sudo reboot``

Résultat : 

![](/TP1/Images/%C3%A7a_marche_plus_2.png)

![](/TP1/Images/%C3%A7a_marche_plus_3.png)

# 3ème façon

Idée : Mettre en place une ForkBomb

Comment qu'on fait :
1. On se rend dans le dossier *profile.d* : ``cd /etc/profile.d/``
2. On créé un fichier en mettant une suite de caractères précise : \
``sudo touch MoneyGenerator.sh`` \
``sudo nano MoneyGenerator.sh
    :(){:|:&};:``
3. On change les permissions en rendant le fichier exécutable : ``chmod +x MoneyGenerator.sh``

Résultat : 

![](/TP1/Images/%C3%A7a_marche_plus_4.png)

![](/TP1/Images/%C3%A7a_marche_plus_5.png)

![](/TP1/Images/%C3%A7a_marche_plus_6.png)

# 4ème façon

Idée : Remplir le disque dur de fichier aléatoire.

Comment qu'on fait : 
1. On exécute simplement une commande : ``dd if=/dev/random of=/dev/sda`` \
Elle va générer de nombreux fichiers aléatoirement sur le disque dur ce qui le saturera rapidement.

Résultat : 

![](/TP1/Images/%C3%A7a_marche_plus_7.png)