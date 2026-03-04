#include <stdarg.h>
#include <dirent.h>
#include <errno.h>
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdnoreturn.h>
#include <string.h>
#include <sys/stat.h>
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
 * Concatène et formate une chaîne de caractères dans un tampon fourni.
 *
 * Cette fonction utilise une liste d'arguments variables (à la manière de
 * printf) pour écrire une chaîne formatée dans `result`, sans dépasser la
 * taille maximale `size`. Elle s'appuie sur `vsnprintf` afin de prévenir les
 * débordements de mémoire. En cas d'erreur ou de troncature, le programme est
 * arrêté.
 *
 * @param result Tampon de destination pour la chaîne résultante.
 * @param size   Taille maximale du tampon `result`.
 * @param format Chaîne de format (type printf).
 * @param ...    Arguments correspondant au format.
 */
void
concatener(char *result, int size, char *format, ...)
{
    va_list ap;
    va_start(ap, format);

    int n = vsnprintf(result, size, format, ap);
    if (n < 0 || n >= size) {
        fprintf(stderr, "snprintf %s", result);
        exit(EXIT_FAILURE);
    }
    va_end(ap);

    return;
}

//faut faire une fonction auxiliaire pour gerer la recurrence
void 
dir_rec(const char* path, int depth)
{
    errno = 0;
    printf("%s\n", path);
    if (depth==0) return;
    
    DIR * dir=opendir(path);
    if (dir==NULL) raler("opendir");
    
    struct dirent * entry;
    while ((entry=readdir(dir))!=NULL)
    {
        if (strcmp(entry->d_name,".")==0 || strcmp(entry->d_name, "..")==0)
        {
            continue;
        }
        char child[PATH_MAX];
        concatener(child, PATH_MAX, "%s/%s", (char *)path, entry->d_name);
        struct stat s;
        CHK(lstat(child, &s));;
        if (S_ISDIR(s.st_mode))
        {
            dir_rec(child, depth-1);
        }
    }
    if (errno != 0) raler("readdir");
    CHK(closedir(dir));
}
int
main(int argc, char *argv[])
{
    if (argc!=3)
    {
        fprintf(stderr, "Usage : %s repertoire profondeur", argv[0]);
        exit(EXIT_FAILURE);
    }
    //au cas ou la profondeur n'a pas la bonne valeur
    char *end = NULL;
    long depth = strtol(argv[2], &end, 10);

    if (end == argv[2] || *end != '\0' || depth < 1) {
        fprintf(stderr, "Profondeur invalide : %s\n", argv[2]);
        exit(EXIT_FAILURE);
    }
    
    struct stat s;
    CHK(lstat(argv[1], &s));
    if(!S_ISDIR(s.st_mode)){
        fprintf(stderr, "%s n'est pas un repertoire", argv[1]);
        exit(EXIT_FAILURE);
    }

    dir_rec(argv[1], (int)depth);
    
    return 0;
}
