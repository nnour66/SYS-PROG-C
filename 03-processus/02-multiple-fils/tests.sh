#!/bin/bash

PROG="./nfils"
FILE="$PROG.c"

TMP=${TMP:=/tmp/test.$USER} # chemin des logs de test
umask 0077		    # permissions des fichiers temporaires

ASAN_OPTIONS=detect_leaks=1

######################################

# Tests

######################################

test_01() {
    echo -n "test 01 - fork() error handling: "

    ! cat "$FILE" | tr -d ' ' | grep -q "case-1:" && {
        echo "[FAIL] -> no handling of fork() failure (-1 case) found in source"
        return 1
    }

    echo "...................[PASS]"
}

test_02() {
    echo -n "test 02 - error handling (invalid arguments): "

    $PROG > /dev/null 2> "$TMP.err" && {
        echo "[FAIL] -> expected non-zero exit status when called without arguments"
        return 1
    }

    ! [ -s "$TMP.err" ] && {
        echo "[FAIL] -> expected error message on stderr when called without arguments"
        return 1
    }

    $PROG 1 2 > /dev/null 2> "$TMP.err"  && {
        echo "[FAIL] -> expected non-zero exit status when called with more than one argument"
        return 1
    }

    ! [ -s "$TMP.err" ] && {
        echo "[FAIL] -> expected error message on stderr when called with more than one argument"
        return 1
    }

    $PROG 0 > /dev/null 2> "$TMP.err"  && {
        echo "[FAIL] -> expected non-zero exit status when n < 1"
        return 1
    }

    ! [ -s "$TMP.err" ] && {
        echo "[FAIL] -> expected error message on stderr when n < 1"
        return 1
    }

    $PROG 10 > /dev/null 2> "$TMP.err"  && {
        echo "[FAIL] -> expected non-zero exit status when n > 9"
        return 1
    }

    ! [ -s "$TMP.err" ] && {
        echo "[FAIL] -> expected error message on stderr when n > 9"
        return 1
    }

    echo "......[PASS]"
}

test_03() {
    echo -n "test 03 - program spawns exactly N child processes: "

    local np=$(( RANDOM % 9 + 1))

    ! grep "sleep(2)" "$FILE" > /dev/null && {
        echo "[FAIL] -> child should call sleep(2) before exiting"
        return 1
    }
    
    $PROG "$np" > "$TMP.out" 2> "$TMP.err" &
    local pid=$!
    sleep 1

    ps -o pid= -o ppid= | grep " $pid$" | tr -s ' ' | cut -d ' ' -f2 | sort -d > "$TMP.children"
    local nb=$(cat "$TMP.children" | wc -l)

    [ "$nb" -ne "$np" ] && {
        echo "[FAIL] -> $nb child processes found, $np expected"
        return 1
    }

    # attendre la fin du processus parent
    ! wait "$pid" > /dev/null 2>&1 && {
        echo "[FAIL] -> expected exit status 0, or AddressSanitizer detected memory errors, see $TMP.err"
        return 1
    }

    echo "[PASS]"
}

test_04() {
    echo -n "test 04 - printed PIDs and exit status: "

    local np=$(( RANDOM % 9 + 1))

    ! grep "sleep(2)" "$FILE" > /dev/null && {
        echo "[FAIL] -> child should call sleep(2) before exiting"
        return 1
    }

    $PROG "$np" > "$TMP.out" 2> "$TMP.err" &
    local pid=$!
    sleep 1

    pgrep -P "$pid" | sort -d > "$TMP.children"

    # attendre la fin du processus parent
    ! wait "$pid" > /dev/null 2>&1 && {
        echo "[FAIL] -> expected exit status 0, or AddressSanitizer detected memory errors, see $TMP.err"
        return 1
    }

    cat "$TMP.out" | cut -d ' ' -f1 | sort -d > "$TMP.pids"

    ! cmp -s "$TMP.pids" "$TMP.children" && {
        echo "[FAIL] -> output differs from what expected"
        return 1
    }

    echo "............[PASS]"
}


test_05() {
    echo -n "test 05 - program prints pid_t correctly: "

    ! grep -q "%jd" "$FILE" && {
        echo "[FAIL] -> missing use of %jd to print pid_t"
        return 1
    }

    ! grep -q "intmax_t" "$FILE" && {
        echo "[FAIL] -> missing use of intmax_t to print pid_t"
        return 1
    }

    echo "..........[PASS]"
}

######################################

# Runner

######################################

run_test() {
    case "$1" in
        1) test_01 ;;
        2) test_02 ;;
        3) test_03 ;;
        4) test_04 ;;
	5) test_05 ;;
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
    for t in 1 2 3 4 5; do
        run_test "$t" || exit 1
    done
else
    # Tests demandés
    for t in "$@"; do
        run_test "$t" || exit 1
    done
fi

rm -rf "$TMP".*
