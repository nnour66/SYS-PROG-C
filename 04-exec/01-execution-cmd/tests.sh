#!/bin/bash

PROG="./execmd"

TMP=${TMP:=/tmp/test.$USER} # chemin des logs de test
umask 0077		    # permissions des fichiers temporaires

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

    $PROG abcd > /dev/null 2> "$TMP.err"  && {
        echo "[FAIL] -> expected non-zero exit status when cmd not found"
        return 1
    }

    ! [ -s "$TMP.err" ] && {
        echo "[FAIL] -> expected error message on stderr when cmd not found"
        return 1
    }

    echo "....[PASS]"
}

test_02() {
    echo -n "test 02 - program output matches ls on directory: "

    mkdir -p "$TMP.ls"
    touch "$TMP.ls/toto" "$TMP.ls/tata"

    # expected output
    ls "$TMP.ls" > "$TMP.expected"

    # program output
    ! $PROG ls "$TMP.ls" > "$TMP.out" 2> "$TMP.err" && {
        echo "[FAIL] -> exit status != 0 when running \"$PROG ls <dir>\""
        return 1
    }

    ! cmp -s "$TMP.expected" "$TMP.out" && {
        echo "[FAIL] -> output differs from legacy ls cmd, compare $TMP.expected and $TMP.out"
        return 1
    }

    rm -rf "$TMP.ls" "$TMP.expected" "$TMP.out" "$TMP.err"
    echo "[PASS]"
}

test_03() {
    echo -n "test 03 - program output matches echo: "

    local msg="hello world"

    # expected output
    echo "$msg" > "$TMP.expected"

    # program output
    ! $PROG echo "$msg" > "$TMP.out" 2> "$TMP.err" && {
        echo "[FAIL] -> exit status != 0 when running \"$PROG echo <string>\""
        return 1
    }

    ! cmp -s "$TMP.expected" "$TMP.out" && {
        echo "[FAIL] -> output differs from echo, compare $TMP.expected and $TMP.actual"
        return 1
    }

    rm -f "$TMP.expected" "$TMP.out" "$TMP.err"
    echo "...........[PASS]"
}

test_04() {
    echo -n "test 04 - no memory leaks (valgrind): "

    ! which valgrind > /dev/null 2>&1 && {
        echo "[FAIL] -> please install valgrind"
        exit 1
    }

    valgrind --leak-check=full --error-exitcode=100 \
             --log-file=$TMP.valgrind.log \
             $PROG echo "hello world" > /dev/null 2>&1

    [ "$?" == "100" ] && {
        echo "[FAIL] -> memory pb please check $TMP.valgrind.log"
        return 1
    }

    echo "............[PASS]"
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
