# Programmation système - Création de multiples processus fils

Complétez le programme `nfils.c` qui crée `n` processus fils.
Le programme admet en argument le nombre de processus fils à créer `n` compris dans [1;9] :

```sh
./nfils n
```

Ce programme doit créer les `n` processus fils dans une première étape puis, dans une deuxième étape, attendre leur terminaison.
Lorsqu'un processus fils se termine, le père affiche son identifiant de processus (pid) et son code de retour.

**Objectifs :** savoir créer plusieurs processus et attendre leur terminaison.

## Marche à suivre

La création d'un processus fils à partir du processus courant se fait via la primitive :

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

Chaque processus fils doit attendre 2 secondes (via un appel à la fonction `sleep()`) avant de se terminer avec la fonction :

```c
void exit(int status)
```

Enfin, le processus père doit attendre la fin de tous ses processus fils via `n` appels à la primitive :

```c
int wait(int *status)
```

À chaque fois qu’un processus se termine, le père affiche son numéro (pid) et son code de retour sous la forme :

    pid_filsX code_retour_filsX
    pid_filsY code_retour_filsY

Il est inutile d'attendre la terminaison des processus fils dans le même ordre que leur création.

On rappelle que pour afficher des types POSIX (e.g. `pid_t`) il faut les convertir en `ìntmax_t` (si signé) ou `uintmax_t` (si non signé) et utiliser respectivement `%jd` ou `%ju` pour le format avec la fonction `printf`.

## Test préliminaire

Vous pouvez exécuter votre programme et vérifier les informations affichées. Par exemple :

```sh
./nfils 5
8411 0
8410 0
8409 0
8408 0
8407 0
```

indique que les identifiants de processus des fils sont respectivement `8407, 8408, 8409, 8410, 8411`.
Dans cet exemple, tous les fils ont terminé avec un code de retour nul.

## Validation

Votre programme doit obligatoirement passer tous les tests sur gitlab (il suffit de `commit/push` le fichier source pour déclencher le pipeline de compilation et de tests) avant de passer à l'exercice suivant.
