#include <asm-generic/errno-base.h>
#include <dirent.h>
#include <errno.h>
#include <limits.h>
#include <linux/limits.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdnoreturn.h>
#include <string.h>
#include <unistd.h>

#define MAX_ARG 5
#define INCREMENT_REALLOC 10

char **
separe(char *chaine, const char *separateurs)
{
    char **tab;
    int i, s, m, size = INCREMENT_REALLOC;

    tab = calloc(size, sizeof *tab);
    if (tab == NULL)
        return NULL;
    m = 0;
    i = 0;
    while (chaine[i] != 0) {
        for (s = 0 ; separateurs[s] != '\0' ; s++)
            if (chaine[i] == separateurs[s])
                break;
        if (separateurs[s] != '\0') {
            chaine[i++] = '\0';
            continue;
        }

        if (chaine[i] != 0)
            tab[m++] = chaine + i;
        if (m == size) {
            size += INCREMENT_REALLOC;
            tab = realloc(tab, size * sizeof *tab);
            if (tab == NULL)
                return NULL;
        }
        for ( ; chaine[i] != '\0' ; i++) {
            for (s = 0 ; separateurs[s] != '\0' ; s++)
                if (chaine[i] == separateurs[s])
                    break;
            if (separateurs[s] != '\0')
                break;
        }
    }
    tab[m] = NULL;
    return tab;
}

int
myexeclp(const char *file, const char *premier_arg, ...)
{
    char * chemin      = getenv("PATH");
    if (chemin == NULL) {
        errno = ENOENT;
        return -1;
    }

    char * chemin_copy = strdup(chemin);
    if ( chemin_copy == NULL){
        errno = ENOMEM;
        return -1;
    }

    char ** repertoire = separe(chemin_copy, ":");
    int idx = 0;
    DIR * dossier;
    struct dirent * entree;

    va_list ap;
    va_start(ap, premier_arg);
    int j = 0;
    char *args[MAX_ARG + 2];
    args[j++] = (char *)premier_arg;
    char *tmp;

    while ((tmp = va_arg(ap, char *)) != NULL) {
        if (j >= MAX_ARG + 1) {
            errno = E2BIG;
            va_end(ap);
            free(chemin_copy);
            free(repertoire);
            return -1;
        }
        args[j++] = tmp;
    }
    args[j] = NULL;
    va_end(ap);

    char fullpath[PATH_MAX];

    while ( repertoire[idx] != NULL ) {
    
        dossier = opendir(repertoire[idx]);
        if ( dossier == NULL){
            if (errno == ENOTDIR) {
                free(chemin_copy);
                free(repertoire);
                return -1;            
            }
            idx +=1;
            continue;
        }
        while ( (entree = readdir(dossier)) != NULL) {
            if ( strcmp(entree->d_name, file) == 0) 
            {
                snprintf(fullpath, sizeof(fullpath), "%s/%s", repertoire[idx], file);
                if (access(fullpath, X_OK) != 0) {
                    errno = EACCES;
                    free(chemin_copy);
                    free(repertoire);
                    return -1;
                }
                execve( fullpath, args, NULL);
                free(chemin_copy);
                free(repertoire);
                return -1;
            }
        }

        closedir(dossier);
        idx  += 1;
    }

    free(chemin_copy);
    free(repertoire);
    errno = ENOENT;
    return -1;
}

int
main(int nb_args, char *tab_args[])
{
    if (nb_args < 2) {
        fprintf(stderr, "usage: %s fichier ...\n", tab_args[0]);
        exit(EXIT_FAILURE);
    }

    switch (nb_args) {
    case 2:
        myexeclp(tab_args[1], tab_args[1], NULL);
        break;

    case 3:
        myexeclp(tab_args[1], tab_args[1], tab_args[2], NULL);
        break;

    case 4:
        myexeclp(tab_args[1], tab_args[1], tab_args[2], tab_args[3], NULL);
        break;

    case 5:
        myexeclp(tab_args[1], tab_args[1], tab_args[2], tab_args[3], tab_args[4], NULL);
        break;

    case 6:
        myexeclp(tab_args[1], tab_args[1], tab_args[2], tab_args[3], tab_args[4], tab_args[5],
                 NULL);
        break;

    case 7:
        myexeclp(tab_args[1], tab_args[1], tab_args[2], tab_args[3], tab_args[4], tab_args[5],
                 tab_args[6], NULL);
        break;

    case 8:
        myexeclp(tab_args[1], tab_args[1], tab_args[2], tab_args[3], tab_args[4], tab_args[5],
                 tab_args[6], tab_args[7], NULL);
        break;
    }

    perror("myexeclp");
    return EXIT_FAILURE;
}

