# Programmation système - Masquer des signaux

Complétez le programme `masquer.c` qui masque tous les signaux puis indique quels signaux sont en attente de traitement (car reçus alors qu'ils sont masqués).
Le programme n'admet pas d'argument.

**Objectifs :** savoir masquer des signaux.

## Marche à suivre

Masquez tous les signaux (excepté les signaux `SIGKILL` et `SIGSTOP`) via la primitive :

```c
    int sigprocmask(int how, const sigset_t *restrict set, sigset_t *restrict oldset)
```

Après 5 secondes, récupérez les signaux en attente de traitement, c'est-à-dire tous les signaux reçus alors qu'ils sont masqués, via la primitive :

```c
    int sigpending(sigset_t *set)
```

Vous pouvez utiliser la fonction `sleep()` pour la temporisation.

Vous pouvez tester la présence d'un signal dans un `sigset_t` via la fonction :

```c
    int sigismember(const sigset_t *set, int signum)
```

Enfin, affichez le nom des signaux (un nom par ligne) en attente de traitement.
La fonction suivante permet de traduire le numéro d'un signal en son nom :

```c
    char *strsignal(int sig)
```

## Test préliminaire

Exécutez votre programme puis appuyez sur ctrl+c puis ctrl+z pour lui envoyer les signaux `SIGINT` et `SIGTSTP`.

Après le délai de 5 sec., votre programme doit afficher (suivant votre locale) :

```
    Interrupt
    Stopped
```

## Validation

Votre programme doit obligatoirement passer tous les tests sur gitlab (il suffit de `commit/push` le fichier source pour déclencher le pipeline de compilation et de tests) avant de passer à l'exercice suivant.
