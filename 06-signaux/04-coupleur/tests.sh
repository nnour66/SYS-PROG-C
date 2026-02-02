#!/bin/bash

PROG="./coupleur"
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

    ! grep "sigsuspend" "$FILE" > /dev/null 2>&1 && {
        echo "[FAIL] -> you should use POSIX signals API"
        return 1
    }

    echo ".......[PASS]"
}

test_02() {
    echo -n "test 02 - program usage: "

    $PROG > /dev/null 2> "$TMP.err" && {
        echo "[FAIL] -> expected non-zero exit status when called without argument"
        return 1
    }

    ! [ -s "$TMP.err" ] && {
        echo "[FAIL] -> expected error message on stderr when called without argument"
        return 1
    }

    $PROG -1 > /dev/null 2> "$TMP.err" && {
        echo "[FAIL] -> expected non-zero exit status when transmitted byte is < 0"
        return 1
    }

    ! [ -s "$TMP.err" ] && {
        echo "[FAIL] -> expected error message on stderr when transmitted byte is < 1"
        return 1
    }

    $PROG 256 > /dev/null 2> "$TMP.err" && {
        echo "[FAIL] -> expected non-zero exit status when transmitted byte is > 255"
        return 1
    }

    ! [ -s "$TMP.err" ] && {
        echo "[FAIL] -> expected error message on stderr when transmitted byte is > 255"
        return 1
    }

    echo "................[PASS]"
}

test_03() {
    echo -n "test 03 - fork() error handling: "

    ! grep -q "case -1:" "$FILE" && {
        echo "[FAIL] -> no handling of fork() failure (-1 case) found in source"
        return 1
    }

    echo "........[PASS]"
}

test_04() {
    echo -n "test 04 - program creates child process: "

    ! grep "sleep(2)" "$FILE" > /dev/null && {
	echo "[FAIL] -> child should call sleep(2) before using pipe"
	return 1
    }

    $PROG 32 > "$TMP.out" 2> "$TMP.err" &
    local pid="$!"

    sleep 1

    local nb=$(pgrep -P "$pid" | wc -l)
    [ -z "$nb" ] && {
        echo "[FAIL] -> no child process found"
        return 1
    }

    [ "$nb" -ne 1 ] && {
	echo "[FAIL] -> expected 1 child process, got $nb"
	return 1
    }

    ! wait "$pid" > /dev/null 2>&1 && {
        echo "[FAIL] -> expected zero exit status, or AddressSanitizer detected memory errors, see $TMP.err"
        return 1
    }

    echo "[PASS]"
}

test_05() {
    echo -n "test 05 - program output: "

    local val=$(( RANDOM % 256 ))

    ! $PROG "$val" > "$TMP.out" 2> "$TMP.err" && {
        echo "[FAIL] -> expected zero exit status, or AddressSanitizer detected memory errors, see $TMP.err"
        return 1
    }

    local nb=$(cat "$TMP.out")
    [ -z "$nb" ] && {
        echo "[FAIL] -> no output produced"
        return 1
    }

    # non-numeric output
    ! [[ "$nb" =~ ^-?[0-9]+$ ]] && {
	echo "[FAIL] -> non-numeric output: '$nb'"
	return 1
    }

    [ "$nb" -ne "$val" ] && {
        echo "[FAIL] -> expected output $val, got $nb"
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
        4) test_04 ;;
        5) test_05 ;;
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
