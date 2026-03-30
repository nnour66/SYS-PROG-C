#include <stdio.h>
#include <stdlib.h>
#include <stdnoreturn.h>
#include <unistd.h>

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
{#include <stdio.h>
#include <stdlib.h>
#include <stdnoreturn.h>
#include <unistd.h>

/**
 * Macro pour tester le retour des primitives système
 */
#define CHK(op)                                                                \
    do {                                                                       \
        if ((op) == -1)                                                        \
            raler(#op)#include <stdio.h>
#include <stdlib.h>
#include <stdnoreturn.h>
#include <unistd.h>

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
    if (argc < 2)
    {
        fprintf(stderr, "Usage : %s fichier_exe [arg1 arg2 ...]\n", argv[0]);
        exit(EXIT_FAILURE);
    }

    CHK(execvp(argv[1], &argv[1]));

    return 0; 
};                                                        \
    } while (0)

/**
 * La légendaire fonction raler() directement appelée par la macro CHK()
 */
noreturn void
raler(const char *msg)
{
    perror(msg);
    exit(EXIT_FAILURE)#include <stdio.h>
#include <stdlib.h>
#include <stdnoreturn.h>
#include <unistd.h>

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
    if (argc < 2)
    {
        fprintf(stderr, "Usage : %s fichier_exe [arg1 arg2 ...]\n", argv[0]);
        exit(EXIT_FAILURE);
    }

    CHK(execvp(argv[1], &argv[1]));

    return 0; 
}

int
main(int argc, char *argv[])
{
    if (argc < 2)
    {
        fprintf(stderr, "Usage : %s fichier_exe [arg1 arg2 ...]\n", argv[0]);
        exit(EXIT_FAILURE);
    }

    CHK(execvp(argv[1], &argv[1]));

    return 0; 
}
    perror(msg);
    exit(EXIT_FAILURE);
}

int
main(int argc, char *argv[])
{
    if (argc < 2)
    {
        fprintf(stderr, "Usage : %s fichier_exe [arg1 arg2 ...]\n", argv[0]);
        exit(EXIT_FAILURE);
    }

    CHK(execvp(argv[1], &argv[1]));

    return 0; 
}