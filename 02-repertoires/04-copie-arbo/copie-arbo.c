#include <dirent.h>
#include <errno.h>
#include <fcntl.h>
#include <limits.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdnoreturn.h>
#include <string.h>
#include <sys/stat.h>
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

void
copieFichier(char * src, char * destination){
    int fd=open(src, O_RDONLY);
    CHK(fd);
    int fd1=open(destination, O_WRONLY | O_CREAT | O_TRUNC, 0777);
    CHK(fd1);
    char buff[1024];
    ssize_t nb_octets_read=0;
    while ((nb_octets_read=read(fd, buff, sizeof(buff)))>0)
    {
        CHK(write(fd1, buff, nb_octets_read));
    }
    CHK(nb_octets_read);
    CHK(close(fd));
    CHK(close(fd1));
}

void
copieArbo(char * src, char* destination){
    DIR * dir=opendir(src);
    if (dir==NULL)
    {
        raler("opendir");
    }
    
    int mk = mkdir(destination, 0777);
    if (mk==-1 && errno!=EEXIST)
    {
        raler("mkdir");
    }
    
    struct dirent* entry;
    errno=0;
    while ((entry=readdir(dir))!=NULL)
    {
        if (strcmp(entry->d_name,".")==0 || strcmp(entry->d_name, "..")==0)
        {
            continue;
        }
        char child[PATH_MAX];
        concatener(child, PATH_MAX, "%s/%s", src, entry->d_name);
        char child_dest[PATH_MAX];
        concatener(child_dest, PATH_MAX, "%s/%s", destination, entry->d_name);
        struct stat s;
        CHK(lstat(child, &s));
        if (S_ISDIR(s.st_mode))
        {
            copieArbo(child, child_dest);
        }
        else if (S_ISREG(s.st_mode))
        {
            copieFichier(child, child_dest);
        }
        else
        {
            fprintf(stderr, "Type de fichier non supporte : %s\n", child);
            exit(EXIT_FAILURE);
        }
    }
    if (errno != 0)
        raler("readdir");
    CHK(closedir(dir));
    
}


int
main (int argc, char *argv[])
{
    if (argc!=3)
    {
        fprintf(stderr, "Usage : %s repertoire_source repertoire_destination\n", argv[0]);
        exit(EXIT_FAILURE);
    }
   
    copieArbo(argv[1], argv[2]);

    return 0;
}
