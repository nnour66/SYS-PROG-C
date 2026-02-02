#!/bin/bash

PROG="./copie-arbo"

TMP=${TMP:=/tmp/test.$USER} # chemin des logs de test
umask 0077		    # permissions des fichiers temporaires

ASAN_OPTIONS=detect_leaks=1

######################################

# Tests

######################################

test_01() {
    echo -n "test 01 - error handling (invalid arguments): "

    mkdir $TMP.source

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
        echo "[FAIL] -> expected non-zero exit status when src directory does not exist"
        return 1
    }

    ! [ -s "$TMP.err" ] && {
        echo "[FAIL] -> expected error message on stderr when src directory does not exist"
        return 1
    }

    $PROG $TMP.src $TMP.src > /dev/null 2> "$TMP.err"  && {
        echo "[FAIL] -> expected non-zero exit status when dst directory already exists"
        return 1
    }

    ! [ -s "$TMP.err" ] && {
        echo "[FAIL] -> expected error message on stderr when dst directory already exists"
        return 1
    }

    echo ".[PASS]"
}

test_02() {
    echo -n "test 02 - recursive directory copy: "

    mkdir -p "$TMP.dir/source/1/2"
    head -c 102400 /dev/urandom > "$TMP.dir/source/toto"
    head -c 500    /dev/urandom > "$TMP.dir/source/1/titi"
    head -c 2050   /dev/urandom > "$TMP.dir/source/1/2/tata"

    ! $PROG "$TMP.dir/source" "$TMP.dir/cpy" > /dev/null 2> "$TMP.err" && {
        echo "[FAIL] -> expected exit status 0, or AddressSanitizer detected memory errors, see $TMP.err"
        return 1
    }

    ! diff -qr "$TMP.dir/source" "$TMP.dir/cpy" &> /dev/null && {
        echo "[FAIL] -> recursive copy differs from source (see: diff -qr $TMP.dir/source $TMP.dir/cpy)"
        return 1
    }

    rm -r $TMP.dir
    echo "...........[PASS]"
}

test_03() {
    echo -n "test 03 - fail on symlink in source directory: "

    mkdir -p "$TMP.dir/source"
    touch "$TMP.dir/source/toto" ; ln -s "$TMP.dir/source/toto" "$TMP.dir/source/link"

    $PROG "$TMP.dir/source" "$TMP.dir/cpy" > /dev/null 2> "$TMP.err" && {
        echo "[FAIL] -> expected non-zero exit status"
        return 1
    }

    ! [ -s "$TMP.err" ] && {
        echo "[FAIL] -> expected error message on stderr when source contains symlink"
        return 1
    }

    rm -r "$TMP.dir"
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
