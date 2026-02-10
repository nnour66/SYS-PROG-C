#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdnoreturn.h>
#include <unistd.h>
#include <errno.h>

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
        fprintf(stderr,"Usage: %s nom_fichier\n", argv[0]);
        return 1;
    }

    char* filename = argv[1];
    char r = '-';
    char w = '-';
    int fd;
    
    fd = open(filename, O_RDONLY);
    if (fd>=0)
    {
        r='R';
        CHK(close(fd));
    }else if(errno!=EACCES){
        raler("open 1");
    }

    fd= open(filename, O_WRONLY);
    if (fd>=0)
    {
        w='W';
        CHK(close(fd));
    }else if (errno!=EACCES)
    {
        raler("open 2");
    }

    printf("%s: %c%c\n",filename,r,w);

    return 0;
}
