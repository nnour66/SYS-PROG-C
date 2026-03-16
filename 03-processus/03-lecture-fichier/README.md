# Programmation système - Lecture concurrente dans un fichier

Complétez le programme `lecture.c` qui réalise une lecture concurrente par deux processus d'un même fichier.
Le programme admet en argument le nom du fichier à lire :

```sh
./lecture nom_fichier
```

Il ouvre en lecture le fichier passé en argument puis crée 1 processus fils.
Les deux processus (père et fils) lisent dans le fichier et affichent les caractères lus sur la sortie standard.

**Objectifs :** comprendre l'incidence de la création d'un processus sur la table des fichiers ouverts.

## Marche à suivre

Le processus père doit ouvrir en lecture le fichier passé en argument à l'aide de la primitive :

```c
int open(const char *path, int oflag, ...)
```

Le processus père doit maintenant créer un processus fils à l'aide de la primitive :

```c
int fork()
```

On rappelle que cette primitive doit obligatoirement s'utiliser dans une structure `switch ()` :

```c
switch (fork()) {
case -1: /* erreur */
case  0: /* processus fils */
default: /* processus père */
}
```

Les deux processus (père et fils) doivent désormais lire dans le fichier caractère par caractère à l'aide de la primitive :

```c
ssize_t read(int fildes, void *buf, size_t nbyte)
```c

Chaque processus affiche les caractères lus sur la sortie standard à l'aide du code suivant :

```c
printf(BLEU "%c", c) // pour le processus fils
printf(JAUN "%c", c) // pour le processus père
```

Lorsqu'un processus a terminé la lecture du fichier, il doit fermer le descripteur correspondant via la primitive :

```c
int close(int fildes)
```

Le fils doit attendre 2 secondes (via un appel à la fonction `sleep()`) avant de se terminer.

Enfin, le processus père doit attendre la fin du processus fils via la primitive :

```c
int wait(int *status)
```

Il faut s'assurer que le fils a bien terminé par un appel à la fonction `exit` avec un code de retour nul via les macros :

```c
WIFEXITED()
WEXITSTATUS()
```

## Tests préliminaires

La commande suivante crée un fichier ASCII `toto` de 1024 octets :

```sh
LC_ALL=C tr -dc "A-Za-z0-9\n" < /dev/urandom | head -c 1024 > toto
```

Passez ensuite ce fichier en argument de votre programme et comptez le nombre d'octets produit en sortie : 

```sh
./lecture toto | wc -c
```

L'exécution de ces commandes doit produire en sortie `1024`, auquel cas le fichier `toto` (qui contient 1024 caractères) est bien lu intégralement par votre programme.

Compilez maintenant votre programme avec la syntaxe suivante afin d'afficher en couleur (jaune pour le processus père, bleu pour le processus fils) les caractères lus et affichés par chaque processus :

```sh
scons -Q color=1
```

Exécutez votre programme sur un fichier texte.
Que constatez-vous ?
Pourquoi ?
Relancez votre programme à plusieurs reprises sur le même fichier texte.
Que constatez-vous ?
Pourquoi ?

## Validation

Votre programme doit obligatoirement passer tous les tests sur gitlab (il suffit de `commit/push` le fichier source pour déclencher le pipeline de compilation et de tests) avant de passer à l'exercice suivant.
