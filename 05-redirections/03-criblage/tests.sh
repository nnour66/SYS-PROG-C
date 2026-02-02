#!/bin/bash

PROG="./crible"
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

    $PROG -1 > /dev/null 2> "$TMP.err" && {
        echo "[FAIL] -> expected non-zero exit status when called with N < 2"
        return 1
    }

    ! [ -s "$TMP.err" ] && {
        echo "[FAIL] -> expected error message on stderr when called with N < 2"
        return 1
    }
    
    echo "[PASS]"
}

test_03() {
    echo -n "test 03 - program creates child processes: "

    ! grep "sleep" $FILE > /dev/null && {
        echo "[FAIL] -> child should call sleep (1) before using pipe"
        return 1
    }

    $PROG 16 > "$TMP.out" 2> "$TMP.err" &
    local pid="$!"

    sleep 1

    local nb=$(pgrep -P "$pid" | wc -l)
    [ "$nb" -ne 5 ] && {
        echo "[FAIL] -> 5 children processes expected, got $nb"
        return 1
    }

    ! wait "$pid" > /dev/null 2>&1 && {
        echo "[FAIL] -> expected exit status 0, or AddressSanitizer detected memory errors, see $TMP.err"
        return 1
    }

    echo "...[PASS]"
}

test_04() {
    echo -n "test 04 - program output: "

    cat <<EOF > "$TMP.expected"
2
3
5
7
11
13
17
19
EOF

    ! $PROG 20 > "$TMP.out" 2> "$TMP.err" && {
        echo "[FAIL] -> expected exit status 0, or AddressSanitizer detected memory errors, see $TMP.err"
        return  1
    }

    ! cmp -s "$TMP.expected" "$TMP.out"  && {
        echo "[FAIL] -> output differs from expected numbers, compare $TMP.expected and $TMP.out"
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

rm -rf "$TMP".*
