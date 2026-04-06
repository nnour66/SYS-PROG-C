#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdnoreturn.h>
#include <sys/wait.h>
#include <unistd.h>

#define SIZE 4

#define ADD 1
#define SUB 3
#define MUL 5
#define DIV 7

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
fils_operateur(int fdin, int fdres, char op)
{
    int a;
    int b;
    int r;

    sleep(2);

    while (1) {
        if (!lire_entier(fdin, &a)) {
            break;
        }

        if (!lire_entier(fdin, &b)) {
            fprintf(stderr, "lecture incomplete\n");
            exit(EXIT_FAILURE);
        }

        switch (op) {
        case '+':
            r = a + b;
            break;
        case '-':
            r = a - b;
            break;
        case '*':
            r = a * b;
            break;
        case '/':
            r = a / b;
            break;
        default:
            fprintf(stderr, "operateur inconnu\n");
            exit(EXIT_FAILURE);
        }

        ecrire_entier(fdres, r);
    }

    CHK(close(fdin));
    CHK(close(fdres));
    exit(EXIT_SUCCESS);
}

static int
indice_operateur(char op)
{
    switch (op) {
    case '+':
        return 0;
    case '-':
        return 1;
    case '*':
        return 2;
    case '/':
        return 3;
    default:
        return -1;
    }
}

int
main(int argc, char *argv[])
{
    int tube_res[2];
    int tubes_ops[SIZE][2];
    char ops[SIZE] = {'+', '-', '*', '/'};
    int nb_enfants = 0;
    int ok = 1;

    CHK(pipe(tube_res));

    for (int i = 0; i < SIZE; i++) {
        CHK(pipe(tubes_ops[i]));
    }

    for (int i = 0; i < SIZE; i++) {
        switch (fork()) {
        case -1:
            raler("fork");

        case 0:
            for (int j = 0; j < SIZE; j++) {
                if (j == i) {
                    CHK(close(tubes_ops[j][1]));
                } else {
                    CHK(close(tubes_ops[j][0]));
                    CHK(close(tubes_ops[j][1]));
                }
            }

            CHK(close(tube_res[0]));
            fils_operateur(tubes_ops[i][0], tube_res[1], ops[i]);

        default:
            nb_enfants++;
            break;
        }
    }

    for (int i = 0; i < SIZE; i++) {
        CHK(close(tubes_ops[i][0]));
    }
    CHK(close(tube_res[1]));

    if (argc != 2 && (argc < 4 || argc % 2 != 0))  {
        fprintf(stderr, "usage: %s a op b [op c ...]\n", argv[0]);

        for (int i = 0; i < SIZE; i++) {
            CHK(close(tubes_ops[i][1]));
        }
        CHK(close(tube_res[0]));

        for (int i = 0; i < nb_enfants; i++) {
            int status;
            pid_t pid = wait(&status);
            CHK(pid);
        }

        return EXIT_FAILURE;
    }

    sleep(2);

    if (argc == 2) {
        for (int i = 0; i < SIZE; i++) {
            CHK(close(tubes_ops[i][1]));
        }
        CHK(close(tube_res[0]));

        for (int i = 0; i < nb_enfants; i++) {
            int status;
            pid_t pid = wait(&status);
            CHK(pid);

            if (!(WIFEXITED(status) && WEXITSTATUS(status) == 0)) {
                ok = 0;
            }
        }

        if (!ok) {
            fprintf(stderr, "un fils s'est termine en erreur\n");
            return EXIT_FAILURE;
        }

        return EXIT_SUCCESS;
    }

    {
        int resultat = atoi(argv[1]);

        for (int i = 2; i < argc; i += 2) {
            int idx;
            int suivant;
            int recu;

            if (argv[i][1] != '\0') {
                fprintf(stderr, "operateur inconnu: %s\n", argv[i]);

                for (int j = 0; j < SIZE; j++) {
                    CHK(close(tubes_ops[j][1]));
                }
                CHK(close(tube_res[0]));

                for (int j = 0; j < nb_enfants; j++) {
                    int status;
                    pid_t pid = wait(&status);
                    CHK(pid);
                }

                return EXIT_FAILURE;
            }

            idx = indice_operateur(argv[i][0]);
            if (idx == -1) {
                fprintf(stderr, "operateur inconnu: %s\n", argv[i]);

                for (int j = 0; j < SIZE; j++) {
                    CHK(close(tubes_ops[j][1]));
                }
                CHK(close(tube_res[0]));

                for (int j = 0; j < nb_enfants; j++) {
                    int status;
                    pid_t pid = wait(&status);
                    CHK(pid);
                }

                return EXIT_FAILURE;
            }

            suivant = atoi(argv[i + 1]);

            ecrire_entier(tubes_ops[idx][1], resultat);
            ecrire_entier(tubes_ops[idx][1], suivant);

            if (!lire_entier(tube_res[0], &recu)) {
                fprintf(stderr, "aucun resultat recu\n");

                for (int j = 0; j < SIZE; j++) {
                    CHK(close(tubes_ops[j][1]));
                }
                CHK(close(tube_res[0]));

                for (int j = 0; j < nb_enfants; j++) {
                    int status;
                    pid_t pid = wait(&status);
                    CHK(pid);
                }

                return EXIT_FAILURE;
            }

            resultat = recu;
        }

        for (int i = 0; i < SIZE; i++) {
            CHK(close(tubes_ops[i][1]));
        }
        CHK(close(tube_res[0]));

        for (int i = 0; i < nb_enfants; i++) {
            int status;
            pid_t pid = wait(&status);
            CHK(pid);

            if (!(WIFEXITED(status) && WEXITSTATUS(status) == 0)) {
                ok = 0;
            }
        }

        if (!ok) {
            fprintf(stderr, "un fils s'est termine en erreur\n");
            return EXIT_FAILURE;
        }

        printf("%d\n", resultat);
        return EXIT_SUCCESS;
    }
}