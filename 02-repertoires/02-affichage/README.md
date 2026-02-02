# Programmation système - Afficher les fichiers contenus dans un répertoire

Complétez le programme `monls.c` qui affiche le nom de tous les fichiers contenus dans un répertoire.
Le programme admet en argument le nom du répertoire à parcourir :

```sh
./monls nom_repertoire
```

Le programme devra afficher un nom de fichier par ligne.
On fera l'hypothèse que le répertoire passé en argument ne contient pas de sous-répertoire.
Les fichiers cachés (fichiers dont le nom commence par « . ») ne seront pas affichés.

**Objectifs :** savoir ouvrir et lire le contenu d'un répertoire.

## Marche à suivre

Vous devez ouvrir le fichier passé en argument via la fonction de bibliothèque :

```c
DIR * opendir(const char *filename)
```

et parcourir le répertoire à l'aide de la fonction de bibliothèque :

```c
struct dirent * readdir(DIR *dirp)
```

Cette fonction retourne un pointeur sur une structure `struct dirent` pour un fichier contenu dans le répertoire `dirp` :

```c
struct dirent {
    ino_t d_ino;       /* numéro d'inœud */
    char  d_name[256]; /* nom du fichier */
    ...
};
```

Attention, seuls `d_ino` et `d_name` sont POSIX.
En conséquence, vous n'avez pas le droit d'utiliser les autres champs sinon votre programme ne sera plus portable.

Un nouvel appel à la fonction `readdir()` retourne une structure `struct dirent` sur le second fichier contenu dans le répertoire `dirp` et ainsi de suite.
Lorsque la fonction `readdir()` retourne le pointeur `NULL` :
- soit tous les fichiers présents dans le répertoire on été traités ;
- soit une erreur a été rencontrée, auquel cas `errno`a été positionné en conséquence.

Chaque nom de fichier pourra être affiché sur la sortie standard en utilisant une fonction de bibliothèque (e.g. `printf`).
Enfin, il faut fermer le répertoire afin de libérer la mémoire allouée par `opendir()` :

```c
int closedir (DIR *dirp)
```

## Test préliminaire

Vous pouvez tester votre programme à l'aide des commandes suivantes :

```sh
mkdir toto ; touch toto/titi ; touch toto/tata
./monls toto | sort -d > output1
ls toto | sort -d > output2
```

La commande `cmp` compare le contenu des deux fichiers `output1` (produit par votre programme) et `output2` (produit par la commande `ls`).
Si elle ne produit rien en sortie, c'est que le contenu des deux fichiers est identique et que votre programme est, a priori, fonctionnel :

```sh
cmp output1 output2
```

## Validation

Votre programme doit obligatoirement passer tous les tests sur gitlab (il suffit de `commit/push` le fichier source pour déclencher le pipeline de compilation et de tests) avant de passer à l'exercice suivant.
