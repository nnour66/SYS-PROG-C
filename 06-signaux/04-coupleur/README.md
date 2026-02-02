# Programmation système - Coupleur

Complétez le programme `coupleur.c` qui permet de transmettre un octet entre deux processus.
Le programme admet en argument l'octet à transmettre compris dans [0, 255]:

```sh
    ./coupleur 243
```

Le programme simule un mécanisme matériel comparable à un coupleur série.
Un 0 (zéro) est représenté par le signal `SIGUSR1` et un 1 (un) est représenté par le signal `SIGUSR2`.
Un octet est transmis par une succession de 8 bits (0 ou 1).

**Objectifs :** savoir masquer, envoyer et attendre des signaux entre processus.

## Marche à suivre

Dans un premier temps il faut masquer les signaux `SIGUSR1` et `SIGUSR2` pour éviter les problèmes liés au non-déterminisme de `fork()`.
En effet, le processus père pourrait être remis sur le processeur avant le processus fils et envoyer un signal au processus fils alors que ce dernier n'a pas encore modifié l'action par défaut associée à la réception de ce signal.
Le masquage de signal est réalisé avec la primitive :

```c
    int sigprocmask(int how, const sigset_t *restrict set, sigset_t *restrict oldset)
```

La manipulation d'un `sigset_t` se fait via les fonctions :

```c
    int sigemptyset(sigset_t *set)
    int sigfillset(sigset_t *set)
    int sigaddset(sigset_t *set, int signum)
    int sigdelset(sigset_t *set, int signum)
    int sigismember(const sigset_t *set, int signum)
```

Vous pouvez ensuite créer un processus fils via la primitive :

```c
    int fork(void)
```

On rappelle que cette primitive doit obligatoirement s'utiliser dans une structure `switch ()` :

```c
    switch (fork()) {
    case -1: /* erreur */
    case  0: /* processus fils */
    default: /* processus père */
    }
```

Le processus père doit ensuite décomposer la valeur passée en argument du programme : pour chaque bit qui compose cet octet, il doit envoyer le signal correspondant (`SIGUSR1` ou `SIGUSR2`) au processus fils via la primitive :

```c
    int kill(pid_t pid, int sig)
```

Le processus fils doit attendre la réception d'un signal à l'aide de la primitive :

```c
    int sigsuspend (const sigset_t *mask)
```

Chaque bit reçu (via la réception d'un signal) doit être acquitté auprès du processus père via l'émission du signal `SIGUSR1`.
Le processus père peut envoyer le prochain bit uniquement après réception de l'acquittement pour le bit courant.

Lorsque le processus fils a reçu un octet complet, il l'affiche sur la sortie standard puis attend deux secondes (via la fonction `sleep()`) puis se termine avec un code de retour nul.
Vous pouvez utiliser une fonction de bibliothèque pour cet affichage.

Enfin le processus père doit attendre la terminaison du processus fils et vérifier la raison de sa terminaison via la primitive et les macros :

```c
    pid_t wait(int *wstatus)
    WIFEXITED()
    WEXITSTATUS()
```

## Test préliminaire

Exécutez votre programme et vérifiez que la valeur affichée par le processus fils correspond bien à celle passée en argument du programme.
Par exemple :

```sh
    ./coupleur 214
    214
```

## Validation

Votre programme doit obligatoirement passer tous les tests sur gitlab (il suffit de `commit/push` le fichier source pour déclencher le pipeline de compilation et de tests) avant de passer à l'exercice suivant.
