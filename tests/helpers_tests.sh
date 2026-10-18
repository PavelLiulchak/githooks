#!/bin/bash

# Copyright 2026 Pavel Liulchak
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

echo_green() {
  line=$1
  GREEN=$(tput setaf 2)
  RESET=$(tput sgr0)

  echo "${GREEN}$line${RESET}"
}

echo_red() {
  line=$1
  RED=$(tput setaf 1)
  RESET=$(tput sgr0)

  echo "${RED}$line${RESET}"
}

assert() {
  res=$1
  expect=$2

  echo "res = \"$res\""
  echo "expect = \"$expect\""

  if [[ "$res" == "$expect" ]]; then
    echo_green "Success"
  else
    echo_red "Failed"
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
        echo_red "Assertion failed: array sizes differ"
        return 1
    fi

    for key in "${!expected_local[@]}"; do
        if [[ ! -v actual_local["$key"] ]]; then
                echo_red "Assertion failed: missing key '$key'"
                return 1
        fi

        if [[ "${actual_local[$key]}" != "${expected_local[$key]}" ]]; then
            echo_red "Assertion failed for key '$key'"
            echo_red "  actual:   '${actual_local[$key]}'"
            echo_red "  expected: '${expected_local[$key]}'"
            return 1
        fi
    done

    echo_green "Success"
}

assert_array_equals() {
    local -n actual_local=$1
    local -n expected_local=$2

    echo "res = '${actual_local[@]}'"
    echo "expect = '${expected_local[@]}'"

    if ((${#actual_local[@]} != ${#expected_local[@]})); then
        echo_red "Assertion failed: array sizes differ"
        echo_red "  actual:   '${actual_local[@]}'"
        echo_red "  expected: '${expected_local[@]}'"
        return 1
    fi

    for ((i = 0; i < ${#actual_local[@]}; i++)); do
        if [[ "${actual_local[i]}" != "${expected_local[i]}" ]]; then
            echo_red "Assertion failed for arrays"
            echo_red "  actual:   '${actual_local[@]}'"
            echo_red "  expected: '${expected_local[@]}'"
            return 1
        fi
    done

    echo_green "Success"
}