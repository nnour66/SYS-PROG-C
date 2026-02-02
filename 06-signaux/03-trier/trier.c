#include <errno.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdnoreturn.h>
#include <time.h>
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
 * Trie un tableau d'entiers par ordre croissant à l'aide du tri à bulle.
 *
 * @param tab  Pointeur vers le tableau d'entiers à trier
 * @param size Nombre d'éléments du tableau
 *
 * Le tri est effectué en place.
 */
void
trier(int *tab, int size)
{
    (void) tab;   // à supprimer
    (void) size;  // à supprimer
}

int
main(int argc, char *argv[])
{
    (void) argc; // à supprimer
    (void) argv; // à supprimer

    return 0;
}
