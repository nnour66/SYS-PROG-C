#include <stdarg.h>
#include <fcntl.h>
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
}

int
main(int argc, char *argv[])
{
    int status;
    pid_t pid;

    if (argc != 2) {
        fprintf(stderr, "Usage : %s username\n", argv[0]);
        return EXIT_FAILURE;
    }

    switch (pid = fork()) {
    case -1:
        raler("fork");

    case 0: {
        int fd = open("toto", O_CREAT | O_WRONLY | O_TRUNC, 0666);
        CHK(fd);
        CHK(dup2(fd, STDOUT_FILENO));
        CHK(close(fd));

        execlp("ps", "ps", "-eo", "user:100", NULL);
        raler("execlp ps");
    }

    default:
        CHK(wait(&status));
        if (!(WIFEXITED(status) && WEXITSTATUS(status) == 0)) {
            fprintf(stderr, "ps failed\n");
            return EXIT_FAILURE;
        }
        break;
    }

    switch (pid = fork()) {
    case -1:
        raler("fork");

    case 0: {
        int fdin = open("toto", O_RDONLY);
        CHK(fdin);
        CHK(dup2(fdin, STDIN_FILENO));
        CHK(close(fdin));

        int fdout = open("/dev/null", O_WRONLY);
        CHK(fdout);
        CHK(dup2(fdout, STDOUT_FILENO));
        CHK(close(fdout));

        execlp("grep", "grep", argv[1], NULL);
        raler("execlp grep");
    }

    default:
        CHK(wait(&status));
        if (WIFEXITED(status) && WEXITSTATUS(status) == 0) {
            printf("%s is connected\n", argv[1]);
            return 0;
        }
        return 1;
    }
}