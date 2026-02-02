# Programmation système - Fonction execlp

Complétez la fonction `myexeclp` dans le fichier `myexeclp.c` qui doit reproduire le comportement de la fonction de bibliothèque `execlp()` :

```c
int myexeclp(const char *file, const char *arg0, ...)
```

Cette fonction cherche le fichier `file` dans les répertoires inclus dans la variable d'environnement `PATH` et exécute ce fichier via la primitive système `execve()`.

En cas d'erreur, la fonction `myexeclp()` doit reproduire le comportement de la fonction `execlp()` à savoir positionner `errno` et retourner `-1`.
**Elle ne doit donc pas appeler la fonction `raler()`.**

**Objectifs :** savoir chercher un fichier dans les répertoires pointés par une variable d'environnement, écrire une fonction au nombre d'arguments variable, recouvrir un processus.

## Marche à suivre

Il faut dans un premier temps récupérer le contenu de la variable d'environnement `PATH` via la fonction :

```c
char * getenv(const char *name)
```

Comme la chaîne de caractères retournée par `getenv()` n'est pas modifiable, il faut copier son contenu dans une autre chaîne avant de pouvoir travailler dessus.

Chaque nom de répertoire présent dans la variable `PATH` est séparé des autres par le caractère `:`.
La fonction `separe()` (fournie dans le fichier `myexeclp.c`) décompose une chaîne de caractères en mots en coupant la chaîne à chaque fois qu'un séparateur est trouvé :

```c
char **separe(char *chaine, const char *separateurs)
```

Les mots sont placés dans un tableau terminé par NULL.
Attention, la chaîne `chaine` est modifiée par la fonction.
Par exemple :

```c
char chaine [] = "abcd,efgh:ijklmnop";
char ** tab = separe(chaine, ",:"); // les séparateurs sont ':' et ','

// tab est maintenant composé de 4 cases :
// tab [0] == "abcd"
// tab [1] == "efgh"
// tab [2] == "ijklmnop"
// tab [3] == NULL
```

Il faut ensuite parcourir chaque répertoire présent dans la variable `PATH` afin de trouver dans quel répertoire se trouve le fichier à exécuter.
Pour ce faire, il faut utiliser les fonctions de bibliothèque :

```c
DIR *opendir(const char filename)
struct dirent *readdir(DIR *dirp)
```

Si le fichier n'est pas trouvé, la fonction `myexeclp()` doit positionner `errno` à `ENOENT` et retourner -1. 

Lorsque le fichier est trouvé, il faut l'exécuter via la primitive :

```c
int execve(const char *path, char *const argv[], char *const envp[])
```

Par conséquent, il faut transformer la liste variable d'arguments de `myexeclp()` en un tableau de chaînes de caractères terminé par NULL.
Pour simplifier l'exercice, la fonction `myexeclp()` acceptera *N* arguments, avec *N* dans *[3, MAX_ARG + 3]*.
Si *N > MAX_ARG + 3* alors la fonction doit positionner `errno` à `E2BIG` et retourner -1.

La gestion du nombre variable d'arguments de la fonction sera réalisée via la bibliothèque stdarg :

```c
#include <stdarg.h>
void va_start(va_list ap, parmN)
type va_arg(va_list ap, type)
void va_end(va list ap)
```

La macro `va_start()` initialise la variable `ap` qui est utilisée par les macros `va_arg()` et `va_end()`.
Le paramètre `paramN` correspond au paramètre de la fonction se trouvant juste avant les « ... ».

Après initialisation, les paramètres peuvent être récupérés séquentiellement via la macro `va_arg()` où `type` correspond au type de chaque paramètre.
Enfin, la macro `va_end()` doit être appelée pour chaque invocation de `va_start()`.
Attention, `va_arg()` ne permet de récupérer que les paramètres identifiés par « ... ».

Exemple d'utilisation :

```c
// retourne la somme des entiers passés en arguments 
int
sum(int num_args, ...)
{
    int val = 0;

    va_list ap;
    va_start(ap, num_args);
    for (int i = 0; i < num_args; i++)
        val += va_arg(ap, int);
    va_end(ap);

    return val;
}

int
main(void)
{
    printf ("somme  = %d\", sum (2, 1, 2));
    printf ("somme  = %d\", sum (3, 1, 2, 3, 4));
}
```

## Test préliminaire

Le programme `myexeclp` admet la syntaxe est la suivante :

```sh
./myexeclp fichier arg1 arg2 arg3 ...
```

où `fichier` correspond au nom de fichier à exécuter, `arg1` correspond au premier argument à utiliser lors de l'exécution de `fichier`, `arg2` au deuxième argument, etc.

Les commandes suivantes créent un répertoire `toto` composé des fichiers `tata` et `titi` puis liste le contenu du répertoire `toto` via la commande `ls -a` et via le programme `myexeclp` :

```sh
mkdir toto ; touch toto/tata ; touch toto/titi ; ls -a toto > output1
./myexeclp ls -a toto > output2
```

La commande `cmp` compare le contenu des deux fichiers `output1` (produit par la commande `ls`) et `output2` produit par le programme `myexeclp`.
Si elle ne produit rien en sortie, c'est que le contenu des deux fichiers est identique et que votre fonction `myexeclp()` est, a priori, fonctionnelle :

```sh
cmp output1 output2
```

## Validation

Votre programme doit obligatoirement passer tous les tests sur gitlab (il suffit de `commit/push` le fichier source pour déclencher le pipeline de compilation et de tests) avant de passer à l'exercice suivant.
