#include <fcntl.h>
#include <stdarg.h>
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
 * Pour afficher en couleur, compiler le programme avec :
 * scons -Q color=1
 */
#ifdef COLOR
#define JAUN "\x1B[33m"
#define BLEU "\x1B[34m"
#else
#define JAUN ""
#define BLEU ""
#endif

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
        fprintf(stderr," Usage : %s nom_fichier\n", argv[0]);
        exit(EXIT_FAILURE);
    }
    int fd1;
    CHK(fd1=open(argv[1], O_RDONLY));
    char c;
    ssize_t caracteres_lu_fils;
    ssize_t caracteres_lu_pere;
    pid_t pid=fork();
    switch (pid)
    {
    case -1:
        raler("fork");
    case 0:
        while ((caracteres_lu_fils=read(fd1, &c, 1))>0)
        {
            printf(BLEU "%c", c);
            fflush(stdout);
        }
        CHK(caracteres_lu_fils);
        CHK(close(fd1));
        sleep(2);
        exit(EXIT_SUCCESS);
    }
    
    while ((caracteres_lu_pere=read(fd1, &c, 1))>0)
        {
            printf(JAUN "%c", c);
            fflush(stdout);
        }
        CHK(caracteres_lu_pere);
        CHK(close(fd1));
        int status;
        CHK(wait(&status));
        if (!WIFEXITED(status)||WEXITSTATUS(status)!=0)
        {
            fprintf(stderr, "Le fils ne s'est pas terminé correctement\n");
            exit(EXIT_FAILURE);
        }
    
    return 0;
}
