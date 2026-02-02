#!/bin/bash

PROG="./liste-rep"

TMP=${TMP:=/tmp/test.$USER} # chemin des logs de test
umask 0077		    # permissions des fichiers temporaires

ASAN_OPTIONS=detect_leaks=1

######################################

# Tests

######################################

test_01() {
    echo -n "test 01 - error handling (invalid arguments): "

    $PROG > /dev/null 2> "$TMP.err" && {
        echo "[FAIL] -> expected non-zero exit status when called without arguments"
        return 1
    }

    ! [ -s "$TMP.err" ] && {
        echo "[FAIL] -> expected error message on stderr when called without arguments"
        return 1
    }

    $PROG 1 > /dev/null 2> "$TMP.err"  && {
        echo "[FAIL] -> expected non-zero exit status when called with one argument"
        return 1
    }

    ! [ -s "$TMP.err" ] && {
        echo "[FAIL] -> expected error message on stderr when called with one argument"
        return 1
    }

    $PROG 1 2 3 > /dev/null 2> "$TMP.err"  && {
        echo "[FAIL] -> expected non-zero exit status when called with more than 2 arguments"
        return 1
    }

    ! [ -s "$TMP.err" ] && {
        echo "[FAIL] -> expected error message on stderr when called with more than 2 arguments"
        return 1
    }

    $PROG "$TMP.abcd" 1 > /dev/null 2> "$TMP.err"  && {
        echo "[FAIL] -> expected non-zero exit status when directory does not exist"
        return 1
    }

    ! [ -s "$TMP.err" ] && {
        echo "[FAIL] -> expected error message on stderr when directory does not exist"
        return 1
    }

    $PROG /tmp 0 > /dev/null 2> "$TMP.err"  && {
        echo "[FAIL] -> expected non-zero exit status when depth < 1"
        return 1
    }

    ! [ -s "$TMP.err" ] && {
        echo "[FAIL] -> expected error message on stderr when depth < 1"
        return 1
    }

    $PROG /tmp 10 > /dev/null 2> "$TMP.err"  && {
        echo "[FAIL] -> expected non-zero exit status when depth > 9"
        return 1
    }

    ! [ -s "$TMP.err" ] && {
        echo "[FAIL] -> expected error message on stderr when depth > 9"
        return 1
    }
    
    echo "..[PASS]"
}

test_02() {
    echo -n "test 02 - list existing directory: "

    find /tmp -maxdepth 1 -type d > "$TMP.expected"

    ! $PROG /tmp 1 > "$TMP.out" 2> "$TMP.err" && {
        echo "[FAIL] -> expected exit status 0, or AddressSanitizer detected memory errors, see $TMP.err"
        return 1
    }

    ! cmp -s "$TMP.out" "$TMP.expected" && {
        echo "[FAIL] -> output differs from reference listing"
        return 1
    }

    echo ".............[PASS]"
}

test_03() {
    echo -n "test 03 - list existing directory with depth 5: "

    mkdir -p "$TMP.dir/1/2/3/4/5" ; mkdir -p "$TMP.dir/1bis/2bis/3bis" ; touch "$TMP.dir/1bis/2bis/toto"

    find "$TMP.dir" -maxdepth 5 -type d > "$TMP.expected"

    ! $PROG "$TMP.dir" 5 > "$TMP.out" 2> "$TMP.err" && {
        echo "[FAIL] -> expected exit status 0, or AddressSanitizer detected memory errors, see $TMP.err"
        return 1
    }

    ! cmp -s "$TMP.out" "$TMP.expected" && {
        echo "[FAIL] -> output differs from reference listing"
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
