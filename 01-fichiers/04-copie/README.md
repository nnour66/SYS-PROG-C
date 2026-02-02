# Programmation système - Copier un fichier

Complétez le programme `copie.c` qui réalise une copie de fichier.
Il s'agit d'une version simplifée de la commande `cp`.

Le programme admet en argument le nom du fichier source à copier et le nom du fichier destination :

```sh
./copie source destination
```

**Objectifs :** savoir ouvrir, lire et écrire dans un fichier avec les primitives système.

## Marche à suivre

Vous devez ouvrir les fichiers source et destination passés en argument du programme respectivement en lecture seule et écriture seule à l'aide de la primitive :

```c
int open(const char *path, int oflag, ...)
```

Il faudra écraser le fichier destination si ce dernier existe déjà.

Puis, vous devez lire le contenu du fichier source par blocs et écrire par blocs les octets lus dans le fichier destination à l'aide des primitives :

```c
ssize_t read(int fildes, void *buf, size_t nbyte)
ssize_t write(int fildes, const void *buf, size_t nbyte)
```

Enfin, vous devez fermer les deux fichiers via la primitive :

```c
int close(int fildes)
```

## Test préliminaire

La commande suivante crée un fichier binaire `toto_b` et utilise votre programme pour le copier dans le fichier `toto_b.cpy` :

```sh
head -c 1024000 /dev/urandom > toto_b ; ./copie toto_b toto_b.cpy
```

La commande `cmp` compare le contenu des deux fichiers `toto_b` et `toto_b.cpy`.
Si elle ne produit rien en sortie, c'est que le contenu des deux fichiers est identique et que votre programme est, a priori, fonctionnel :

```sh
cmp toto_b toto_b.cpy
```

## Validation

Votre programme doit obligatoirement passer tous les tests sur gitlab (il suffit de `commit/push` le fichier source pour déclencher le pipeline de compilation et de tests) avant de passer à l'exercice suivant.
