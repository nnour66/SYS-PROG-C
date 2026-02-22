#include <stdio.h>
#include <sys/types.h>
#include <unistd.h>

#define MYEOF (-1) // à remplacer par une valeur adéquate

int
mygetchar(void)
{
    unsigned char c;
    ssize_t s=read(STDIN_FILENO, &c, 1);
    if (s==1)
    {
        return (int)c;
    }else
    {
       return MYEOF; 
    }
}

int
main(void)
{
    int c;
    while ((c = mygetchar()) != MYEOF)
        putchar(c);

    return 0;
}
