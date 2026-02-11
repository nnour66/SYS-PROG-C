#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdnoreturn.h>
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
        fprintf(stderr, "Usage : %s mon_fichier\n",argv[0]);
        exit(1);
    }
    char buff[1000];
    int fd;
    char* filename=argv[1];
    ssize_t nb_caracteres_lus;
    CHK(fd=open(filename, O_RDONLY));
    //pour le comptage je suppose que le fichier
    //ne dépasse pas les 2 Go.
    
    int nb_octets=0;
    int nb_mots=0;
    int nb_lignes=0;
    int vide_ou_pas=0;

    while ((nb_caracteres_lus=read(fd,buff,sizeof(buff)))>0)
    {
        for(ssize_t i=0;i<nb_caracteres_lus;i++){
            char c=buff[i];
            nb_octets++;
            if (c=='\n')
            {
                nb_lignes++;
            }
            if (c == ' ' || c == '\n' || c == '\t' ||
                c == '\r' || c == '\v' || c == '\f')
            {
                vide_ou_pas = 0;
            }
            else
            {
                if (vide_ou_pas==0)
                {
                    nb_mots++;
                    vide_ou_pas=1;
                }
                
            }  
        }
    
    }
    CHK(nb_caracteres_lus);
    printf("%d %d %d\n", nb_lignes, nb_mots, nb_octets);
    CHK(close(fd));
    return 0;
}
