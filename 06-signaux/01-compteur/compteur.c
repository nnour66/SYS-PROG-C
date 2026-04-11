#define _POSIX_C_SOURCE 200809L
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdnoreturn.h>

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

volatile sig_atomic_t count=0;


void handler(int sig){
    (void)sig;
    count ++;
    printf("compteur: %d\n", count);
}

int
main(void)
{
    struct sigaction s;
    s.sa_flags=0;
    sigemptyset(&s.sa_mask);
    s.sa_handler=handler;
    CHK(sigaction(SIGINT, &s, NULL));
    while (count<5);
    return 0;
    

}
