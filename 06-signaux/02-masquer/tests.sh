#!/bin/bash

PROG="./masquer"
FILE="$PROG.c"

TMP=${TMP:=/tmp/test.$USER} # chemin des logs de test
umask 0077		    # permissions des fichiers temporaires

ASAN_OPTIONS=detect_leaks=1

######################################

# Tests

######################################

test_01() {
    echo -n "test 01 - program uses POSIX API: "

    ! grep "sigprocmask" "$FILE" > /dev/null 2>&1 && {
        echo "[FAIL] -> you should use POSIX signals API (sigprocmask)"
        return 1
    }

    echo "..........[PASS]"
}

test_02() {
    echo -n "test 02 - program output for SIGINT: "

    cat <<EOF > "$TMP.expected"
Interrupt
EOF

    LC_ALL=C $PROG > "$TMP.out" 2> "$TMP.err" &
    local pid=$!

    sleep 0.5 ; kill -2 "$pid" > /dev/null 2>&1

    ! wait "$pid" 2> /dev/null && {
        echo "[FAIL] -> signal not masked, or AddressSanitizer detected memory errors, see $TMP.err"
        return 1
    }

    ! cmp -s "$TMP.out" "$TMP.expected" && {
        echo "[FAIL] -> output differs from expected SIGINT handling"
        return 1
    }

    echo ".......[PASS]"
}

test_03() {
    echo -n "test 03 - program output for POSIX signals: "

    cat <<EOF > "$TMP.expected"
Hangup
Interrupt
Quit
Aborted
Alarm clock
Terminated
EOF

    LC_ALL=C $PROG > "$TMP.out" 2> "$TMP.err" &
    local pid=$!

    sleep 0.5
    kill -1  "$pid" > /dev/null 2>&1
    kill -2  "$pid" > /dev/null 2>&1
    kill -3  "$pid" > /dev/null 2>&1
    kill -6  "$pid" > /dev/null 2>&1
    kill -14 "$pid" > /dev/null 2>&1
    kill -15 "$pid" > /dev/null 2>&1

    ! wait "$pid" 2> /dev/null && {
        echo "[FAIL] -> signal not masked, or AddressSanitizer detected memory errors, see $TMP.err"
        return 1
    }

    ! cmp -s "$TMP.out" "$TMP.expected" && {
        echo "[FAIL] -> output differs from expected signals handling"
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
            exit 1
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
