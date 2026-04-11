#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdnoreturn.h>
#include <string.h>
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
    sigset_t mask;
    sigset_t pending;
    CHK(sigfillset(&mask));
    CHK(sigprocmask(SIG_SETMASK, &mask, NULL));
    sleep(5);
    CHK(sigpending(&pending));
    for (int i = 1; i < _NSIG; i++)
    {
        int res=sigismember(&pending, i);
        CHK(res);
        if (res==1)
        {
            printf("%s\n", strsignal(i));
        }
    }
    return 0;
    
}
