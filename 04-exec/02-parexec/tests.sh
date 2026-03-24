#!/bin/bash

PROG="./parexec"
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
        echo "[FAIL] -> expected non-zero exit status when called without argument"
        return 1
    }

    ! [ -s "$TMP.err" ] && {
        echo "[FAIL] -> expected error message on stderr when called without argument"
        return 1
    }

    $PROG abcd > /dev/null 2> "$TMP.err"  && {
        echo "[FAIL] -> expected non-zero exit status when called with one argument"
        return 1
    }

    ! [ -s "$TMP.err" ] && {
        echo "[FAIL] -> expected error message on stderr when called with one argument"
        return 1
    }

    $PROG 0 ls > /dev/null 2> "$TMP.err"  && {
        echo "[FAIL] -> expected non-zero exit status when n=0"
        return 1
    }

    ! [ -s "$TMP.err" ] && {
        echo "[FAIL] -> expected error message on stderr when n=0"
        return 1
    }

    $PROG 0 abcd > /dev/null 2> "$TMP.err"  && {
        echo "[FAIL] -> expected non-zero exit status when cmd is not found"
        return 1
    }

    ! [ -s "$TMP.err" ] && {
        echo "[FAIL] -> expected error message on stderr when cmd is not found"
        return 1
    }
    
    echo "........[PASS]"
}

test_02() {
    echo -n "test 02 - fork() error handling: "

    ! grep -q "case -1:" "$FILE" && {
        echo "[FAIL] -> no handling of fork() failure (-1 case) found in source"
        return 1
    }

    echo ".....................[PASS]"
}

test_03() {
    echo -n "test 03 - program output with random execution count: "

    # random number between 1 and 9
    local n=$((RANDOM % 9 + 1))

    # build expected output
    : > "$TMP.expected"
    for i in $(seq 0 $((n - 1))); do
        printf "salut %d\n" "$i" >> "$TMP.expected"
    done

    # program output
    ! $PROG "$n" "echo" "salut" | sort -d > "$TMP.out" 2> "$TMP.err" && {
        echo "[FAIL] -> expected exit status 0, or AddressSanitizer detected memory errors, see $TMP.err"
        return 1
    }

    ! cmp -s "$TMP.out" "$TMP.expected" && {
        echo "[FAIL] -> output differs from reference file (n=$n), check $TMP.expected and $TMP.out"
        return 1
    }

    rm -f "$TMP".*
    echo "[PASS]"
}

test_04() {
    echo -n "test 04 - program return code if child fails: "

    cat << 'EOF' > "$TMP.cmd.sh"
#!/bin/sh
exit "$1"
EOF
    chmod +x "$TMP.cmd.sh"

    # run program: second execution should fail with exit code 1
    $PROG 2 "$TMP.cmd.sh" > /dev/null 2> "$TMP.err"
    local rc="$?"

    [ "$rc" -ne 1 ] && {
        echo "[FAIL] -> expected return code 1, got $rc"
        return 1
    }

    rm -f "$TMP".*
    echo "........[PASS]"
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
