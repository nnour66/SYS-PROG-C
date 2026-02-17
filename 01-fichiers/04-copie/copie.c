#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdnoreturn.h>
#include <sys/types.h>
#include <unistd.h>
#define NOUR 1000

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
    if (argc!=3)
    {
        fprintf(stderr,"Usage : %s Source Destination\n", argv[0]);
        exit(1);
    }
    char* filename=argv[1];
    int fd1;
    int fd2;
    CHK(fd1=open(filename, O_RDONLY));
    CHK(fd2=open(argv[2], O_WRONLY | O_CREAT | O_TRUNC, 0644));
    ssize_t nbr_de_caracteres_lus;
    char buffer [NOUR];

    while ((nbr_de_caracteres_lus=read(fd1, buffer, sizeof(buffer)))>0)
    {
        ssize_t nbr_de_caracteres_w=write(fd2, buffer, nbr_de_caracteres_lus);
        CHK(nbr_de_caracteres_w);
        if (nbr_de_caracteres_lus!=nbr_de_caracteres_w)
        {
            raler("Write Failure");
        }
    }
    CHK(nbr_de_caracteres_lus);
    CHK(close(fd1));
    CHK(close(fd2));
    
    

    return 0;
}
