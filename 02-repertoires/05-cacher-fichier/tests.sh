#!/bin/bash

PROG="./cacher"

TMP=${TMP:=/tmp/test.$USER} # chemin des logs de test
umask 0077		    # permissions des fichiers temporaires

######################################

# Tests with option -c

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

    touch "$TMP.in"
    $PROG -a "$TMP.in" > /dev/null 2> "$TMP.err" && {
        echo "[FAIL] -> unknown option accepted"
        return 1
    }

    ! [ -s "$TMP.err" ] && {
        echo "[FAIL] -> expected error message on stderr when called with unknown option"
        return 1
    }
    
    $PROG -c "$TMP.abcd" > /dev/null 2> "$TMP.err"  && {
        echo "[FAIL] -> expected non-zero exit status when source file does not exist"
        return 1
    }

    ! [ -s "$TMP.err" ] && {
        echo "[FAIL] -> expected error message on stderr when source file does not exist"
        return 1
    }

    mkdir -p "$TMP.in.d"
    $PROG -c "$TMP.in" > /dev/null 2> "$TMP.err" && {
        echo "[FAIL] -> expected non-zero exit status when target directory already exists"
        return 1
    }

    ! [ -s "$TMP.err" ] && {
        echo "[FAIL] -> expected error message on stderr when target directory already exists"
        return 1
    }

    rm -rf "$TMP".*
    echo "......................[PASS]"
}

test_02() {
    echo -n "test 02 - program output with empty source file: "

    # source file exists and is empty
    : > "$TMP.in"

    ! $PROG -c "$TMP.in" > /dev/null 2> "$TMP.err" && {
        echo "[FAIL] -> expected exit status 0, or AddressSanitizer detected memory errors, see $TMP.err"
        return 1
    }

    ! [ -d "$TMP.in.d" ] && {
        echo "[FAIL] -> destination directory not created"
        return 1
    }

    # directory must be empty
    [ "$(ls -A "$TMP.in.d")" ] && {
        echo "[FAIL] -> destination directory not empty"
        return 1
    }

    rm -rf "$TMP".*
    echo "...................[PASS]"
}

test_03() {
    echo -n "test 03 - small input file produces expected output tree: "

    printf "abcdefgh" > "$TMP.in"

    ! $PROG -c "$TMP.in" > /dev/null 2> "$TMP.err" && {
        echo "[FAIL] -> expected exit status 0, or AddressSanitizer detected memory errors, see $TMP.err"
        return 1
    }

    ! [ -d "$TMP.in.d/0/abcdefgh" ] && {
        echo "[FAIL] -> expected directory \"$TMP.in.d/0/abcdefgh\" not found"
        return 1
    }

    rm -rf "$TMP".*
    echo "..........[PASS]"
}

test_04() {
    echo -n "test 04 - large input file is fully reconstructed from output tree: "

    # generate deterministic alphanumeric content
    LC_ALL=C tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 4093 > "$TMP.in"

    ! $PROG -c "$TMP.in" > /dev/null 2> "$TMP.err" && {
        echo "[FAIL] -> expected exit status 0, or AddressSanitizer detected memory errors, see $TMP.err"
        return 1
    }

    # rebuild output by concatenating directory names in order
    : > "$TMP.tmp"
    for i in $(seq 0 5); do
        ls -lR "$TMP.in.d/$i" | grep ^d | tr -s ' ' | cut -d ' ' -f9 >> "$TMP.tmp"
    done
    tr -d '\n' < "$TMP.tmp" > "$TMP.out"

    ! cmp -s "$TMP.in" "$TMP.out" && {
        echo "[FAIL] -> reconstructed data differs from input file"
        return 1
    }

    rm -rf "$TMP".*
    echo "[PASS]"
}

######################################

# Tests with option -x

######################################

test_05() {
    echo -n "test 05 - failure when directory argument does not exist: "

    $PROG -x "$TMP.abcd" "$TMP.out" > /dev/null 2> "$TMP.err" && {
        echo "[FAIL] -> expected non-zero exit status when directory does not exist"
        return 1
    }

    ! [ -s "$TMP.err" ] && {
        echo "[FAIL] -> expected error message on stderr when directory does not exist"
        return 1
    }

    echo "..........[PASS]"
}

test_06() {
    echo -n "test 06 - reconstruct small file from directory tree: "

    printf "abcdefgh" > "$TMP.in"
    mkdir -p "$TMP.in.d/0/abcdefgh"

    ! $PROG -x "$TMP.in.d" "$TMP.out" > /dev/null 2> "$TMP.err" && {
        echo "[FAIL] -> expected exit status 0, or AddressSanitizer detected memory errors, see $TMP.err"
        return 1
    }

    ! cmp -s "$TMP.in" "$TMP.out" && {
        echo "[FAIL] -> reconstructed file differs from expected content"
        return 1
    }

    rm -rf "$TMP".*
    echo "..............[PASS]"
}

test_07() {
    echo -n "test 07 - round-trip on large file (-c then -x): "

    LC_ALL=C tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 1000000 > "$TMP.in"

    ! $PROG -c "$TMP.in" > /dev/null 2> "$TMP.err" && {
        echo "[FAIL] -> compression (-c) failed with non-zero exit status, or AddressSanitizer detected memory errors, see $TMP.err"
        return 1
    }

    ! $PROG -x "$TMP.in.d" "$TMP.out" > /dev/null 2> "$TMP.err" && {
        echo "[FAIL] -> extraction (-x) failed with non-zero exit status, or AddressSanitizer detected memory errors, see $TMP.err"
        return 1
    }

    ! cmp -s "$TMP.in" "$TMP.out" && {
        echo "[FAIL] -> reconstructed file differs from original"
        return 1
    }

    rm -rf "$TMP".*
    echo "...................[PASS]"
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
        7) test_07 ;;
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
    for t in 1 2 3 4 5 6 7; do
        run_test "$t" || exit 1
    done
else
    # Tests demandés
    for t in "$@"; do
        run_test "$t" || exit 1
    done
fi

rm -rf "$TMP".*
