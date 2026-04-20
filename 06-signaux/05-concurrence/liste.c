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

volatile long long int compteur_pere = 0;
volatile sig_atomic_t m = 0; 

void handlerFils(int sig){
    m = sig;
}


void handlerPere(int sig) {
    inserer(sig, compteur_pere);
}

noreturn void fils(sigset_t mask, int i){
    
    sigset_t mask_empty;
    CHK(sigemptyset(&mask_empty));
    
    struct sigaction s;
    s.sa_handler = handlerFils;
    s.sa_flags = 0;
    sigemptyset(&s.sa_mask);
    CHK(sigaction(SIGUSR1, &s, NULL));

    CHK(sigprocmask(SIG_BLOCK, &mask, NULL));
    if ( m == 0) 
    {
        sigsuspend(&mask_empty);
    }
    printf("child %2d: START\n", i);
    for (int j = 0; j < NBITER; j++)
        CHK(kill(getppid(), i)); 
    
    printf("child %2d: END\n", i);
    sleep(2);
    exit(EXIT_SUCCESS);
}

int
main (void)
{
    pid_t child[NBSIG];

    sigset_t mask_empty;
    CHK(sigemptyset(&mask_empty));

    // creation du mask pour le handler 
    sigset_t mask_all, old_mask;
    CHK(sigemptyset(&mask_all)); 
    

    for (int i = 1; i < NBSIG; i++) {
        if (i == SIGKILL || i == SIGSTOP) {
            continue;
        }
        
        CHK(sigaddset(&mask_all, i));
    }

    // creation du handler et affectation a chaque signale
    struct sigaction sp;
    sp.sa_handler = handlerPere;
    sp.sa_flags = 0;
    sp.sa_mask = mask_all; 

    for (int i = 1; i < NBSIG; i++) {
        if (i == SIGKILL || i == SIGSTOP) {
            continue;
        }
        
        CHK(sigaction(i, &sp, NULL));
    }

    sigset_t mask;
    CHK(sigemptyset(&mask));
    CHK(sigaddset(&mask, SIGUSR1));
    CHK(sigprocmask(SIG_BLOCK, &mask, NULL));
    
    // creation des processus fils
    for (int i = 1; i < NBSIG; i++) 
    {
        if ( i == SIGKILL || i == SIGSTOP) 
            continue;
        
        switch ( child[i] = fork()) 
        {
        case -1:
            raler("fork");
        case 0:
            fils(mask, i);
        }
        
    }

    CHK(sigprocmask(SIG_UNBLOCK, &mask, NULL));
    
    // envoit du depart a tout les fils
    for (int i = 1; i < NBSIG; i++) 
    {
        if ( i == SIGKILL || i == SIGSTOP) 
            continue;
        
        CHK(kill(child[i], SIGUSR1));
    }

    // la boucle d incrementation
    for (compteur_pere = 0; compteur_pere < NBITER; compteur_pere++) {
        
        CHK(sigprocmask(SIG_BLOCK, &mask_all, &old_mask));
        
        inserer(0, compteur_pere);
        
        CHK(sigprocmask(SIG_SETMASK, &old_mask, NULL));
    }

    // attente de tout les fils
    int status;
    for (int i = 1; i < NBSIG; i++) {
        if (i == SIGKILL || i == SIGSTOP || i == SIGUSR1) continue;
        CHK(wait(&status));
        if ( !WIFEXITED(status) && WEXITSTATUS(status) != EXIT_SUCCESS )
        {   
            fprintf(stderr, "Erreur terminaison d'un fils\n"); 
            return EXIT_FAILURE;
        }
    }

    // affichage 
    print_and_detect();

    return 0;
}