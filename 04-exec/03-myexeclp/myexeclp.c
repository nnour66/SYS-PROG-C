#include <dirent.h>
#include <errno.h>
#include <limits.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdnoreturn.h>
#include <string.h>
#include <unistd.h>

#define MAX_ARG 5
#define INCREMENT_REALLOC 10

/** fonction qui sépare la chaine de caractères 'chaine'
 *  avec tous les séparateurs présents dans 'separateurs'
 *  renvoie un tableau NULL-terminated de mots
 *  utilise la mémoire de chaine pour cela (modifie la chaine) !
 */
char **
separe(char *chaine, const char *separateurs)
{
    char **tab;
    int i, s, m, size = INCREMENT_REALLOC;

    tab = calloc(size, sizeof *tab);
    if (tab == NULL)
        return NULL;
    m = 0;
    i = 0;
    while (chaine[i] != 0) {
        // saute un séparateur
        for (s = 0 ; separateurs[s] != '\0' ; s++)
            if (chaine[i] == separateurs[s])
                break;
        if (separateurs[s] != '\0') {
            // met une fin de chaine à la place du séparateur et avance
            chaine[i++] = '\0';
            continue; // les séparateurs n'ont pas été épuisés
        }

        if (chaine[i] != 0)
            tab[m++] = chaine + i;
        if (m == size) {
            // si j'atteins la limite de mon tableau, je l'agrandis.
            size += INCREMENT_REALLOC;
            tab = realloc(tab, size * sizeof *tab);
            if (tab == NULL)
                return NULL;
        }
        // saute les caractères non séparateurs
        for ( ; chaine[i] != '\0' ; i++) {
            for (s = 0 ; separateurs[s] != '\0' ; s++)
                if (chaine[i] == separateurs[s])
                    break;
            if (separateurs[s] != '\0')
                break; // trouvé un caractère séparateur : passer au suivant
        }
    }
    tab[m] = NULL;
    return tab;
}

/**
 * Fonction à compléter
 */
int
myexeclp(const char *file, const char *arg, ...)
{
    (void) file; // à supprimer
    (void) arg;  // à supprimer

    return -1;
}

int
main(int argc, char *argv [])
{
    if (argc < 2) {
        fprintf(stderr, "usage: %s fichier ...\n", argv [0]);
        exit(EXIT_FAILURE);
    }

    switch (argc) {
    case 2:
        myexeclp(argv[1], argv[1], NULL);
        break;

    case 3:
        myexeclp(argv[1], argv[1], argv[2], NULL);
        break;

    case 4:
        myexeclp(argv[1], argv[1], argv[2], argv[3], NULL);
        break;

    case 5:
        myexeclp(argv[1], argv[1], argv[2], argv[3], argv[4], NULL);
        break;

    case 6:
        myexeclp(argv[1], argv[1], argv[2], argv[3], argv[4], argv[5],
                 NULL);
        break;

    case 7:
        myexeclp(argv[1], argv[1], argv[2], argv[3], argv[4], argv[5],
                 argv[6], NULL);
        break;

    case 8:
        myexeclp(argv[1], argv[1], argv[2], argv[3], argv[4], argv[5],
                 argv[6], argv[7], NULL);
        break;
    }

    perror("myexeclp");
    return EXIT_FAILURE;
}
