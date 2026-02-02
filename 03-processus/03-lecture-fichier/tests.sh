#!/bin/bash

PROG="./lecture"
FILE="$PROG.c"

TMP=${TMP:=/tmp/test.$USER} # chemin des logs de test
umask 0077		    # permissions des fichiers temporaires

######################################

# Tests

######################################

test_01() {
    echo -n "test 01 - fork() error handling: "

    ! grep -q "case -1:" "$FILE" && {
        echo "[FAIL] -> no handling of fork() failure (-1 case) found in source"
        return 1
    }

    echo ".............[PASS]"
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

    $PROG 0 1 > /dev/null 2> "$TMP.err"  && {
        echo "[FAIL] -> expected non-zero exit status when called with more than 1 argument"
        return 1
    }

    ! [ -s "$TMP.err" ] && {
        echo "[FAIL] -> expected error message on stderr when called with more than 1 argument"
        return 1
    }

    $PROG "$TMP.abcd" > /dev/null 2> "$TMP.err"  && {
        echo "[FAIL] -> expected non-zero exit status when file not found"
        return 1
    }

    ! [ -s "$TMP.err" ] && {
        echo "[FAIL] -> expected error message on stderr when file not found"
        return 1
    }

    echo "[PASS]"
}

test_03() {
    echo -n "test 03 - program creates child process: "

    LC_ALL=C tr -dc "A-Za-z0-9\n" < /dev/urandom | head -c 1024000 > "$TMP.in"

    $PROG "$TMP.in" > "$TMP.out" 2> "$TMP.err" &
    local pid=$!
    sleep 1

    pgrep -P "$pid" | sort -d > "$TMP.children"
    local nb=$(cat "$TMP.children" | wc -l)

    [ "$nb" -ne "1" ] && {
	echo "[FAIL] -> expected 1 child process, but $nb child processes created"
	return 1
    }

    # attendre la fin du processus parent
    ! wait "$pid" > /dev/null 2>&1 && {
        echo "[FAIL] -> expected exit status 0, or AddressSanitizer detected memory errors, see $TMP.err"
        return 1
    }

    rm -f "$TMP".*
    echo ".....[PASS]"
}

test_04() {
    echo -n "test 04 - program output: "

    LC_ALL=C tr -dc "A-Za-z0-9\n" < /dev/urandom | head -c 1024000 > "$TMP.in"

    ! $PROG "$TMP.in" > "$TMP.out" 2> "$TMP.err" && {
        echo "[FAIL] -> expected exit status 0, or AddressSanitizer detected memory errors, see $TMP.err"
        return 1
    }
    
    local nc=$(cat "$TMP.out" | wc -c)

    [ "$nc" -ne "1024000" ] && {
	echo "[FAIL] -> check files \"$TMP.out\" (yours) \"$TMP.in\" (expected)"
	return 1
    }

    rm -f "$TMP".*
    echo "....................[PASS]"
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
    for t in 1 2 3 4; do
        run_test "$t" || exit 1
    done
else
    # Tests demandés
    for t in "$@"; do
        run_test "$t" || exit 1
    done
fi

rm -rf $TMP.*
