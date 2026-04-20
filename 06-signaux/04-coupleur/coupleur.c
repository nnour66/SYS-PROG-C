#include <errno.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdnoreturn.h>
#include <sys/wait.h>
#include <unistd.h>

#define CHK(op) do { if ((op) == -1) raler(#op); } while (0)

noreturn void raler(const char *msg) {
    perror(msg);
    exit(EXIT_FAILURE);
}


volatile sig_atomic_t signal_recu = 0;

void handlerSIG(int sig) {
    signal_recu = sig;
}

noreturn void fils(){

    int octet_recu = 0;
    sigset_t mask_user;
    CHK(sigemptyset(&mask_user));
    CHK(sigaddset(&mask_user, SIGUSR1));
    CHK(sigaddset(&mask_user, SIGUSR2));
    CHK(sigprocmask(SIG_BLOCK, &mask_user, NULL));

    sigset_t mask_empty;
    CHK(sigemptyset(&mask_empty));

    struct sigaction sa;
    sa.sa_handler = handlerSIG;
    sa.sa_flags = 0;
    sigemptyset(&sa.sa_mask);
    
    CHK(sigaction(SIGUSR1, &sa, NULL));
    CHK(sigaction(SIGUSR2, &sa, NULL));

    CHK(sigprocmask(SIG_UNBLOCK, &mask_user, NULL));

    
    for (int i = 0; i < 8; i++) 
    {
        CHK(sigprocmask(SIG_BLOCK, &mask_user, NULL));
        
        if ( signal_recu == 0 ) 
            sigsuspend(&mask_empty);

        int bit = (signal_recu == SIGUSR2) ? 1 : 0;
        octet_recu = (octet_recu << 1) | bit;
        signal_recu = 0;

        CHK(sigprocmask(SIG_UNBLOCK, &mask_user, NULL));
        CHK(kill(getppid(), SIGUSR1));
    }

    printf("%d\n", octet_recu);
    sleep(2);

    exit(EXIT_SUCCESS);
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s N\n", argv[0]);
        exit(EXIT_FAILURE);
    }

    int n = atoi(argv[1]);
    if (n < 0 || n > 255) {
        fprintf(stderr, "N doit etre compris entre 0 et 255\n");
        exit(EXIT_FAILURE);
    }

    sigset_t mask_empty;    
    CHK(sigemptyset(&mask_empty));

    sigset_t mask_user;
    CHK(sigemptyset(&mask_user));
    CHK(sigaddset(&mask_user, SIGUSR1));
    CHK(sigaddset(&mask_user, SIGUSR2));
    CHK(sigprocmask(SIG_BLOCK, &mask_user, NULL));

    pid_t pid_enfant;
    int bit_a_envoyer;

    switch (pid_enfant = fork() ) {
    case -1:
        raler("fork");

    case 0:
        fils();
    }
    struct sigaction sa;
    sa.sa_handler = handlerSIG;
    sa.sa_flags = 0;
    sigemptyset(&sa.sa_mask);
    
    CHK(sigaction(SIGUSR1, &sa, NULL));
    CHK(sigaction(SIGUSR2, &sa, NULL));
    
    CHK(sigprocmask(SIG_UNBLOCK, &mask_user, NULL));


    for (int i = 7; i >= 0; i--) 
    {
        bit_a_envoyer = (n >> i) & 1;   
        CHK(kill(pid_enfant, bit_a_envoyer ? SIGUSR2 : SIGUSR1));

        CHK(sigprocmask(SIG_BLOCK, &mask_user, NULL));
        if ( signal_recu == 0 ) 
            sigsuspend(&mask_empty);
        signal_recu = 0;  
        CHK(sigprocmask(SIG_UNBLOCK, &mask_user, NULL));   
        
    }
    int status;
    CHK(wait(&status));
    if ( !WIFEXITED(status) || WEXITSTATUS(status) != EXIT_SUCCESS )
        return EXIT_FAILURE;

    return EXIT_SUCCESS;

}