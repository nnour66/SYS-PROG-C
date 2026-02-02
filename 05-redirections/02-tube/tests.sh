#!/bin/bash

PROG="./tube"
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

    echo "........[PASS]"
}

test_02() {
    echo -n "test 02 - program creates child process: "

    ! grep "sleep" $FILE > /dev/null && {
        echo "[FAIL] -> child should call sleep (1) before using pipe"
        return 1
    }

    $PROG < /bin/ls > "$TMP.out" 2> "$TMP.err" &
    local pid="$!"

    sleep 1

    local child=$(pgrep -P "$pid")
    [ -z "$child" ] && {
        echo "[FAIL] -> no child process"
        return 1
    }

    ! wait "$pid" > /dev/null 2>&1 && {
        echo "[FAIL] -> expected exit status 0, or AddressSanitizer detected memory errors, see $TMP.err"
        return 1
    }

    echo "[PASS]"
}

test_03() {
    echo -n "test 03 - program output: "

    ! $PROG < /bin/ls > "$TMP.out" 2> "$TMP.err" && {
        echo "[FAIL] -> expected exit status 0, or AddressSanitizer detected memory errors, see $TMP.err"
        return 1
    }

    ! cmp -s /bin/ls "$TMP.out" && {
        echo "[FAIL] -> output differs from source file"
        return 1
    }

    echo "...............[PASS]"
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
