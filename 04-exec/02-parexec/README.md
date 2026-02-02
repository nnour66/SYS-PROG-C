# Programmation système - Exécution d'une commande

Complétez le programme `parexec.c` qui exécute `n` fois une commande.
Le programme admet en argument le nombre d'exécution `n`, la commande à exécuter `cmd`, et les éventuels arguments de la commande (en nombre non connu) :

```sh
./parexec n cmd arg ...
```

Les `n` commandes doivent être lancées en parallèle, et le code de retour de `parexec` doit être égal à 0 si toutes les commandes réussissent (i.e. renvoient un code de retour nul), ou 1 si au moins l'une des commands échoue (i.e. renvoie un code de retour non nul).

**Objectifs :** savoir créer des processus fils et exécuter des fichiers exécutables.

## Marche à suivre

Le processus principal doit créer `n` processus fils via la primitive :

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

Chaque processus fils doit exécuter la commande `cmd` avec ses éventuels arguments via la primitive :

```c
int execvp(const char *file, char *const argv[])
```

Néanmoins, il faut ajouter le rang d'appel `i` $(i \in [0;n[)$ comme argument supplémentaire à la fin des autres arguments.
Par exemple :

```sh
./parexec 2 echo bonjour
```

doit créer deux processus fils, chacun exécutant la commande :

```sh
echo bonjour 0 // pour le premier fils
echo bonjour 1 // pour le deuxième fils
```

## Test préliminaire

L'exécution de la commande suivante :

```sh
./parexec 3 echo bonjour | sort -d
```

doit produire le résultat suivant auquel cas votre programme est, a priori, fonctionnel :

```sh
bonjour 0
bonjour 1
bonjour 2
```

## Validation

Votre programme doit obligatoirement passer tous les tests sur gitlab (il suffit de `commit/push` le fichier source pour déclencher le pipeline de compilation et de tests) avant de passer à l'exercice suivant.
