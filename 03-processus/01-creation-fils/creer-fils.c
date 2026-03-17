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
main(void)
{
    pid_t pid=fork();
    switch (pid)
    {
    case -1 :
        raler("fork");
    case 0 :
        sleep(2);
        exit(getpid()%10);
    }
    int status;
    pid=wait(&status);
    CHK(pid);
    if (WIFEXITED(status))
    {
        printf("%jd %jd %d\n", (intmax_t)getpid(), (intmax_t)pid, WEXITSTATUS(status));
    }
}
