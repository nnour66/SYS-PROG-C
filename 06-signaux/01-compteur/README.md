# Programmation système - Gestion d'un signal 

Complétez le programme `compteur.c` qui incrémente et affiche un compteur à chaque fois qu'il reçoit le signal `SIGINT`.
Le programme n'admet pas d'argument.

Au bout de 5 réceptions, le programme doit s'arrêter.

**Objectifs :** savoir modifier l'action associée à la réception d'un signal.

## Marche à suivre

Il faut dans un premier temps modifier l'action associée à la réception du signal `SIGINT` via la primitive :

```c
    int sigaction(int signum, const struct sigaction *restrict act, struct sigaction *restrict oldact)
```

On rappelle que cette primitive prend en paramètre une structure `struct sigaction` qui correspond à la nouvelle action à associer au signal :

```c
    struct sigaction {
        void     (*sa_handler)(int);
        sigset_t sa_mask;
        int      sa_flags;
	    ...
    }
```

En dépit des règles de bon usage des signaux :
- la fonction handler associée au signal `SIGINT` doit incrémenter un compteur et afficher la valeur courante de ce dernier ;
- le programme devra réaliser une attente active sur la réception d'un signal.

Enfin, le programme doit se terminer lorsque la valeur du compteur est égale à 5 ou plus.

## Test préliminaire

Exécutez votre programme :

```sh
    ./compteur
```

à chaque fois que vous appuyez sur `ctrl+c`, votre programme doit afficher :

```
    compteur: x
```

où `x` est la valeur courante du compteur.
Lorsque la valeur courante du compteur est égale à 5, votre programme doit se terminer avec un code de retour nul.

## Validation

Votre programme doit obligatoirement passer tous les tests sur gitlab (il suffit de `commit/push` le fichier source pour déclencher le pipeline de compilation et de tests) avant de passer à l'exercice suivant.
