# Programmation système - Copier un fichier via un tube

Complétez le programme `tube.c` qui se compose de deux processus :
- le processus père lit des données sur l'entrée standard et les passe par un tube au processus fils puis attend la terminaison du processus fils ;
- le processus fils lit des données sur un tube et les affiche sur sa sortie standard.

Le programme n'admet pas d'argument.

**Objectifs :** savoir utiliser un tube entre deux processus.

## Marche à suivre

Il faut dans un premier temps créer le tube anonyme à l'aide de la primitive :

```c
    int pipe(int fildes[2])
```

Ensuite il faut créer le processus fils via la primitive :

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

Le processus fils doit attendre 3 secondes via la fonction `sleep()` puis lire sur le côté lecture du tube et écrire les données lues sur sa sortie standard.
Le processus père doit lire des données depuis son entrée standard et écrire les données lues sur le côté écriture du tube.

Vous réaliserez la copie entre deux descripteurs (l'entrée standard et le tube pour le processus père, le tube et la sortie standard pour le processus fils) à l'aide de la fonction `copier()` à compléter. 

Rappel : n'oubliez pas de fermer au plus tôt les descripteurs inutiles dès que possible.

## Test préliminaire

Vous pouvez tester votre programme via la commande suivante qui copie le contenu du fichier `/bin/ls` dans le fichier `toto` à l'aide de votre programme :

```sh
    ./tube < /bin/ls > toto
```

La commande `cmp` compare le contenu des deux fichiers `/bin/ls` et `toto`.
Si elle ne produit rien en sortie, c'est que le contenu des deux fichiers est identique et que votre programme est, a priori, fonctionnel :

```sh
    cmp /bin/ls toto
```

## Validation

Votre programme doit obligatoirement passer tous les tests sur gitlab (il suffit de `commit/push` le fichier source pour déclencher le pipeline de compilation et de tests) avant de passer à l'exercice suivant.
