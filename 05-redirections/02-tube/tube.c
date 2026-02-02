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
 * La légendaire fonction raler() directement appelée par la macro CHK()
 */
noreturn void
raler(const char *msg)
{
    perror(msg);
    exit(EXIT_FAILURE);
}

/**
 * Copie le contenu lu sur un descripteur dans un autre descripteur.
 * @param fdsrc Descripteur source ouvert en lecture
 * @param fddst Descripteur destination ouvert en écriture
 */
void
copier(int fdsrc, int fddst)
{
    (void) fdsrc; // à supprimer
    (void) fddst; // à supprimer
}

int
main(void)
{
    return 0;
}
