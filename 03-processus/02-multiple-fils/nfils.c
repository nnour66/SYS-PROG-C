#include <stdint.h>
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

int
main(int argc, char *argv[])
{
    if (argc!=2)
    {
        fprintf(stderr, "Usage : %s n\n", argv[0]);
        exit(EXIT_FAILURE);
    }

    int n = atoi(argv[1]);
    if (n < 1 || n > 9) {
        fprintf(stderr, "n doit etre compris entre 1 et 9\n");
        exit(EXIT_FAILURE);
    }
    
    for (int i = 0; i < n; i++)
    {
        pid_t pid=fork();
        switch(pid){
            case -1 : raler("fork");
            case 0 : sleep(2); exit(0);
        }
    }
    for (int i = 0; i < n; i++)
    {
        int status;
        pid_t pid=wait(&status);
        CHK(pid);
        if (WIFEXITED(status))
        {
            printf("%jd %d\n", (intmax_t)pid, WEXITSTATUS(status));
        }
    }
    return 0;
}
