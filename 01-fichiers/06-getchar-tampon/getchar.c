#include <stdio.h>
#include <sys/types.h>
#include <unistd.h>

#define MYEOF -1 // à remplacer par une valeur adéquate
#define BUFFER_SIZE 4096 // Plus grand moins d'appel à la fonc read
                        // Plus le programme devient rapide 

int
mygetchar(void)
{
    static unsigned char buff[BUFFER_SIZE];
    static ssize_t nb_lus=0;
    static ssize_t i=0;

    if (i>=nb_lus)
    {
        nb_lus=read(STDIN_FILENO, buff, sizeof(buff));
        if (nb_lus<=0)
        {
            return MYEOF;
        }
        i=0;
    }
    return (int)buff[i++];
}

int
main(void)
{
    int c;
    while ((c = mygetchar()) != MYEOF)
        putchar(c);

    return 0;
}
