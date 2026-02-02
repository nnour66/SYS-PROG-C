# Programmation système - Fonction getchar avec tampon

Complétez la fonction `mygetchar()` du fichier `getchar.c`. Cette fonction doit reproduire le comportement de la fonction de bibliothèque `getchar()` en utilisant un tampon en lecture.
Vous ne devez pas modifier la fonction `main()`.

**Objectifs :** comprendre le fonctionnement d'une fonction de bibliothèque sur les fichiers.

## Marche à suivre

La fonction `mygetchar()` doit lire un bloc d'octets sur l'entrée standard (descripteur 0) à l'aide de la primitive système :

```c
ssize_t read(int fildes, void *buf, size_t nbyte)
```

et stocker les octets lus dans un tampon.
Elle doit ensuite retourner le premier octet lu sous la forme d'un entier signé.
Lors des appels suivants, la fonction doit retourner les octets lus en avance et stockés dans le tampon.
Lorsque le tampon est épuisé (tous les octets lus ont été consommés), il faut lire un nouveau bloc d'octets sur l'entrée standard à l'aide de la primitive `read()`.

Lorsqu'il n'y a plus rien à lire ou en cas d'erreur, la fonction `mygetchar()` doit retourner la constante `MYEOF`. Il vous appartient de définir sa valeur.

Vous ne devez pas utiliser de variables globales.
Des états peuvent être sauvegardés au sein d'un fonction via l'utilisation de variables déclarées comme `static` :

```c
static int a;
static char buf[];
```

Une variable `static` à l'intérieur d'une fonction conserve sa valeur entre les différentes invocations de la fonction.

## Test préliminaire

Les commandes suivantes créent un fichier binaire `toto_b` et le copie dans un fichier `toto_b.cpy` à l'aide de votre programme :

```sh
head -c 10240000 /dev/urandom > toto_b
./getchar < toto_b > toto_b.cpy
```

La commande `cmp` compare le contenu des deux fichiers `toto_b` et `toto_b.cpy`.
Si elle ne produit rien en sortie, c'est que le contenu des deux fichiers est identique et que votre fonction `mygetchar()` est, a priori, fonctionnelle :

```sh
cmp toto_b toto_b.cpy
```

Comparez ensuite la vitesse d'exécution du programme courant sur ce fichier avec la version réalisée à lors de l'exercice précédent.
Que constatez-vous ?
Que pouvez-vous en conclure ?

## Validation

Votre programme doit obligatoirement passer tous les tests sur gitlab (il suffit de `commit/push` le fichier source pour déclencher le pipeline de compilation et de tests) avant de passer à l'exercice suivant.
