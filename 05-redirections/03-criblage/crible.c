#include <math.h>
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

static void
ecrire_entier(int fd, int x)
{
    const char *p = (const char *)&x;
    size_t reste = sizeof(x);

    while (reste > 0) {
        ssize_t n = write(fd, p, reste);
        CHK(n);
        p += n;
        reste -= (size_t)n;
    }
}

static int
lire_entier(int fd, int *x)
{
    char *p = (char *)x;
    size_t reste = sizeof(*x);

    while (reste > 0) {
        ssize_t n = read(fd, p, reste);
        if (n == 0) {
            return 0;
        }
        CHK(n);
        p += n;
        reste -= (size_t)n;
    }

    return 1;
}

static noreturn void
generateur(int fdout, int n)
{
    sleep(2);

    for (int i = 2; i <= n; i++) {
        ecrire_entier(fdout, i);
    }

    CHK(close(fdout));
    exit(EXIT_SUCCESS);
}

static noreturn void
filtre(int fdin, int fdout, int k)
{
    int x;

    sleep(2);

    while (lire_entier(fdin, &x)) {
        if (x == k || x % k != 0) {
            ecrire_entier(fdout, x);
        }
    }

    CHK(close(fdin));
    CHK(close(fdout));
    exit(EXIT_SUCCESS);
}

static noreturn void
imprimeur(int fdin)
{
    int x;

    sleep(2);

    while (lire_entier(fdin, &x)) {
        printf("%d\n", x);
    }

    CHK(close(fdin));
    exit(EXIT_SUCCESS);
}

int
main(int argc, char *argv[])
{
    int n;
    char c;
    int nb_enfants = 0;
    int tube_prec[2];
    int borne;

    if (argc != 2) {
        fprintf(stderr, "Usage: %s N\n", argv[0]);
        return EXIT_FAILURE;
    }

    if (sscanf(argv[1], "%d%c", &n, &c) != 1 || n < 2) {
        fprintf(stderr, "N doit etre un entier >= 2\n");
        return EXIT_FAILURE;
    }

    CHK(pipe(tube_prec));

    switch (fork()) {
    case -1:
        raler("fork");

    case 0:
        CHK(close(tube_prec[0]));
        generateur(tube_prec[1], n);

    default:
        nb_enfants++;
        CHK(close(tube_prec[1]));
        break;
    }

    borne = (int)sqrt((double)n);

    for (int k = 2; k <= borne; k++) {
        int tube_suiv[2];

        CHK(pipe(tube_suiv));

        switch (fork()) {
        case -1:
            raler("fork");

        case 0:
            CHK(close(tube_suiv[0]));
            filtre(tube_prec[0], tube_suiv[1], k);

        default:
            nb_enfants++;
            CHK(close(tube_prec[0]));
            CHK(close(tube_suiv[1]));
            tube_prec[0] = tube_suiv[0];
            break;
        }
    }

    switch (fork()) {
    case -1:
        raler("fork");

    case 0:
        imprimeur(tube_prec[0]);

    default:
        nb_enfants++;
        CHK(close(tube_prec[0]));
        break;
    }

    {
        int ok = 1;

        for (int i = 0; i < nb_enfants; i++) {
            int status;
            pid_t pid = wait(&status);

            CHK(pid);

            if (!(WIFEXITED(status) && WEXITSTATUS(status) == 0)) {
                ok = 0;
            }
        }

        return ok ? EXIT_SUCCESS : EXIT_FAILURE;
    }
}