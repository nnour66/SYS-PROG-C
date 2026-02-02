# Programmation système

Ce dépôt contient une liste d'exercices pratiques pour apprendre à utiliser les primitives système en C. Les exercices sont progressifs et doivent être réalisés dans l'ordre. La majorité des exercices ont été créés par @pda, @loechner ou @alain.

## Compilation

Un squelette de programme C est fourni pour chaque exercice. Pour le compiler, vous pouvez simplement utiliser l'outil `SCons` qui est un équivalent de `make` :

```sh
    scons
```

Pour nettoyer le répertoire courant, il suffit de passer l'option `-c` :

```sh
    scons -c
```

## Tests locaux natifs

Un script de tests en `bash` est fourni pour chaque exercice. Après avoir compilé votre programme, vous pouvez le tester via le script :

```sh
    ./tests.sh
```

Suivant les exerices, plusieurs tests sont réalisés et un `[PASS]` indique que le test est réussi.
Sinon, un court message vous indique la raison de l'échec, vous permettant de corriger les erreurs dans votre programme.

Vous pouvez également lancer un test en particulier, en précisant son numéro.
Par exemple, pour ne lancer que le test 2 :

```sh
    ./tests.sh 2
```

Les scripts de tests sont fournis sans garantie de compatibilité avec votre système. 

## Tests locaux sur docker

Vous pouvez tester vos programmes dans une image docker (nécessite d'avoir `docker` installé sur votre système).

L'image `docker` configurée pour les exercices peut être récupérée localement et instanciée dans un conteneur via les commandes :

```sh
    docker pull registry.app.unistra.fr/montavont/img-docker/progsys
    cd chemin/vers/la/copie/locale/du/dépôt/git
    docker run --rm -it -v $PWD:/home/alice registry.app.unistra.fr/montavont/img-docker/progsys
```

## Tests sur gitlab

Les tests peuvent également être directement exécutés par gitlab dans un conteneur docker exécuté sur un runner de gitlab. Tout `commit/push` sur l'un des fichiers source provoque sa compilation et l'exécution du script de tests associés. Vous pouvez configurer le dépôt gitlab pour être notifié en cas de succès (ou d'échec) des tests.

Sur l'interface de gitlab, il suffit d'aller dans `build/pipeline` pour visualiser le résultat des tests.
