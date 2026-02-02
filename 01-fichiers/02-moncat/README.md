# Programmation système - Afficher le contenu d'un fichier

Complétez le programme `moncat.c` qui affiche le contenu d'un fichier sur la sortie standard.
Il s'agit d'une version simplifée de la commande `cat`.

Le programme admet en argument le nom du fichier dont le contenu doit être affiché :

```sh
./moncat nom_fichier
```

On fera l'hypothèse que seuls des fichiers texte sont passés en argument du programme.

**Objectifs :** savoir ouvrir et lire un fichier avec les primitives système.

## Marche à suivre

Vous devez ouvrir le fichier passé en argument et lire son contenu par blocs à l'aide des primitives :

```c
int open(const char *path, int oflag, ...)
ssize_t read(int fildes, void *buf, size_t nbyte)
```

Enfin, vous devez afficher le contenu lu sur la sortie standard.
Cet affichage pourra utiliser une fonction de bibliothèque (e.g. `printf` ou `putchar`).

## Test préliminaire

Vous pouvez tester votre programme sur des fichiers texte.
Par exemple, la commande suivante crée le fichier `toto` dont le contenu doit être le même que celui du fichier `montcat.c` :

```sh
./moncat moncat.c > toto
```

La commande `cmp` compare le contenu des deux fichiers `moncat.c` et `toto`.
Si elle ne produit rien en sortie, c'est que le contenu des deux fichiers est identique et que votre programme est, a priori, fonctionnel :

```sh
cmp moncat.c toto
```

## Validation

Votre programme doit obligatoirement passer tous les tests sur gitlab (il suffit de `commit/push` le fichier source pour déclencher le pipeline de compilation et de tests) avant de passer à l'exercice suivant.
