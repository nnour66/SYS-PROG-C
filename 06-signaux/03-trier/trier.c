#include <errno.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdnoreturn.h>
#include <time.h>
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
 * Trie un tableau d'entiers par ordre croissant à l'aide du tri à bulle.
 *
 * @param tab  Pointeur vers le tableau d'entiers à trier
 * @param size Nombre d'éléments du tableau
 *
 * Le tri est effectué en place.
 */
void
trier(int *tab, int size)
{
    for (int i = size-1; i > 0; i--)
    {
        for (int j = 0; j < i; j++)
        {
            if (tab[j+1]<tab[j])
            {
                int tmp=tab[j];
                tab[j]=tab[j+1];
                tab[j+1]=tmp;
            } 
        }
    }

}

void
handler(int sig){
    (void)sig;
    write(STDOUT_FILENO, "working\n", 8);
    alarm(1);
}


int
main(int argc, char *argv[])
{
    if (argc!=2)
    {
        fprintf(stderr, "Usage : %s taille_du_tableau\n", argv[0]);
        exit(EXIT_FAILURE);
    }
    struct sigaction s={0};
    int size=atoi(argv[1]);

    if (size <= 0) {
        fprintf(stderr, "La taille doit être un entier strictement positif\n");
        exit(EXIT_FAILURE);
    }

    int* tab=malloc(size*sizeof(int));
    if (tab==NULL)
    {
        raler("malloc");
    }

    srand(time(NULL));
    for (int i = 0; i < size; i++)
    {
        tab[i]= rand() % 1001;
    }

    s.sa_flags=0;
    CHK(sigemptyset(&s.sa_mask));
    s.sa_handler=handler;
    CHK(sigaction(SIGALRM, &s, NULL));

    alarm(1);
    trier(tab, size);
    alarm(0);
    
    for (int i = 0; i < size; i++)
    {
        printf("%d\n", tab[i]);
    }
    
    free(tab);
    

    return 0;
}
