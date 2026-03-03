#include <dirent.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdnoreturn.h>

/**
 * Macro pour tester le retour des primitives système
 */
#define CHK(op)                                                                \
    do {                                                                       \
        if ((op) == -1)                                                        \
            raler(#op);                                                        \
    } while (0)

/**
 * La légendaire fonction raler() directement appelée par la macro CHK()
 */
noreturn void
raler(const char *msg)
{
    perror(msg);
    exit(EXIT_FAILURE);
}

int
main(int argc, char *argv[])
{
    if (argc!=2)
    {
        fprintf(stderr, "Usage : %s nom_repertoire\n", argv[0]);
        exit(EXIT_FAILURE);
    }
    DIR *dir=opendir(argv[1]);
    if (dir==NULL)
    {
        raler("Problème d'allocation");
    }
    struct dirent *entry;

    while ((entry = readdir(dir)) != NULL)
    {
        if (entry->d_name[0] == '.')
            continue;  

        printf("%s\n", entry->d_name);
    }
    closedir(dir);
    return 0;
}
