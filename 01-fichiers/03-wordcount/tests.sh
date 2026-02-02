#!/bin/bash

PROG="./wordcount"
FILE="$PROG.c"

TMP=${TMP:=/tmp/test.$USER} # chemin des logs de test
umask 0077		    # permissions des fichiers temporaires

ASAN_OPTIONS=detect_leaks=1

######################################

# Tests

######################################

test_01() {
    echo -n "test 01 - no stdio functions (open/read/write only): "

    grep "fopen" "$FILE" && {
        echo "[FAIL] -> forbidden stdio call detected (use open/read/write, not fopen)"
        return 1
    }
    echo "[PASS]"
}

test_02() {
    echo -n "test 02 - error handling (invalid arguments): "

    $PROG > /dev/null 2> "$TMP.err" && {
        echo "[FAIL] -> expected non-zero exit status when called without arguments"
        return 1
    }

    ! [ -s "$TMP.err" ] && {
        echo "[FAIL] -> expected error message on stderr when called without arguments"
        return 1
    }

    $PROG "$TMP.abcd" > /dev/null 2> "$TMP.err" && {
        echo "[FAIL] -> expected non-zero exit status when file does not exist"
        return 1
    }

    ! [ -s "$TMP.err" ] && {
        echo "[FAIL] -> expected error message on stderr when file does not exist"
        return 1
    }

    echo ".......[PASS]"
}

test_03() {
    echo -n "test 03 - normal execution on existing file: "

    LC_ALL=C tr -dc "A-Za-z0-9 \n\t\r\f" < /dev/urandom | head -c 4096303 > "$TMP.in"

    ! $PROG "$TMP.in" > "$TMP.out" 2> "$TMP.err" && {
        echo "[FAIL] -> expected exit status 0, or AddressSanitizer detected memory errors, see $TMP.err"
        return 1
    }

    echo "........[PASS]"
}

test_04() {
    echo -n "test 04 - produces output on stdout: "

    LC_ALL=C tr -dc "A-Za-z0-9 \n\t\r\f" < /dev/urandom | head -c 4096303 > "$TMP.in"

    ! $PROG "$TMP.in" > "$TMP.out" 2> "$TMP.err" && {
        echo "[FAIL] -> expected exit status 0, or AddressSanitizer detected memory errors, see $TMP.err"
        return 1
    }

    ! [ -s "$TMP.out" ] && {
        echo "[FAIL] -> expected non-empty output on stdout"
        return 1
    }

    echo "................[PASS]"
}

test_05() {
    echo -n "test 05 - correct line count: "

    LC_ALL=C tr -dc "A-Za-z0-9 \n\t\r\f" < /dev/urandom | head -c 4096303 > "$TMP.in"

    local r1=$(wc -l "$TMP.in" | cut -d ' ' -f1)

    ! $PROG "$TMP.in" > "$TMP.out" 2> "$TMP.err" && {
        echo "[FAIL] -> expected exit status 0, or AddressSanitizer detected memory errors, see $TMP.err"
        return 1
    }

    local r2=$(cat "$TMP.out" | cut -d ' ' -f1)

    [ "$r1" -ne "$r2" ] && {
        echo "[FAIL] -> expected $r1 line count, got $r2"
        return 1
    }

    echo ".......................[PASS]"
}

test_06() {
    echo -n "test 06 - correct word count: "

    LC_ALL=C tr -dc "A-Za-z0-9 \n\t\r\f" < /dev/urandom | head -c 4096303 > "$TMP.in"

    local r1=$(wc -w "$TMP.in" | cut -d ' ' -f1)

    ! $PROG "$TMP.in" > "$TMP.out" 2> "$TMP.err" && {
        echo "[FAIL] -> expected exit status 0, or AddressSanitizer detected memory errors, see $TMP.err"
        return 1
    }

    local r2=$(cat "$TMP.out" | cut -d ' ' -f2)

    [ "$r1" -ne "$r2" ] && {
        echo "[FAIL] -> expected $r1 word count, got $r2"
        return 1
    }

    echo ".......................[PASS]"
}

test_07() {
    echo -n "test 07 - correct byte count"

    LC_ALL=C tr -dc "A-Za-z0-9 \n\t\r\f" < /dev/urandom | head -c 4096303 > "$TMP.in"

    local r1=$(wc -c "$TMP.in" | cut -d ' ' -f1)

    ! $PROG "$TMP.in" > "$TMP.out" 2> /dev/null && {
        echo "[FAIL] -> expected exit status 0, or AddressSanitizer detected memory errors, see $TMP.err"
        return 1
    }

    local r2=$(cat "$TMP.out" | cut -d ' ' -f3)

    [ "$r1" -ne "$r2" ] && {
        echo "[FAIL] -> expected $r1 byte count, got $r2"
        return 1
    }

    echo ".........................[PASS]"
}

test_08() {
    echo -n "test 08 - efficient block-based processing: "

    LC_ALL=C tr -dc "A-Za-z0-9 \n\t\r\f" < /dev/urandom | head -c 4096303 > "$TMP.in"

    local t0=$(date +%s)
    ! $PROG "$TMP.in" > /dev/null 2> "$TMP.err" && {
        echo "[FAIL] -> expected exit status 0, or AddressSanitizer detected memory errors, see $TMP.err"
        return 1
    }
    local t1=$(date +%s)

    local runtime=$(($t1 - $t0))
    [ "$runtime" -gt "1" ] && {
        echo "[FAIL] -> execution time exceeds 1s (are you processing input byte-by-byte?)"
        return 1
    }

    echo ".........[PASS]"
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
        8) test_08 ;;
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
    for t in 1 2 3 4 5 6 7 8; do
        run_test "$t" || exit 1
    done
else
    # Tests demandés                                                                                                                                          
    for t in "$@"; do
        run_test "$t" || exit 1
    done
fi

rm -f "$TMP".*
