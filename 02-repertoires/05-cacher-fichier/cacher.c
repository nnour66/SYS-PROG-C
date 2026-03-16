#include <dirent.h>
#include <errno.h>
#include <fcntl.h>
#include <limits.h>
#include <stdarg.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdnoreturn.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>
#define NAME_MAX 255

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

static int
lire_nom_unique_sous_repertoire(const char *dirname, char *name, size_t size)
{
    DIR *dir = opendir(dirname);
    if (dir == NULL)
        raler(dirname);

    struct dirent *ent;
    int trouve = 0;

    errno = 0;
    while ((ent = readdir(dir)) != NULL) {
        if (strcmp(ent->d_name, ".") == 0 || strcmp(ent->d_name, "..") == 0)
            continue;

        if (trouve) {
            fprintf(stderr, "plus d'un sous-repertoire dans %s\n", dirname);
            closedir(dir);
            exit(EXIT_FAILURE);
        }

        size_t len = strlen(ent->d_name);
        if (len + 1 > size) {
            fprintf(stderr, "nom de repertoire trop long\n");
            closedir(dir);
            exit(EXIT_FAILURE);
        }

        strcpy(name, ent->d_name);
        trouve = 1;
    }

    if (errno != 0) {
        closedir(dir);
        raler("readdir");
    }

    CHK(closedir(dir));
    return trouve; 
}

void
encoder(const char *source)
{
    int fd = open(source, O_RDONLY);
    if (fd == -1)
        raler(source);

    char root[PATH_MAX];
    concatener(root, PATH_MAX, "%s.d", source);
    CHK(mkdir(root, 0700));

    char buf[NAME_MAX + 1];
    ssize_t nread;
    int index = 0;

    while ((nread = read(fd, buf, NAME_MAX)) > 0) {
        buf[nread] = '\0';

        char level0[PATH_MAX];
        concatener(level0, PATH_MAX, "%s/%d", root, index);
        CHK(mkdir(level0, 0700));

        char current[PATH_MAX];
        concatener(current, PATH_MAX, "%s/%s", level0, buf);
        CHK(mkdir(current, 0700));

        for (int depth = 1; depth < 3; depth++) {
            nread = read(fd, buf, NAME_MAX);
            if (nread == -1)
                raler("read");
            if (nread == 0)
                break;

            buf[nread] = '\0';

            char next[PATH_MAX];
            concatener(next, PATH_MAX, "%s/%s", current, buf);
            CHK(mkdir(next, 0700));
            strcpy(current, next);
        }

        index++;
    }

    CHK(nread);

    CHK(close(fd));
}   

void
decoder(const char *dirname, const char *filename)
{
    DIR *root = opendir(dirname);
    if (root == NULL)
        raler(dirname);
    CHK(closedir(root));

    int fd = open(filename, O_WRONLY | O_CREAT | O_TRUNC, 0600);
    if (fd == -1)
        raler(filename);

    for (int index = 0;; index++) {
        char level0[PATH_MAX];
        concatener(level0, PATH_MAX, "%s/%d", dirname, index);

        DIR *test = opendir(level0);
        if (test == NULL) {
            if (errno == ENOENT)
                break;
            raler(level0);
        }
        CHK(closedir(test));

        char current[PATH_MAX];
        strcpy(current, level0);

        for (;;) {
            char child[NAME_MAX + 1];

            if (!lire_nom_unique_sous_repertoire(current, child, sizeof(child)))
                break;

            CHK(write(fd, child, strlen(child)));

            char next[PATH_MAX];
            concatener(next, PATH_MAX, "%s/%s", current, child);
            strcpy(current, next);
        }
    }

    CHK(close(fd));
}

int
main(int argc, char *argv[])
{
    if (argc != 3 && argc != 4) {
        fprintf(stderr, "usage: %s {-c filename | -x dirname output}", argv[0]);
        exit(EXIT_FAILURE);
    }

    if (strcmp(argv[1], "-c") == 0)
        encoder(argv[2]);
    else if (strcmp(argv[1], "-x") == 0)
        decoder(argv[2], argv[3]);
    else {
        fprintf(stderr, "bad option, usage: %s {-c | -x} filename\n", argv[0]);
        exit(EXIT_FAILURE);
    }

    return 0;
}