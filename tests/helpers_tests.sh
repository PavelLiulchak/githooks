#!/bin/bash

assert() {
  res=$1
  expect=$2

  echo "res = $res"
  echo "expect = $expect"

  if [[ $res == $expect ]]; then
    GREEN=$(tput setaf 2)
    RESET=$(tput sgr0)

    echo "${GREEN}Success${RESET}"
  else
    RED=$(tput setaf 1)
    RESET=$(tput sgr0)

    echo "${RED}Failed${RESET}"
  fi
}

echo_assoc_array() {
    local -n array_local=$1

    for key in "${!array_local[@]}"; do
      echo "\"$key\" : ${array_local[$key]}"
    done
}

assert_assoc_array_equals() {
    local -n actual_local=$1
    local -n expected_local=$2

    if ((${#actual_local[@]} != ${#expected_local[@]})); then
        RED=$(tput setaf 1)
        RESET=$(tput sgr0)
        echo "${RED}Assertion failed: array sizes differ${RESET}"
        return 1
    fi

    for key in "${!expected_local[@]}"; do
        if [[ ! -v actual_local["$key"] ]]; then
                RED=$(tput setaf 1)
                RESET=$(tput sgr0)
                echo "${RED}Assertion failed: missing key '$key'${RESET}"
                return 1
        fi

        if [[ "${actual_local[$key]}" != "${expected_local[$key]}" ]]; then
            RED=$(tput setaf 1)
            RESET=$(tput sgr0)
            echo "${RED}Assertion failed for key '$key':${RESET}"
            echo "  actual:   '${actual_local[$key]}'"
            echo "  expected: '${expected_local[$key]}'"
            return 1
        fi
    done

    GREEN=$(tput setaf 2)
    RESET=$(tput sgr0)
    echo "${GREEN}Success${RESET}"
}