# Programmation système - Tester si un fichier est un répertoire

Complétez le programme `isdir.c` qui vérifie si le fichier passé en argument est un répertoire.
Le programme admet en argument le nom du fichier qui sera testé :

```sh
./isdir nom_fichier
```

Le programme retourne une valeur nulle si le fichier passé en argument est un répertoire, non nulle sinon.

**Objectifs :** savoir récupérer les attributs d'un fichier et les tester.

## Marche à suivre

Vous pouvez récupérer les attributs du fichier passé en argument via la primitive :

```c
int stat(const char *path, struct stat *stbuf)
```

Cette primitive place les attributs du fichier passé en argument dans une structure `struct stat` :

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

Le type du fichier se trouve dans le champ `st_mode` de la structure `struct stat` que vous pouvez directement tester avec la macro `S_ISDIR()`.

## Test préliminaire

Vous pouvez tester votre programme sur le répertoire courant (cette commande doit afficher `0`) :

```sh
./isdir . ; echo $?
```

ou sur un fichier régulier (cette commande doit afficher `1`) :

```sh
touch toto ; ./isdir toto ; echo $?
```

## Validation

Votre programme doit obligatoirement passer tous les tests sur gitlab (il suffit de `commit/push` le fichier source pour déclencher le pipeline de compilation et de tests) avant de passer à l'exercice suivant.
