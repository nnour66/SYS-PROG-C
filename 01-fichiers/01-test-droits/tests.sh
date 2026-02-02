#!/bin/bash

PROG="./testr"
FILE="$PROG.c"

TMP=${TMP:=/tmp/test.$USER} # chemin des logs de test
umask 0077		    # permissions des fichiers temporaires

ASAN_OPTIONS=detect_leaks=1

######################################

# Tests

######################################

test_01() {
    echo -n "test 01 - no stdio functions (open/read/write only): "

    grep "fopen" "$FILE" && {
        echo "[FAIL] -> forbidden stdio call detected (use open/read/write, not fopen)"
        return 1
    }
    echo "...[PASS]"
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

    $PROG "$TMP.abcd" > /dev/null 2> "$TMP.err"  && {
        echo "[FAIL] -> expected non-zero exit status when file does not exist"
        return 1
    }

    ! [ -s "$TMP.err" ] && {
        echo "[FAIL] -> expected error message on stderr when file does not exist"
        return 1
    }

    echo "..........[PASS]"
}

test_03() {
    echo -n "test 03 - normal execution on existing file: "

    touch "$TMP.in"

    ! $PROG "$TMP.in" > "$TMP.out" 2> "$TMP.err" && {
        echo "[FAIL] -> expected zero exit status, or AddressSanitizer detected memory errors, see $TMP.err"
        return 1
    }

    echo "...........[PASS]"
}

test_04() {
    echo -n "test 04 - output written to stdout (not stderr): "

    touch "$TMP.in"

    ! $PROG "$TMP.in" > "$TMP.out" 2> "$TMP.err" && {
        echo "[FAIL] -> expected exit status 0, or AddressSanitizer detected memory errors, see $TMP.err"
        return 1
    }

    ! [ -s "$TMP.out" ] && {
        echo "[FAIL] -> expected output on stdout"
        return 1
    }

    echo ".......[PASS]"
}

test_05() {
    echo -n "test 05 - readable file permissions reported correctly: "

    touch "$TMP.in"
    chmod -w "$TMP.in"

    ! $PROG "$TMP.in" > "$TMP.out" 2> "$TMP.err" && {
        chmod +w $TMP.toto
        echo "[FAIL] -> expected exit status 0, or AddressSanitizer detected memory errors, see $TMP.err"
        return 1
    }

    chmod +w "$TMP.in"
    local msg=$(cat "$TMP.out")

    [ "$msg" != "$TMP.in: R-" ] && {
        echo "[FAIL] -> expected output format: '<filename>: R-'"
        return 1
    }

    echo "[PASS]"
}

test_06() {
    echo -n "test 06 - writable file permissions reported correctly: "

    touch "$TMP.in"
    chmod -r "$TMP.in"

    ! $PROG "$TMP.in" > "$TMP.out" 2> "$TMP.err" && {
        chmod +r "$TMP.in"
        echo "[FAIL] -> expected exit status 0, or AddressSanitizer detected memory errors, see $TMP.err"
        return 1
    }

    chmod +r "$TMP.in"
    local msg=$(cat "$TMP.out")

    [ "$msg" != "$TMP.in: -W" ] && {
        echo "[FAIL] -> expected output format: '<filename>: -W'"
        return 1
    }

    echo "[PASS]"
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
        6) test_06 ;;
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
    for t in 1 2 3 4 5 6; do
        run_test "$t" || exit 1
    done
else
    # Tests demandés
    for t in "$@"; do
        run_test "$t" || exit 1
    done
fi

rm -f "$TMP".*
