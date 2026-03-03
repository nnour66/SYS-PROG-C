#include <stdio.h>
#include <stdlib.h>
#include <stdnoreturn.h>
#include <sys/stat.h>

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
        fprintf(stderr, "Usage : %s nom_du_fichier\n", argv[0]);
        exit(EXIT_FAILURE);
    }

    struct stat s;
    CHK(stat(argv[1], &s));

    if (S_ISDIR(s.st_mode))
        return 0;
    else
        return 1;
    
}
