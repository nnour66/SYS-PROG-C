# Programmation système - Exécution d'une commande

Complétez le programme `execmd.c` qui recouvre le processus courant avec le code d'un fichier exécutable.
Le programme admet en argument le nom du fichier exécutable ainsi que ses éventuels arguments :

```sh
./execmd fichier_exe [arg1 arg2]
```

Par exemple :

```sh
./execmd ls -lR /tmp
```

**Objectifs :** recouvrir un processus via la primitive `exec*`.

## Marche à suivre

Vous pouvez recouvrir le segment TEXT du processus courant avec le code d'un fichier exécutable à l'aide de la primitive :

```c
int execvp(const char *file, char *const argv[])
```

On rappelle qu'en cas de succès, le code exécutable présent dans le fichier `file` remplace le code du programme courant (recouvrement de processus).

## Test préliminaire

Les commandes suivantes créent un répertoire contenant deux fichiers puis exécutent la commande `ls -l` sur ce dernier :

```sh
mkdir essai ; touch essai/1 ; touch essai/2 ; ls -l essai > output1
./execmd ls -l essai > output2
```

La commande `cmp` compare le contenu des deux fichiers `output1` et `output2`.
Si elle ne produit rien en sortie, c'est que le contenu des deux fichiers est identique et que votre programme est, a priori, fonctionnel :

```sh
cmp output1 output2
```

## Validation

Votre programme doit obligatoirement passer tous les tests sur gitlab (il suffit de `commit/push` le fichier source pour déclencher le pipeline de compilation et de tests) avant de passer à l'exercice suivant.
