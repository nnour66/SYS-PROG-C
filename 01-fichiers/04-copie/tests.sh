#!/bin/bash

PROG="./copie"
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
    echo "................[PASS]"
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
        echo "[FAIL] -> expected non-zero exit status when called with only one argument"
        return 1
    }

    ! [ -s "$TMP.err" ] && {
        echo "[FAIL] -> expected error message on stderr when called with only one argument"
        return 1
    }

    $PROG "$TMP.abcd" "$TMP.dcba" > /dev/null 2> "$TMP.err" && {
        echo "[FAIL] -> expected non-zero exit status when source file does not exist"
        return 1
    }

    ! [ -s "$TMP.err" ] && {
        echo "[FAIL] -> expected error message on stderr when source file does not exist"
        return 1
    }

    LC_ALL=C tr -dc "A-Za-z0-9 \n\t\r" < /dev/urandom | head -c 1024300 > "$TMP.in"
    touch "$TMP.in.cpy" ; chmod -w "$TMP.in.cpy"

    $PROG "$TMP.in" "$TMP.in.cpy" > /dev/null 2> "$TMP.err" && {
        chmod +w "$TMP.in.cpy"
        echo "[FAIL] -> expected non-zero exit status when writing to non-writable destination file"
        return  1
    }
    chmod +w "$TMP.in.cpy"

    ! [ -s "$TMP.err" ] && {
        echo "[FAIL] -> expected error message on stderr when writing to non-writable destination file"
        return 1
    }

    echo ".......................[PASS]"
}

test_03() {
    echo -n "test 03 - normal execution on existing file: "

    LC_ALL=C tr -dc "A-Za-z0-9 \n\t\r" < /dev/urandom | head -c 1024300 > "$TMP.in"

    ! $PROG "$TMP.in" "$TMP.in.cpy" > /dev/null 2> "$TMP.err" && {
        echo "[FAIL] -> expected exit status 0, or AddressSanitizer detected memory errors, see $TMP.err"
        return 1
    }

    echo "........................[PASS]"
}

# we assume here that umask is set to its default value 0022
test_04() {
    echo -n "test 04 - destination file created with correct default permissions: "

    LC_ALL=C tr -dc "A-Za-z0-9 \n\t\r" < /dev/urandom | head -c 1024300 > "$TMP.in"

    ! $PROG "$TMP.in" "$TMP.in.cpy" > /dev/null 2> "$TMP.err" && {
        echo "[FAIL] -> expected exit status 0, or AddressSanitizer detected memory errors, see $TMP.err"
        return 1
    }

    ! [ -r "$TMP.in.cpy" ] && {
        echo "[FAIL] -> destination file should be created and readable"
        return 1
    }

    ! [ -w "$TMP.in.cpy" ] && {
        echo "[FAIL] -> destination file should be created and writable"
        return 1
    }

    [ -x "$TMP.in.cpy" ] && {
        echo "[FAIL] -> destination file must not be executable"
        return 1
    }

    echo "[PASS]"
}

test_05() {
    echo -n "test 05 - data written to destination file: "

    LC_ALL=C tr -dc "A-Za-z0-9 \n\t\r" < /dev/urandom | head -c 1024300 > "$TMP.in"

    ! $PROG "$TMP.in" "$TMP.in.cpy" > /dev/null 2> "$TMP.err" && {
        echo "[FAIL] -> expected exit status 0, or AddressSanitizer detected memory errors, see $TMP.err"
        return 1
    }

    ! [ -s "$TMP.in.cpy" ] && {
        echo "[FAIL] -> destination file is empty (no data written)"
        return 1
    }

    echo ".........................[PASS]"
}

test_06() {
    echo -n "test 06 - exact copy (ASCII and binary files): "

    # ASCII
    LC_ALL=C tr -dc "A-Za-z0-9 \n\t\r" < /dev/urandom | head -c 1024300 > "$TMP.in"
    ! $PROG "$TMP.in" "$TMP.in.cpy" > /dev/null 2> "$TMP.err" && {
        echo "[FAIL] -> expected exit status 0 when copying ASCII file, or AddressSanitizer detected memory errors, see $TMP.err"
        return 1
    }
    
    ! cmp "$TMP.in" "$TMP.in.cpy" && {
        echo "[FAIL] -> copied ASCII file differs from source"
        return 1
    }

    # BINARY
    head -c 1024300 /dev/urandom > "$TMP.in"
    ! $PROG "$TMP.in" "$TMP.in.cpy" > /dev/null 2> "$TMP.err" && {
        echo "[FAIL] -> expected exit status 0 when copying binary file, or AddressSanitizer detected memory errors, see $TMP.err"
        return 1
    }

    ! cmp "$TMP.in" "$TMP.in.cpy" && {
        echo "[FAIL] -> copied binary file differs from source (binary-safe copy expected)"
        return 1
    }

    echo "......................[PASS]"
}

test_07() {
    echo -n "test 07 - efficient block-based processing: "

    head -c 1024300 /dev/urandom > "$TMP.in"

    local t0=$(date +%s)
    ! $PROG "$TMP.in" "$TMP.in.cpy" > /dev/null 2> "$TMP.err" && {
        echo "[FAIL] -> expected exit status 0, or AddressSanitizer detected memory errors, see $TMP.err"
        return 1
    }
    local t1=$(date +%s)

    local runtime=$(($t1 - $t0))
    [ "$runtime" -gt "1" ] && {
        echo "[FAIL] -> execution time exceeds 1s (are you processing input byte-by-byte?)"
        return 1
    }

    echo ".........................[PASS]"
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

rm -f "$TMP".*
