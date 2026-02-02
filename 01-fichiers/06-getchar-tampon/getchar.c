#include <stdio.h>
#include <sys/types.h>
#include <unistd.h>

#define MYEOF 0 // à remplacer par une valeur adéquate

int
mygetchar(void)
{
    return MYEOF; // à modifier
}

int
main(void)
{
    int c;
    while ((c = mygetchar()) != MYEOF)
        putchar(c);

    return 0;
}
