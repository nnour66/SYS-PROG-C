#!/bin/bash

PROG="./liste"
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

    ! grep "sigsuspend" "$FILE" > /dev/null 2>&1 && {
        echo "[FAIL] -> you should use POSIX signals API"
        return 1
    }

    echo "................[PASS]"
}

test_02() {
    echo -n "test 02 - fork() error handling: "

    ! grep -q "case -1:" "$FILE" && {
        echo "[FAIL] -> no handling of fork() failure (-1 case) found in source"
        return 1
    }

    echo ".................[PASS]"
}

test_03() {
    echo -n "test 03 - program completes (timeout set to 30s): "

    $PROG > "$TMP.out" 2> "$TMP.err" &
    local pid="$!"

    sleep 30 ; kill -s 9 "$pid" > /dev/null 2>&1
    ! wait "$pid" > /dev/null 2>&1 && {
        echo "[FAIL] -> expected zero exit status, program loops or AddressSanitizer detected memory errors, see $TMP.err"
        return 1
    }

    echo "[PASS]"
}

test_04() {
    echo -n "test 04 - program creates child process: "

    $PROG > /dev/null 2> "$TMP.err" &
    local pid="$!"

    sleep 1

    local nb=$(pgrep -P "$pid" | wc -l)
    [ -z "$nb" ] && {
        echo "[FAIL] -> no child process found"
        return 1
    }

    [ "$nb" -ne 29 ] && {
	echo "[FAIL] -> expected 29 child processes, got $nb"
	return 1
    }

    sleep 30 ; kill -s 9 "$pid" > /dev/null 2>&1
    ! wait "$pid" > /dev/null 2>&1 && {
        echo "[FAIL] -> expected zero exit status, program loops or AddressSanitizer detected memory errors, see $TMP.err"
        return 1
    }

    echo ".........[PASS]"
}

test_05() {
    echo -n "test 05 - program output: "

    $PROG > "$TMP.out" 2> "$TMP.err" &
    local pid="$!"
    sleep 30 ; kill -s 9 "$pid" > /dev/null 2>&1
    ! wait "$pid" > /dev/null 2>&1 && {
        echo "[FAIL] -> expected zero exit status, program loops or AddressSanitizer detected memory errors, see $TMP.err"
        return 1
    }
    
    ! [ -s "$TMP.out" ] && {
        echo "[FAIL] -> expected output on stdout"
        return 1
    }

    local nb=$(grep "START" "$TMP.out" | wc -l)
    [ -z "$nb" ] && {
        echo "[FAIL] -> pattern « START » not found in stdout"
        return 1
    }

    # non-numeric output
    ! [[ "$nb" =~ ^-?[0-9]+$ ]] && {
	echo "[FAIL] -> non-numeric output: '$nb'"
	return 1
    }

    [ $nb -ne 29 ] && {
        echo "[FAIL] -> expected 29 child processes, got $nb"
        return 1
    }

    nb=$(grep "END" "$TMP.out" | wc -l)
    [ -z "$nb" ] && {
        echo "[FAIL] -> pattern « END » not found in stdout"
        return 1
    }

    # non-numeric output
    ! [[ "$nb" =~ ^-?[0-9]+$ ]] && {
	echo "[FAIL] -> non-numeric output: '$nb'"
	return 1
    }

    [ $nb -ne 29 ] && {
        echo "[FAIL] -> expected 29 child processes, got $nb"
        return 1
    }

    nb=$(grep "type 0" "$TMP.out" | cut -d ' ' -f3)
    # non-numeric output
    ! [[ "$nb" =~ ^-?[0-9]+$ ]] && {
	echo "[FAIL] -> number of type 0 is not a numeric value: '$nb'"
	return 1
    }
    
    [ $nb -ne 1000000 ] && {
        echo "[FAIL] -> not 1000000 iter of type 0"
        return 1
    }

    echo "........................[PASS]"
}

test_06() {
    echo -n "test 05 - inconsistencies on type 0: " 

    $PROG > "$TMP.out" 2> "$TMP.err" &

    local pid="$!"
    sleep 30 ; kill -s 9 "$pid" > /dev/null 2>&1
    ! wait "$pid" > /dev/null 2>&1 && {
        echo "[FAIL] -> expected zero exit status, program loops or AddressSanitizer detected memory errors, see $TMP.err"
        return 1
    }

    [ -s "$TMP.err" ] && {
        echo "[FAIL] -> inconsistencies detected, check $TMP.err"
        return 1
    }

    echo ".............[PASS]"
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
            exit 1
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

rm -rf "$TMP".*
