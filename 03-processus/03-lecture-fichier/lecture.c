#include <fcntl.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdnoreturn.h>
#include <sys/wait.h>
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
 * Pour afficher en couleur, compiler le programme avec :
 * scons -Q color=1
 */
#ifdef COLOR
#define JAUN "\x1B[33m"
#define BLEU "\x1B[34m"
#else
#define JAUN ""
#define BLEU ""
#endif

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
    (void) argc; // à supprimer
    (void) argv; // à supprimer

    return 0;
}
