# Programmation système - Copier une arborescence de fichiers

Complétez le programme `copie-arbo.c` qui copie une arborescence de fichiers.
Le programme admet en argument le nom du répertoire à copier et le nom du répertoire destination :

```sh
./copie-arbo repertoire_source repertoire_destination
```

**Objectifs :** savoir parcourir récursivement une arborescence et copier des fichiers/répertoires.

## Marche à suivre

Vous devez ouvrir le répertoire source passé en argument via la fonction de bibliothèque :

```c
DIR * opendir(const char *filename)
```

et créer le répertoire destination via la primitive :

```c
int mkdir(const char *path, mode_t mode)
```

Il faut maintenant parcourir le répertoire source à l'aide de la fonction de bibliothèque :

```
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
- soit tous les fichiers présents dans le répertoire ont été traités ;
- soit une erreur a été rencontrée, auquel cas `errno` a été positionné en conséquence.

Pour chaque fichier présent dans le répertoire, il faut déterminer son type via la primitive :

```c
int lstat(const char *path, struct stat *stbuf)
```

- les fichiers réguliers seront copiés dans le répertoire destination ;
- les répertoires déclencheront un nouvel appel à la fonction `copie-arbo` (fonction récursive) avec les bons paramètres ;
- tout autre type de fichier rencontré devra provoquer une erreur.

Attention, le champ `d_name` de la structure `struct dirent` contient uniquement le nom du fichier, et non celui de ses potentiels répertoires parents.
Par conséquent, il faut concaténer le nom du répertoire parent avec le nom du fichier pour pouvoir travailler sur ce dernier.
Pour ce faire vous pouvez utiliser la fonction `concatener()` fournie dans le fichier `copie-arbo.c`.
Pour rappel, la taille du chemin complet d'un fichier ne peut pas dépasser `PATH_MAX` caractères.

Pour chaque répertoire ouvert il faudra appeler la fonction suivante afin de libérer la mémoire allouée par la fonction `opendir()` :

```c
int closedir(DIR *dirp)
```

## Test préliminaire

Les commandes suivantes créent une arborescence de fichiers nommée `toto` et la copie dans le répertoire `toto.cpy` à l'aide de votre programme :

```sh
mkdir -p toto/1/2 ; echo "123" > toto/titi ; echo "456" > toto/1/tata ; echo "789" > toto/1/2/tutu
./copie-arbo toto toto.cpy
```

La commande `diff` compare les deux arborescences et échoue si des différences sont détéctées.
Si elle ne produit rien en sortie, c'est que le contenu des deux arborescences est identique et que votre programme est, a priori, fonctionnel :

```c
diff -qr toto toto.cpy
```

## Validation
 
Votre programme doit obligatoirement passer tous les tests sur gitlab (il suffit de `commit/push` le fichier source pour déclencher le pipeline de compilation et de tests) avant de passer à l'exercice suivant.
