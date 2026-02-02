#!/bin/bash

PROG="./creer-fils"
FILE="$PROG.c"

TMP=${TMP:=/tmp/test.$USER} # chemin des logs de test
umask 0077		    # permissions des fichiers temporaires

ASAN_OPTIONS=detect_leaks=1

######################################

# Tests

######################################

test_01() {
    echo -n "test 01 - fork() error handling: "

    ! grep -q "case -1:" "$FILE" && {
        echo "[FAIL] -> no handling of fork() failure (-1 case) found in source"
        return 1
    }

    echo "...........................[PASS]"
}

test_02() {
    echo -n "test 02 - program prints child PID and computed exit value: "

    ! grep "sleep(2)" "$FILE" > /dev/null && {
	echo "[FAIL] -> child should call sleep(2) before exiting"
	return 1
    }
    
    # lancer le programme en arrière-plan
    "$PROG" > "$TMP.out" 2> "$TMP.err" &
    local pid=$!
    sleep 1  # attendre que l'enfant soit créé

    # récupérer le PID de l'enfant
    local child=$(ps --no-headers -o pid --ppid "$pid" | tr -d ' ')
    [ -z "$child" ] && {
        echo "[FAIL] -> no child process created by program"
        return 1
    }

    # calcul de la valeur de sortie attendue
    local exit_value=$(($child % 10))
    printf "%s %s %s\n" "$pid" "$child" "$exit_value" > "$TMP.expected"

    # attendre la fin du processus parent
    ! wait "$pid" > /dev/null 2>&1 && {
        echo "[FAIL] -> expected exit status 0, or AddressSanitizer detected memory errors, see $TMP.err"
        return 1
    }

    ! cmp -s "$TMP.out" "$TMP.expected" && {
        echo "[FAIL] -> output differs from expected"
        return 1
    }

    rm -f "$TMP".*
    echo "[PASS]"
}

test_03() {
    echo -n "test 03 - program prints pid_t using intmax_t and %jd: "

    ! grep -q "%jd" "$FILE" && {
        echo "[FAIL] -> missing use of %jd to print pid_t"
        return 1
    }

    ! grep -q "intmax_t" "$FILE" && {
        echo "[FAIL] -> missing use of intmax_t to print pid_t"
        return 1
    }

    echo ".....[PASS]"
}

######################################

# Runner

######################################

run_test() {
    case "$1" in
        1) test_01 ;;
        2) test_02 ;;
        3) test_03 ;;
        *)
            echo "Unknown test: $1"
            exit 2
            ;;
    esac
}

######################################

# Main

######################################

if [ "$#" -eq 0 ]; then
    # Aucun argument → tous les tests
    for t in 1 2 3; do
        run_test "$t" || exit 1
    done
else
    # Tests demandés
    for t in "$@"; do
        run_test "$t" || exit 1
    done
fi

rm -rf "$TMP".*
