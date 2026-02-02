# Programmation système - Afficher les répertoires d'une arborescence

Complétez le programme `liste-rep.c` qui affiche les répertoires contenus dans une arborescence.
Le programme admet en argument le nom du répertoire à parcourir ainsi que la profondeur maximale à laquelle descendre dans le répertoire :

```sh
./liste-rep repertoire profondeur
```

Votre programme doit exactement reproduire la sortie de la commande :

```sh
find repertoire -d type -maxdepth profondeur
```

Dans l'exemple suivant, l'exécution du programme sur le répertoire `d` produit en sortie :

```sh
mkdir -p d/dd/ddd/dddd ; ./liste-rep d 3
d
d/dd
d/dd/ddd
d/dd/ddd/dddd
```

**Objectifs :** savoir parcourir récursivement une arborescence.

## Marche à suivre

Vous devez dans un premier temps ouvrir le répertoire source passé en argument via la fonction de bibliothèque :

```c
DIR * opendir(const char *filename)
```

Il faut maintenant parcourir le répertoire à l'aide de la fonction de bibliothèque :

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

Vous pouvez récupérer les attributs d'un fichier (même pour un lien symbolique) avec la primitive :

```c
int lstat (const char *path, struct stat *stbuf)
```

Les attributs sont placés dans une structure `struct stat` passée en argument :

```c
struct stat {
    dev_t     st_dev;         /* Périphérique                     */
    ino_t     st_ino;         /* Numéro d’inœud                   */
    mode_t    st_mode;        /* Protection                       */
    nlink_t   st_nlink;       /* Nombre de liens physiques        */
    uid_t     st_uid;         /* UID du propriétaire              */
    gid_t     st_gid;         /* GID du propriétaire              */
    dev_t     st_rdev;        /* Type de périphérique             */
    off_t     st_size;        /* Taille totale en octets          */
    blksize_t st_blksize;     /* Taille de bloc pour E/S          */
    blkcnt_t  st_blocks;      /* Nombre de blocs de 512 o alloués */

    /* Depuis Linux 2.6, le noyau permet une précision à la
       nanoseconde pour les champs temporels suivants. Pour
       plus de précisions avant Linux 2.6, consultez les NOTES. */

    struct timespec st_atim;  /* Heure dernier accès              */
    struct timespec st_mtim;  /* Heure dernière modification      */
    struct timespec st_ctim;  /* Heure dernier changement état    */

    #define st_atime st_atim.tv_sec      /* Rétrocompatibilité    */
    #define st_mtime st_mtim.tv_sec
    #define st_ctime st_ctim.tv_sec
};
```

Vous pouvez tester si un fichier est un répertoire à l'aide de la macro `S_ISDIR()` sur le champ `st_mode` d'une structure `struct stat`.
Dans ce cas, il faut également parcourir ce répertoire.

Attention, le champ `d_name` de la structure `struct dirent` contient uniquement le nom du fichier, et non celui de ses potentiels répertoires parents.
Par conséquent, il faut concaténer le nom du répertoire parent avec le nom du fichier pour pouvoir travailler sur ce dernier.
Pour ce faire vous pouvez utiliser la `concatener()` qui est fournie dans le fichier `liste-rep.c`.
Pour rappel, la taille du chemin complet d'un fichier ne peut pas dépasser `PATH_MAX` caractères.

Pour chaque répertoire ouvert il faudra appeler la fonction suivante afin de libérer la mémoire allouée par la fonction `opendir()` :

```c
int closedir(DIR *dirp)
```

## Test préliminaire

Vous pouvez tester votre programme à l'aide des commandes suivantes :

```sh
mkdir -p toto/1/2 ; echo "123" > toto/titi ; echo "456" > toto/1/tata ; echo "789" > toto/1/2/tutu
./liste-rep toto 2 > output1
find toto -type d -maxdepth 2 > output2
```

La commande `cmp` compare le contenu des deux fichiers `output1` (produit par votre programme) et `output2` (produit par la commande `find`).
Si elle ne produit rien en sortie, c'est que le contenu des deux fichiers est identique et que votre programme est, a priori, fonctionnel :

```sh
cmp output1 output2
```

## Validation

Votre programme doit obligatoirement passer tous les tests sur gitlab (il suffit de `commit/push` le fichier source pour déclencher le pipeline de compilation et de tests) avant de passer à l'exercice suivant.
