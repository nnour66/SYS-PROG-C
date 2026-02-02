#!/bin/bash

PROG="./monls"
FILE="$PROG.c"

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

    $PROG $TMP.abcd > /dev/null 2> "$TMP.err"  && {
        echo "[FAIL] -> expected non-zero exit status when directory does not exist"
        return 1
    }

    ! [ -s "$TMP.err" ] && {
        echo "[FAIL] -> expected error message on stderr when directory does not exist"
        return 1
    }

    echo "[PASS]"
}

test_02() {
    echo -n "test 02 - normal execution on existing dir: "
    
    mkdir -p "$TMP.in.d"

    ! $PROG "$TMP.in.d" > /dev/null 2> "$TMP.err" && {
        echo "[FAIL] -> expected exit status 0, or AddressSanitizer detected memory errors, see $TMP.err"
        return 1
    }

    echo "..[PASS]"
}

test_03() {
    echo -n "test 04 - list existing directory: "

    mkdir -p "$TMP.dir" ; touch "$TMP.dir/toto" ; touch "$TMP.dir/tata"
    ls "$TMP.dir" | sort -d > "$TMP.expected"

    ! $PROG "$TMP.dir" | sort -d > "$TMP.out" 2> "$TMP.err" && {
        echo "[FAIL] -> expected exit status 0, or AddressSanitizer detected memory errors, see $TMP.err"
        return 1
    }
    
    ! cmp -s "$TMP.out" "$TMP.expected" && {
        echo "[FAIL] -> output differs from reference listing"
        return 1
    }

    echo "...........[PASS]"
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
