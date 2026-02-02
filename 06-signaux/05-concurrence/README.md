# Programmation système - Concurrence

Complétez le programme `liste.c` qui ajoute des éléments dans une liste de façon synchrone et asynchrone (via la réception de signaux).
Le programme n'adment pas d'argument.

On cherche ici à mettre en évidence le problème de concurrence entre les parties synchrone et asynchrone d'un programme.
Pour cela, on construit une structure de liste et une fonction pour insérer un élément d'un type donné dans la liste.

```c
    struct elem {
        int type;
        long long int val;
        struct elem *suiv;
    } ;
    struct elem *tete = NULL;

    void
    inserer(int type, long long int val)
    {
        struct elem *e ;
        if ((e = malloc(sizeof *e)) == NULL)
            raler("malloc");
        e->suiv = tete;
        e->type = type;
        e->val  = val;
        tete    = e;
    }
```

**Objectifs :** Mise en évidence du problème de concurrence entre les parties synchrone et asynchrone d'un programme.

## Marche à suvire

Le programme qu'on vous demande de rédiger doit tout d'abord générer un processus fils par signal (entre *1* et *31*, bornes comprises, en excluant `SIGKILL` et `SIGSTOP` via la primitive :

```c
    int fork(void);
```

On rappelle que cette primitive doit obligatoirement s'utiliser dans une structure `switch ()` :

```c
    switch (fork()) {
    case -1: /* erreur */
    case  0: /* processus fils */
    default: /* processus père */
    }
```

Lorsque tous les fils sont générés, le père leur donne l'ordre de démarrer en envoyant à chacun d'eux `SIGUSR1` via la primitive :

```c
     int kill(pid_t pid, int sig);
```

Puis il incrémente un million de fois un compteur en insérant à chaque tour de boucle la valeur du compteur dans la liste avec le type 0.

De son côté, chaque fils *i*, dès le top départ donné par le père, affiche le message :

```sh
    child i: START
```

(où *i* est le numéro du fils) et envoie un million de fois le signal *i* au père, et affiche le message indiquant sa terminaison :

```sh
    child i: END
```

Lorsque le père reçoit un signal *i*, il ajoute (à l'intérieur de la fonction associée au signal) dans la liste la valeur courante du compteur avec le type *i*.

À la fin de l'exécution, le père attend la terminaison de tous les processus fils (on ne tiendra exceptionnellement pas compte de leur code de retour pour simplifier) via la primitive :

```c
    pid_t wait(int *wstatus);
```

Puis le père appelle la fonction `print_and_detect()` déjà presente dans le fichier source.
Cette fonction affiche, pour chaque type, le nombre d'éléments trouvés dans la liste.
Pour le type 0 en particulier, elle détecte les éléments incohérents, c'est-à-dire lorsque deux valeurs de type 0 consécutives (même si des valeurs d'autres types sont intercalées entre elles) ne sont pas séparées d'une unité.
Vous ne devriez pas avoir d'éléments incohérents.
On ne cherchera pas à avoir ce type de vérification pour les autres types.

Pour bien montrer que vous avez compris le masquage des signaux, vous chercherez à réduire ce masquage au minimum nécessaire pour éviter les problèmes.
Tout masquage superflu montrera que vous n'avez pas bien compris cette notion.
Le masquage et l'attente passive d'un signal s'effectuent respectivement via les primitives :

```c
     int sigprocmask(int how, const sigset_t *restrict set, sigset_t *restrict oldset);
     int sigsuspend(const sigset_t *mask);
```

Dans un commentaire en début de programme, expliquez chaque problème que vous avez rencontré (ou anticipé), sa raison ou son origine, ainsi que la manière dont vous l'avez résolu (ou pas).
Expliquez également pourquoi le nombre d'éléments des types autres que 0 n'est qu'exceptionnellement égal à un million.
Soignez vos explications.

## Test préliminaire

L'exécution de votre programme doit produire l'affichage suivant (attention l'ordre des fils est non déterministe) :

```sh
    ./liste 2> stderr
    child  3: START
    child 11: START
    child  7: START
    child  1: START
    child  2: START
    child  4: START
    child  5: START
    child  6: START
    child 16: START
    child 14: START
    child 13: START
    child 12: START
    child 10: START
    child  8: START
    child 17: START
    child 15: START
    child 18: START
    child 20: START
    child 26: START
    child 21: START
    child 22: START
    child 23: START
    child 24: START
    child 30: START
    child 27: START
    child 25: START
    child 28: START
    child 29: START
    child 31: START
    child  6: END
    child  2: END
    child  5: END
    child 11: END
    child  7: END
    child 29: END
    child 10: END
    child  8: END
    child 17: END
    child 12: END
    child 26: END
    child 27: END
    child  3: END
    child  4: END
    child 16: END
    child  1: END
    child 23: END
    child 31: END
    child 25: END
    child 15: END
    child 13: END
    child 24: END
    child 14: END
    child 30: END
    child 21: END
    child 28: END
    child 22: END
    child 20: END
    child 18: END
    type 0: 1000000
    type 1: 8093
    type 2: 2831
    type 3: 534
    type 4: 115745
    type 5: 49224
    type 6: 2
    type 7: 46467
    type 8: 29140
    type 9: 0
    type 10: 219
    type 11: 20254
    type 12: 1
    type 13: 3979
    type 14: 2144
    type 15: 1
    type 16: 1
    type 17: 8
    type 18: 20340
    type 19: 0
    type 20: 13076
    type 21: 128
    type 22: 77
    type 23: 1
    type 24: 1
    type 25: 1
    type 26: 1
    type 27: 1
    type 28: 1
    type 29: 1
    type 30: 1
    type 31: 13578
```

Le fichier `stderr` doit être vide.

## Validation

Votre programme doit obligatoirement passer tous les tests sur gitlab (il suffit de `commit/push` le fichier source pour déclencher le pipeline de compilation et de tests) avant de passer à l'exercice suivant.
