# Programmation système - Compter les lignes, mots et octets d'un fichier

Complétez le programme `wordcount.c` qui affiche sur la sortie standard le nombre de lignes, de mots et d'octets d'un fichier.
Il s'agit d'une version simplifée de la commande `wc`.

Le programme admet en argument le nom du fichier dont le contenu doit être comptabilisé :

```sh
./wordcount nom_fichier
```

On fera l'hypothèse que seuls des fichiers texte sont passés en argument du programme.

**Objectifs :** savoir ouvrir, lire et manipuler le contenu d'un fichier avec les primitives système.

## Marche à suivre

Vous devez ouvrir le fichier passé en argument et lire son contenu par blocs à l'aide des primitives :

```c
int open(const char *path, int oflag, ...)
ssize_t read(int fildes, void *buf, size_t nbyte)
```

Après lecture d'un bloc, vous devez analyser les octets lus.
On rappelle que les caractères suivants appartiennent à la classe de caractères « space » et sont à utiliser pour déterminer les extrémités d'un mot :

    \n : saut de ligne
    \f : form feed
    \r : retour chariot
    \t : tabulation horizontale
    \v : tabulation verticale

Enfin, vous devez afficher sur la sortie standard le nombre de lignes, mots et octets sous la forme :

```sh
./wordcount toto
12 345 6789
```

où `12`, `345` et `6789` correspondent respectivement au nombre de lignes, de mots et d'octets contenus dans le fichier `toto`.
Cet affichage pourra utiliser une fonction de bibliothèque (e.g. `printf`).

## Test préliminaire

La commande suivante crée le fichier `toto` qui comporte 10243 octets (uniquement des caractères ASCII) :

```sh
LC_ALL=C tr -dc "A-Za-z0-9 \n\t\r\v\f" < /dev/urandom | head -c 10243 > toto
```

Vous pouvez ensuite comparer la sortie de la commande `wc` avec la sortie de votre programme :

```sh
wc toto | tr -s ' ' | cut -d ' ' -f2,3,4 > output1
./wordcount toto > output2
```

La commande `cmp` compare le contenu des deux fichiers `output1` (prduit par la commande `wc`) et `output2` (produit par votre programme).
Si elle ne produit rien en sortie, c'est que le contenu des deux fichiers est identique et que votre programme est, a priori, fonctionnel :

```sh
cmp output1 output2
```

## Validation

Votre programme doit obligatoirement passer tous les tests sur gitlab (il suffit de `commit/push` le fichier source pour déclencher le pipeline de compilation et de tests) avant de passer à l'exercice suivant.
