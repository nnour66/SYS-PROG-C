#include <errno.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdnoreturn.h>
#include <sys/wait.h>
#include <unistd.h>

#define NBSIG 32
#define NBITER 1000 * 1000

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

volatile long long int asynctr = 0;

struct elem {
    int type;
    long long int val;
    struct elem *suiv;
};
struct elem *tete = NULL;

void
inserer(int type, long long int val)
{
    struct elem *e;
    if ((e = malloc(sizeof *e)) == NULL)
        raler("malloc");

    e->suiv = tete;
    e->type = type;
    e->val  = val;
    tete    = e;
}

void
print_and_detect(void)
{
    int type[NBSIG] = {0};

    long long int pval = tete->val;
    type[tete->type]++;
    struct elem *tmp = tete->suiv;

    while (tmp != NULL) {
        if (tmp->type == 0) {
            if (tmp->val != pval - 1)
                fprintf(stderr, "error: %lld %lld\n", tmp->val, pval);

            pval = tmp->val;
        }
        type[tmp->type]++;
        tmp = tmp->suiv;
    }

    for (int i = 0 ; i < NBSIG ; i++)
        printf("type %d: %d\n", i, type[i]);
}

int
main (void)
{
    return 0;
}
