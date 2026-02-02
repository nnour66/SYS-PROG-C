# Programmation système - Créer d'un processus fils et afficher des identifiants de processus

Complétez le programme `creer-fils.c` qui crée un processus.
Le programme n'admet pas d'argument.

Le processus fils doit attendre 2 secondes (avec la fonction `sleep()`) puis se terminer avec un code de retour égal au dernier chiffre de son pid.
Le processus père devra attendre la terminaison du fils, puis afficher son PID, le PID du fils et le code de retour du fils.

**Objectifs :** savoir créer un processus et attendre sa terminaison.

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

La récupération des identifiants de processus se fait via les primitives :

```c
pid_t getpid ()   // identifiant du processus courant
```

On rappelle que pour afficher des types POSIX (e.g. `pid_t`) il faut les convertir en `ìntmax_t` (si signé) ou `uintmax_t` (si non signé) et utiliser respectivement `%jd` ou `%ju` pour le format avec la fonction `printf`.

Le fils doit attendre 2 secondes (via un appel à la fonction `sleep()`) avant de se terminer avec la fonction :

```c
void exit(int status)
```

Le processus père doit attendre la fin du processus fils via la primitive :

```c
int wait(int *status)
```

puis afficher l'identifiant de processus du fils et sa valeur de retour.
Ces informations sont récupérables via les macros suivantes à utiliser sur l'entier passé en argument à la primitive `wait()` :

```c
WIFEXITED ()
WEXITSTATUS ()
```

## Test préliminaire

Exécutez votre programme et vérifiez les informations affichées.
Par exemple :

```sh
./creer-fils
4713 4714 4
```

indique que le PID du père est `4713` et que celui du fils est `4714`, et que la valeur de retour du fils est `4`, ce qui correspond bien au chiffre des unités de l'identifiant du processus fils.

## Validation

Votre programme doit obligatoirement passer tous les tests sur gitlab (il suffit de `commit/push` le fichier source pour déclencher le pipeline de compilation et de tests) avant de passer à l'exercice suivant.
