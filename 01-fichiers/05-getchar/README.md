# Programmation système - Fonction getchar sans tampon

Complétez la fonction `mygetchar()` du fichier `getchar.c`.
Cette fonction doit reproduire le comportement de la fonction de bibliothèque `getchar()`.
Vous ne devez pas modifier la fonction `main()`.

**Objectifs :** comprendre le fonctionnement d'une fonction de bibliothèque sur les fichiers.

## Marche à suivre

La fonction `mygetchar()` doit lire un octet sur l'entrée standard (descripteur `STDIN_FILENO`) à l'aide de la primitive système :

```c
ssize_t read(intfildes, void *buf, size_t nbyte)
```

et retourner cet octet sous la forme d'un entier signé.

Lorsqu'il n'y a plus rien à lire ou en cas d'erreur, la fonction `mygetchar()` doit retourner la constante `MYEOF`.
Il vous appartient de définir sa valeur de telle sorte qu'il n'y ait pas de recouvrement avec tout octet pouvant être lu sur l'entrée standard.

## Test préliminaire

Les commandes suivantes créent un fichier binaire `toto_b` et le copie dans le fichier `toto_b.cpy` à l'aide de votre programme :

```sh
head -c 1024000 /dev/urandom > toto_b
./getchar < toto_b > toto_b.cpy
```

La commande `cmp` compare le contenu des deux fichiers `toto_b` et `toto_b.cpy`.
Si elle ne produit rien en sortie, c'est que le contenu des deux fichiers est identique et que votre fonction `mygetchar()` est, a priori, fonctionnelle :

```sh
cmp toto_b toto_b.cpy
```

## Validation

Votre programme doit obligatoirement passer tous les tests sur gitlab (il suffit de `commit/push` le fichier source pour déclencher le pipeline de compilation et de tests) avant de passer à l'exercice suivant.
