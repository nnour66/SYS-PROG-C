#!/bin/bash

PROG="./moncat"
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

    $PROG "$TMP.abcd" > /dev/null 2> "$TMP.err" && {
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

    echo "abcdefgh" > "$TMP.in"
    ! $PROG "$TMP.in" > "$TMP.out" 2> "$TMP.err" && {
        echo "[FAIL] -> expected exit status 0, or AddressSanitizer detected memory errors, see $TMP.err"
        return 1
    }

    echo "...........[PASS]"
}

test_04() {
    echo -n "test 04 - file content written to stdout: "

    echo "abcdefgh" > "$TMP.in"

    ! $PROG "$TMP.in" > "$TMP.out" 2> "$TMP.err" && {
        echo "[FAIL] -> expected exit status 0, or AddressSanitizer detected memory errors, see $TMP.err"
        return 1
    }

    ! [ -s "$TMP.out" ] && {
        echo "[FAIL] -> expected file content on stdout"
        return 1
    }

    echo "..............[PASS]"
}

test_05() {
    echo -n "test 05 - output identical to input file (binary-safe): "

    head -c 4096900 /dev/urandom > "$TMP.in"

    ! $PROG "$TMP.in" > "$TMP.out" 2> "$TMP.err" && {
        echo "[FAIL] -> expected exit status 0, or AddressSanitizer detected memory errors, see $TMP.err"
        return 1
    }

    ! cmp -s "$TMP.in" "$TMP.out" && {
        echo "[FAIL] -> output differs from input file (check binary handling)"
        return 1
    }

    echo "[PASS]"
}

test_06() {
    echo -n "test 06 - efficient block-based reading: "

    head -c 4096900 /dev/urandom > "$TMP.in"
    local t0=$(date +%s)

    ! $PROG "$TMP.in" > "$TMP.out" 2> "$TMP.err" && {
        echo "[FAIL] -> expected exit status 0, or AddressSanitizer detected memory errors, see $TMP.err"
        return 1
    }

    local t1=`date +%s`
    local runtime=$(($t1 - $t0))

    [ "$runtime" -gt "1" ] && {
        echo "[FAIL] -> execution time exceeds 1s (are you reading byte-by-byte?)"
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
