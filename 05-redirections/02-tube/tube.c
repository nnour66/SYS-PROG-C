    #include <fcntl.h>
    #include <stdio.h>
    #include <stdlib.h>
    #include <stdnoreturn.h>
    #include <sys/wait.h>
    #include <unistd.h>

    #define CHK(op)                                                                \
        do {                                                                       \
            if ((op) == -1)                                                        \
                raler(#op);                                                        \
        } while (0)

    noreturn void
    raler(const char *msg)
    {
        perror(msg);
        exit(EXIT_FAILURE);
    }

    /* copie tout ce qui est lu sur fdin vers fdout */
    void
    copier(int fdin, int fdout)
    {
        char buff[1024];
        ssize_t nb_octets_read=0;
        while ((nb_octets_read=read(fdin, buff, sizeof(buff)))>0)
        {
            CHK(write(fdout, buff, nb_octets_read));
        }
        CHK(nb_octets_read);
    }


    int
    main(void)
    {
        int tube[2];
        int status;
        pid_t pid;

        CHK(pipe(tube));

        switch (pid = fork()) {
        case -1:
            raler("fork");

        case 0:
            /* fils : lit depuis le tube et écrit sur stdout */
            CHK(close(tube[1]));
            sleep(3);
            copier(tube[0], STDOUT_FILENO);
            CHK(close(tube[0]));
            exit(0);

        default:
            /* père : lit depuis stdin et écrit dans le tube */
            CHK(close(tube[0]));
            copier(STDIN_FILENO, tube[1]);
            CHK(close(tube[1]));
            CHK(wait(&status));

            if (!(WIFEXITED(status) && WEXITSTATUS(status) == 0))
                return EXIT_FAILURE;

            return 0;
        }
    }