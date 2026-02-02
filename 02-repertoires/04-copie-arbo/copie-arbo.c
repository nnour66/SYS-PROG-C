#include <dirent.h>
#include <errno.h>
#include <fcntl.h>
#include <limits.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdnoreturn.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
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
 * Concatène et formate une chaîne de caractères dans un tampon fourni.
 *
 * Cette fonction utilise une liste d'arguments variables (à la manière de
 * printf) pour écrire une chaîne formatée dans `result`, sans dépasser la
 * taille maximale `size`. Elle s'appuie sur `vsnprintf` afin de prévenir les
 * débordements de mémoire. En cas d'erreur ou de troncature, le programme est
 * arrêté.
 *
 * @param result Tampon de destination pour la chaîne résultante.
 * @param size   Taille maximale du tampon `result`.
 * @param format Chaîne de format (type printf).
 * @param ...    Arguments correspondant au format.
 */
void
concatener(char *result, int size, char *format, ...)
{
    va_list ap;
    va_start(ap, format);

    int n = vsnprintf(result, size, format, ap);
    if (n < 0 || n >= size) {
        fprintf(stderr, "snprintf %s", result);
        exit(EXIT_FAILURE);
    }
    va_end(ap);

    return;
}

int
main (int argc, char *argv[])
{
    (void) argc; // à supprimer
    (void) argv; // à supprimer

    return 0;
}
