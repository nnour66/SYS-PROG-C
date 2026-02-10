#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdnoreturn.h>
#include <sys/types.h>
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
        fprintf(stderr,"Usage : %s nom_fichier\n", argv[0]);
        exit(1);
    }
    char* filename= argv[1];
    int fd;
    char buffer[1000];
    ssize_t nb_caracteres_lu;
    CHK(fd=open(filename,O_RDONLY));
    while ((nb_caracteres_lu=read(fd, buffer, sizeof(buffer)))>0)
    {
        fwrite(buffer, 1, nb_caracteres_lu, stdout);
    }

    if (nb_caracteres_lu==-1)
    {
        raler("read probleme");
    }
    CHK(close(fd));

    return 0;
}
