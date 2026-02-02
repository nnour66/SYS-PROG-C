# Programmation système - Tester la présence d'un utilisateur

Complétez le programme `presence.c` qui vérifie si un utilisateur est connecté.
Le programme admet en argument le nom d'un utilisateur :

```sh
    ./presence username
```

Le programme doit être équivalent au script shell où la variable `$1` contient le nom d'utilisateur :

```sh
    ps -eo user:100 > toto ; grep "$1" < toto > /dev/null && echo "$1 is connected"
```

En outre, le programme principal va :
- créer un processus fils qui exécute la commande `ps` avec la fonction `execlp()`. La sortie standard de ce processus doit être redirigée dans le fichier `toto` (à créer) ;
- créer un processus fils qui exécute la commande `grep` avec la fonction `execlp()`. L'entrée et la sortie standard de ce processus doivent respectivement être redirigées vers les fichier `toto` et `/dev/null`. 
- afficher, en cas de succès du second processus fils, la chaîne : `username is connected`

**Objectifs :** savoir rediriger l'entrée et la sortie standard d'un processus

## Marche à suivre

Il faut dans un premier temps créer le premier processus fils via la primitive :

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

Le processus fils doit créer le fichier `toto` et l'ouvrir en écriture seule à l'aide de la primitive :

```c
    int open(const char *path, int oflag, ...)
```

Puis il doit rediriger sa sortie standard vers le fichier `toto` à l'aide de la primitive :

```c
    int dup2(int fildes, int fildes2)
```

Enfin, ce processus fils doit exécuter la commande `ps` avec les arguments `-eo` et `user:100` via la fonction :

```c
    int execlp(const char *file, const char *arg0, ...)
```

Le processus père doit vérifier la bonne exécution du processus fils via la primitive et les macros :

```c
    int wait(int *status)
    WIFEXITED()
    WEXITSTATUS()
```

Le processus père crée ensuite un second processus fils et attend sa terminaison.
Ce second processus fils doit exécuter la commande `grep`, avec pour argument le nom de l'utilisateur.
La recherche est effectuée dans le fichier `toto`, préalablement créé par le premier processus fils, ce fichier étant fourni comme entrée standard du second processus fils.
Si le processus fils termine avec un code nul, le motif a été trouvé et l'utilisateur est connecté auquel cas il faut afficher sur la sortie standard la chaîne :

```sh
    username is connected
```

où `username` est le nom d'utilisateur passé en argument du programme.
Vous pouvez utiliser une fonction de bibliothèque pour cet affichage (e.g. `printf`).
Sinon, le programme doit se terminer avec un code non nul.

Pour gérer les redirections dans le second processus fils (fichier `toto` en entrée standard, fichier `/dev/null` en sortie standard), il faut utiliser les primitives :

```c
    int open(const char *path, int oflag, ...)
    int dup2(int fildes, int fildes2)
```

Enfin, le second processus fils doit exécuter la commande `grep` avec le motif créé précédemment via la fonction :

```c
    int execlp (const char *file, const char *arg0, ...)
```

Rappel : n'oubliez pas de fermer au plus tôt les descripteurs devenus inutiles.

## Test préliminaire

La commande suivante devrait afficher `1` (l'utilisateur `unknown_user` n'a pas été trouvé) :

```sh
    ./presence unknown_user ; echo $?
```

alors que la commande suivante devrait afficher : `votre_login is connected`

```sh
    ./presence $(whoami)
```

## Validation

Votre programme doit obligatoirement passer tous les tests sur gitlab (il suffit de `commit/push` le fichier source pour déclencher le pipeline de compilation et de tests) avant de passer à l'exercice suivant.
