#!/bin/bash

PROG="./myexeclp"

TMP=${TMP:=/tmp/test.$USER} # chemin des logs de test
umask 0077		    # permissions des fichiers temporaires

ASAN_OPTIONS=detect_leaks=1

######################################

# Tests

######################################

test_01() {
    echo -n "test 01 - error handling (invalid arguments): "

    echo "myexeclp: No such file or directory" > "$TMP.errmsg"
    LC_ALL=C $PROG "abcd" -l -g > /dev/null 2> "$TMP.err" && {
        echo "[FAIL] -> expected non-zero exit status when cmd is not found"
        return 1
    }

    ! cmp -s "$TMP.errmsg" "$TMP.err" && {
        echo "[FAIL] -> incorrect error message when cmd not found: either errno is not set, or perror() was not called"
        return 1
    }

    mkdir -p "$TMP.d" ; touch "$TMP.d/tata"
    echo "myexeclp: Not a directory" > "$TMP.errmsg"

    LC_ALL=C PATH="$TMP.d/tata" $PROG echo coucou > /dev/null 2> "$TMP.err" && {
        echo "[FAIL] -> expected non-zero exit status when regular file in PATH"
        return 1
    }

    ! cmp -s "$TMP.errmsg" "$TMP.err" && {
        echo "[FAIL] -> incorrect error message when regular file in PATH: either errno is not set, or perror() was not called"
        return 1
    }

    echo "myexeclp: Argument list too long" > "$TMP.errmsg"
    LC_ALL=C $PROG echo 1 2 3 4 5 6 > /dev/null 2> "$TMP.err" && {
        echo "[FAIL] -> expected non-zero exit status when the number of args > MAX_ARG"
        return 1
    }

    ! cmp -s "$TMP.errmsg" "$TMP.err" && {
        echo "[FAIL] -> incorrect error message when too many args: either errno is not set, or perror() was not called"
        return 1
    }

    rm -rf "$TMP.d" "$TMP.errmsg" "$TMP.err"
    echo "[PASS]"
}

test_02() {
    echo -n "test 02 - program output: "

    mkdir -p "$TMP.d" ; touch "$TMP.d/tata" ; touch "$TMP.d/titi"
    ls -a "$TMP.d" > "$TMP.expected"

    ! $PROG ls -a "$TMP.d" > "$TMP.out" 2> "$TMP.err" && {
        echo "[FAIL] -> expected exit status 0, or AddressSanitizer detected memory errors, see $TMP.err"
	return 1
    }

    ! cmp -s "$TMP.expected" "$TMP.out" && {
        echo "[FAIL] -> output differs from reference file, check $TMP.expected $TMP.out"
        return 1
    }

    echo salut tata titi toto > "$TMP.expected"
    ! $PROG echo salut tata titi toto > "$TMP.out" 2> "$TMP.err" && {
        echo "[FAIL] -> expected exit status 0, or AddressSanitizer detected memory errors, see $TMP.err"
        return 1
    }

    ! cmp -s "$TMP.expected" "$TMP.out" && {
        echo "[FAIL] -> output differs from reference file, check $TMP.expected $TMP.out"
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
    for t in 1 2; do
        run_test "$t" || exit 1
    done
else
    # Tests demandés
    for t in "$@"; do
        run_test "$t" || exit 1
    done
fi

rm -rf "$TMP".*
