#!/bin/bash

PROG="./trier"
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

    echo "........[PASS]"
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
        echo "[FAIL] -> expected non-zero exit status when array size < 1"
        return 1
    }

    ! [ -s "$TMP.err" ] && {
        echo "[FAIL] -> expected error message on stderr when array size < 1"
        return 1
    }

    echo ".................[PASS]"
}

test_03() {
    echo -n "test 03 - program output for small array: "

    ! $PROG 5 > "$TMP.out" 2> "$TMP.err" && {
        echo "[FAIL] -> expected 0 exit status, or AddressSanitizer detected memory errors, see $TMP.err"
        return 1
    }

    grep "working" "$TMP.out" > /dev/null && {
        echo "[FAIL] -> expected no « working » statement when array is small, see $TMP.out"
        return 1
    }

    sort -n "$TMP.out" > "$TMP.expected"
    ! cmp -s "$TMP.out" "$TMP.expected" && {
        echo "[FAIL] -> array not sorted, see $TMP.out"
        return 1
    }

    echo "[PASS]"
}

test_04() {
    echo -n "test 04 - program output for large array: "

    ! $PROG 40960 > "$TMP.out" 2> "$TMP.err" && {
        echo "[FAIL] -> expected 0 exit status, or AddressSanitizer detected memory errors, see $TMP.err"
        return 1
    }

    ! grep "working" "$TMP.out" > /dev/null && {
        echo "[FAIL] -> expected « working » statement when array is large, see $TMP.out"
        return 1
    }

    grep -v "working" "$TMP.out" > "$TMP.tmp" ; mv -f "$TMP.tmp" "$TMP.out"
    sort -n "$TMP.out" > "$TMP.expected"

    ! cmp -s "$TMP.out" "$TMP.expected" && {
        echo "[FAIL] -> array not sorted, see $TMP.out"
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
    for t in 1 2 3 4; do
        run_test "$t" || exit 1
    done
else
    # Tests demandés
    for t in "$@"; do
        run_test "$t" || exit 1
    done
fi

rm -rf "$TMP".*
