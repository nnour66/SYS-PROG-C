# Programmation système - Temporisation avec SIGALRM 

Complétez le programme `trier.c` qui trie, via un tri à bulles, un tableau aléatoire.
Le programme admet en argument la taille du tableau :

```sh
    ./trier 5
```

Le tableau sera initialisé par des valeurs aléatoires comprises entre 0 et 1000.
À chaque seconde le programme doit afficher le texte *working* via l'utilisation du signal `SIGALRM` et de la primitive `alarm()` pour indiquer à l'utilisateur que le programme n'est pas bloqué.

**Objectifs :** gestion des signaux et utilisation de la primitive `alarm ()`.

## Marche à suivre

Compléter la fonction `trier()` déjà présente dans le fichier source qui implémentera la pseudo-code suivant :

    tri_à_bulles (Tableau T)
        pour i allant de (taille de T) - 1 à 1
            pour j allant de 0 à i-1
                si T [j+1] < T [j]
                    (T [j+1], T [j]) ← (T [j], T [j+1])

Dans la fonction `main()`, créez le tableau dont la taille est passé en paramètre et initialisez son contenu via les fonctions de bibliothèque :

```c
    void srand(unsigned int seed)
    int rand(void)
```

Modifiez l'action associée à la réception du signal `SIGALRM` via la primitive :

```c
    int sigaction(int signum, const struct sigaction *restrict act, struct sigaction *restrict oldact)
```

On rappelle que cette primitive prend en paramètre une structure `struct sigaction` qui correspond à la nouvelle action à associer au signal :

```c
    struct sigaction {
        void       (*sa_handler)(int);
        sigset_t   sa_mask;
        int        sa_flags;
	    ...
    }
```

POSIX permet l'utilisation de certaines fonctions ou primitives système dans la fonction handler d'un signal, notamment :

```c
    unsigned int alarm(unsigned int seconds)
    ssize_t write(int fd, const void *buf, size_t count)
```

Dans la fonction `main()` appelez la primitive `alarm()` puis la fonction `trier()`.
Au retour de cette dernière, annulez la prochaine émission de `SIGALRM`.

Enfin, affichez le contenu du tableau trié sur la sortie standard (une valeur par ligne).
Vous pouvez utiliser une fonction de bibliothèque pour cet affichage.

## Test préliminaire

Sur de petites tailles de tableau, le programme ne doit pas avoir le temps d'afficher la chaîne `working`.
Par exemple :

```sh
    ./trier 5
    103 430 486 755 973
```

Par contre, sur de très grands tableaux, le programme peut mettre plusieurs secondes à effectuer le tri :

```sh
    ./trier 40960
    working
    working
    working
    working
    0
    0
    1
    ...
    999
```

## Validation

Votre programme doit obligatoirement passer tous les tests sur gitlab (il suffit de `commit/push` le fichier source pour déclencher le pipeline de compilation et de tests) avant de passer à l'exercice suivant.
