#!/bin/bash

PROG="./presence"
FILE="$PROG.c"

TMP=${TMP:=/tmp/test.$USER} # chemin des logs de test
umask 0077		    # permissions des fichiers temporaires

ASAN_OPTIONS=detect_leaks=1

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
	echo "[FAIL] -> expected non-zero exit status when called without argument"
	return 1
    }

    ! [ -s "$TMP.err" ] && {
        echo "[FAIL] -> expected error message on stderr when called without argument"
	return 1
    }

    $PROG a b > /dev/null 2> "$TMP.err" && {
	echo "[FAIL] -> expected non-zero exit status when called with too many arguments"
	return 1
    }

    ! [ -s "$TMP.err" ] && {
	echo "[FAIL] -> expected error message on stderr when called with too many arguments"
	return 1
    }

    echo "[PASS]"
}

test_03() {
    echo -n "test 03 - program output: "

    $PROG zapp.brannigan > /dev/null 2> "$TMP.err" && {
	echo "[FAIL] -> expected non-zero exit status for unknown user"
        return 1
    }

    ! [ -s toto ] && {
	echo "[FAIL] -> file toto not created or empty"
	return 1
    }

    local usr=$(whoami)
    echo "$usr is connected" > "$TMP.expected"

    ! $PROG "$usr" > "$TMP.out" 2> "$TMP.err" && {
        echo "[FAIL] -> expected exit status 0, or AddressSanitizer detected memory errors, see $TMP.err"
	return 1
    }

    ! cmp -s "$TMP.expected" "$TMP.out" && {
	echo "[FAIL] -> output differs, check $TMP.expected $TMP.out"
	return 1
    }

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
