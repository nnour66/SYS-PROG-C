#!/bin/bash

PROG="./calculatrice"
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

    echo "................[PASS]"
}

test_02() {
    echo -n "test 02 - program creates 4 child processes: "

    ! grep "sleep(2)" "$FILE" > /dev/null && {
	echo "[FAIL] -> child should call sleep(2) before using pipe"
	return 1
    }

    $PROG 5 > /dev/null 2> "$TMP.err" &
    local pid="$!"

    sleep 1

    local nb=$(pgrep -P "$pid" | wc -l)
    [ "$nb" -ne 4 ] && {
	echo "[FAIL] -> expected 4 child processes, got $nb"
	return 1
    }

    ! wait "$pid" > /dev/null 2>&1 && {
        echo "[FAIL] -> expected exit status 0, or AddressSanitizer detected memory errors, see $TMP.err"
        return 1
    }

    echo "....[PASS]"
}

test_03() {
    echo -n "test 03 - program supports addition: "

    local a=$(( RANDOM % 101 ))
    local b=$(( RANDOM % 101 ))
    local sum=$(($a + $b))
    
    ! $PROG "$a" "+" "$b" > "$TMP.out" 2> "$TMP.err" && {
	echo "[FAIL] -> expected 0 exit status, or AddressSanitizer detected memory errors, see $TMP.err"
	return 1
    }

    local val=$(cat "$TMP.out")

    # empty output
    [ -z "$val" ] && {
	echo "[FAIL] -> no output produced"
	return 1
    }

    # non-numeric output
    ! [[ "$val" =~ ^-?[0-9]+$ ]] && {
	echo "[FAIL] -> non-numeric output: '$val'"
	return 1
    }

    # numeric but wrong value
    [ "$val" -ne "$sum" ] && {
	echo "[FAIL] -> expected value $sum, got $val"
	return 1
    }

    echo "............[PASS]"
}

test_04() {
    echo -n "test 04 - program supports substraction: "

    local a=$(( RANDOM % 101 ))
    local b=$(( RANDOM % 101 ))
    local sub=$(($a - $b))

    ! $PROG "$a" "-" "$b" > "$TMP.out" 2> "$TMP.err" && {
	echo "[FAIL] -> expected 0 exit status, or AddressSanitizer detected memory errors, see $TMP.err"
	return 1
    }

    local val=$(cat "$TMP.out")

    # empty output
    [ -z "$val" ] && {
	echo "[FAIL] -> no output produced"
	return 1
    }

    # non-numeric output
    ! [[ "$val" =~ ^-?[0-9]+$ ]] && {
	echo "[FAIL] -> non-numeric output: '$val'"
	return 1
    }

    # numeric but wrong value
    [ "$val" -ne "$sub" ] && {
	echo "[FAIL] -> expected value $sub, got $val"
	return 1
    }

    echo "........[PASS]"
}

test_05() {
    echo -n "test 05 - program supports multiplication: "

    local a=$(( RANDOM % 101 ))
    local b=$(( RANDOM % 101 ))
    local mul=$(($a * $b))
    
    ! $PROG "$a" "*" "$b" > "$TMP.out" 2> "$TMP.err" && {
        echo "[FAIL] -> expected 0 exit status, or AddressSanitizer detected memory errors, see $TMP.err"
	return 1
    }

    local val=$(cat "$TMP.out")

    # empty output
    [ -z "$val" ] && {
	echo "[FAIL] -> no output produced"
	return 1
    }

    # non-numeric output
    ! [[ "$val" =~ ^-?[0-9]+$ ]] && {
	echo "[FAIL] -> non-numeric output: '$val'"
	return 1
    }

    # numeric but wrong value
    [ "$val" -ne "$mul" ] && {
	echo "[FAIL] -> expected value $mul, got $val"
	return 1
    }

    echo "......[PASS]"
}

test_06() {
    echo -n "test 06 - program supports division: "

    local a=$(( RANDOM % 100 + 1 ))
    local b=$(( RANDOM % 100 + 1 ))
    local div=$(($a / $b))
    
    ! $PROG "$a" "/" "$b" > "$TMP.out" 2> "$TMP.err" && {
        echo "[FAIL] -> expected 0 exit status, or AddressSanitizer detected memory errors, see $TMP.err"
	return 1
    }

    local val=$(cat "$TMP.out")

    # empty output
    [ -z "$val" ] && {
	echo "[FAIL] -> no output produced"
	return 1
    }

    # non-numeric output
    ! [[ "$val" =~ ^-?[0-9]+$ ]] && {
	echo "[FAIL] -> non-numeric output: '$val'"
	return 1
    }

    # numeric but wrong value
    [ "$val" -ne "$div" ] && {
	echo "[FAIL] -> expected value $div, got $val"
	return 1
    }

    echo "............[PASS]"
}

test_07() {
    echo -n "test 07 - combination of operands and operators: "

    local a=$(( RANDOM % 101 ))
    local b=$(( RANDOM % 101 ))
    local c=$(( RANDOM % 101 ))
    local d=$(( RANDOM % 100 + 1 ))
    local res=$(($a - $b))
    res=$(($res * $c))
    res=$(($res / $d))

    ! $PROG "$a" "-" "$b" "*" "$c" "/" "$d" > "$TMP.out" 2> "$TMP.err" && {
        echo "[FAIL] -> expected 0 exit status, or AddressSanitizer detected memory errors, see $TMP.err"
	return 1
    }

    local val=$(cat "$TMP.out")

    # empty output
    [ -z "$val" ] && {
	echo "[FAIL] -> no output produced"
	return 1
    }

    # non-numeric output
    ! [[ "$val" =~ ^-?[0-9]+$ ]] && {
	echo "[FAIL] -> non-numeric output: '$val'"
	return 1
    }

    # numeric but wrong value
    [ "$val" -ne "$res" ] && {
	echo "[FAIL] -> expected result $res, got $val"
	return 1
    }

    echo "[PASS]"
}

test_08() {
    echo -n "test 08 - program with unknown operand: "

    $PROG 42 x 3 > "$TMP.out" 2> "$TMP.err" && {
	echo "[FAIL] -> expected non-zero exit status"
        return 1
    }

    [ -s "$TMP.out" ] && {
	echo "[FAIL] -> output detected on stdout"
	return 1
    }

    ! [ -s "$TMP.err" ] && {
	echo "[FAIL] -> no output detected on stderr"
	return 1
    }

    echo ".........[PASS]"
}

test_09() {
    echo -n "test 09 - test of children termination: "

    $PROG 5 > "$TMP.out" 2> "$TMP.err" &
    local pid="$!"

    sleep 1

    local child=$(pgrep -P "$pid" | head -1)
    [ -n "$child" ] && kill -s SIGTERM "$child"


    wait "$pid" > /dev/null 2>&1 && {
        echo "[FAIL] -> expected non-zero exit status"
        return 1
    }

    [ -s "$TMP.out" ] && {
	echo "[FAIL] -> output detected on stdout"
	return 1
    }

    ! [ -s "$TMP.err" ] && {
	echo "[FAIL] -> no output detected on stderr"
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
        9) test_09 ;;
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
    for t in 1 2 3 4 5 6 7 8 9; do
        run_test "$t" || exit 1
    done
else
    # Tests demandés
    for t in "$@"; do
        run_test "$t" || exit 1
    done
fi

rm -rf "$TMP".*
