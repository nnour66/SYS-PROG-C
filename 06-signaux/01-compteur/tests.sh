#!/bin/bash

PROG="./compteur"
FILE="$PROG.c"

TMP=${TMP:=/tmp/test.$USER} # chemin des logs de test
umask 0077		    # permissions des fichiers temporaires

ASAN_OPTIONS=detect_leaks=1

######################################

# Tests

######################################

test_01() {
    echo -n "test 01 - program uses POSIX API: "

    ! grep "sigaction" "$FILE" > /dev/null 2>&1 && {
        echo "[FAIL] -> you should use POSIX signals API"
        return 1
    }

    echo "..........[PASS]"
}

test_02() {
    echo -n "test 02 - program completes after 5 SIGINT: "

    $PROG > /dev/null 2> "$TMP.err" &
    local pid="$!"

    sleep 0.5
    ! kill -0 "$pid" 2> /dev/null && {
        wait "$pid" > /dev/null 2>&1
        echo "[FAIL] => program exits before receiving 5 SIGINT, or AddressSanitizer detected memory errors, see $TMP.err"
        return 1
    }
    
    for i in {1..5}; do
        sleep 0.5
        kill -s SIGINT "$pid"
    done

    sleep 0.5 ; kill -s SIGTERM "$pid" 2> /dev/null

    ! wait $pid > /dev/null 2>&1 && {
        echo "[FAIL] -> program still running after 5 SIGINT"
        return 1
    }

    echo "[PASS]"
}

test_03() {
    echo -n "test 03 - program output: "

    cat <<EOF > "$TMP.expected"
compteur: 1
compteur: 2
compteur: 3
compteur: 4
compteur: 5
EOF

    $PROG > "$TMP.out" 2> "$TMP.err" &
    local pid="$!"

    sleep 0.5
    ! kill -0 "$pid" 2> /dev/null && {
        wait "$pid" > /dev/null 2>&1
        echo "[FAIL] => program exits before receiving 5 SIGINT, or AddressSanitizer detected memory errors, see $TMP.err"
        return 1
    }

    for i in {1..5}; do
        sleep 0.5
        kill -s SIGINT "$pid"
    done

    sleep 0.5 ; kill -s SIGTERM "$pid" 2> /dev/null

    ! wait $pid > /dev/null 2>&1 && {
        echo "[FAIL] -> program still running after 5 SIGINT"
        return 1
    }
    
    sleep 0.5
    ! cmp -s "$TMP.out" "$TMP.expected" && {
        echo "[FAIL] -> output differs from expected SIGINT handling"
        return 1
    }

    echo "..................[PASS]"
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
            exit 1
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
