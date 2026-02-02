# Programmation système - Ouvrir un fichier et afficher ses droits (lecture / écriture)

Complétez le programme `testr.c` qui affiche les droits d'accès d'un fichier passé en paramètre.

Le programme admet en argument le nom du fichier dont les droits doivent être vérifés :

```sh
./testr nom_fichier
```

Le programme doit afficher les droits d'accès du fichier suivant le format :

```sh
nom_fichier: RW
```

où :
- `R` signifie que le droit de lecture est présent
- `W` signifie que le droit d'écriture est présent

Le droit d'exécution ne sera pas traité.

Si un droit est absent, la lettre correspondante à ce droit doit être remplacée par le caractère `-`.
Par exemple, si le fichier `noaccess` ne dispose d'aucun droit, le programme doit produire en sortie :

```sh
./testr noaccess
noaccess: --
```

Votre programme ne devra tester que les droits de l'utilisateur courant.

**Objectifs :** savoir ouvrir un fichier avec les primitives système.

## Marche à suivre

Vous devez tenter d'ouvrir le fichier passé en argument dans les modes lecture seule (`O_RDONLY`) puis écriture seule (`O_WRONLY`) à l'aide de la primitive :

```c
int open(const char *path, int oflag, ...)
```

Lorsque cette primitive échoue et que la valeur de `errno` est égale à `EACCES`, cela signifie que le droit correspondant au mode d'ouverture utilisé n'est pas présent pour l'utilisateur courant.
En cas de succès le droit correspondant au mode d'ouverture est présent pour l'utilisateur courant.

Tous les descripteurs créés par la primitive `open()` devront être fermés via la primitive :

```c
int close (int fildes)
```

Après avoir testé les deux modes d'ouverture, vous devez afficher les droits présents sur le fichier.
Cet affichage pourra utiliser une fonction de bibliothèque (e.g. `printf`).

## Test préliminaire

Les commandes suivantes créent le fichier `toto` et positionnent uniquement le droit de lecture pour l'utilisateur courant :

```sh
touch toto ; chmod a=r toto
```

Sur le fichier `toto` ainsi créé, votre programme devra produire le résultat suivant :

```sh
./testr toto
toto: R-
```

## Validation

Votre programme doit obligatoirement passer tous les tests sur gitlab (il suffit de `commit/push` le fichier source pour déclencher le pipeline de compilation et de tests) avant de passer à l'exercice suivant.
