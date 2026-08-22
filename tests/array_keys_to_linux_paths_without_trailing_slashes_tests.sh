#!/bin/bash

pushd "$(dirname "$(which "$0")")" >/dev/null
script_dir="$(pwd -P)"
popd >/dev/null

helper_functions_script="$script_dir/../hooks-helper-functions.sh"
if [[ ! -f "$helper_functions_script" ]]; then
echo "$helper_functions_script is not found, nothing to source, exiting..."
exit 1
fi
source $helper_functions_script

helper_tests_script="$script_dir/helpers_tests.sh"
if [[ ! -f "$helper_tests_script" ]]; then
echo "$helper_tests_script is not found, nothing to source, exiting..."
exit 1
fi
source $helper_tests_script

## tests
echo ""
echo "2. array_keys_to_linux_paths_without_trailing_slashes"


#########################################
echo ""
echo "2.1. Test array_keys_to_linux_paths_without_trailing_slashes, Windows paths"
declare -A actual=(
    ['code\']="DEV"
    ['code\tests\\\']="QA"
    ['code\autotests']="QA"
)

declare -A expected=(
    ['code']="DEV"
    ['code/tests']="QA"
    ['code/autotests']="QA"
)

echo "actual:"
echo_assoc_array actual
echo ""
echo "expected:"
echo_assoc_array expected
echo ""

array_keys_to_linux_paths_without_trailing_slashes actual

assert_assoc_array_equals actual expected


#########################################
echo ""
echo "2.2. Test array_keys_to_linux_paths_without_trailing_slashes, Linux paths"
declare -A actual=(
    ['code/']="DEV"
    ['code/tests///']="QA"
    ['code/autotests']="QA"
)

declare -A expected=(
    ['code']="DEV"
    ['code/tests']="QA"
    ['code/autotests']="QA"
)

echo "actual:"
echo_assoc_array actual
echo ""
echo "expected:"
echo_assoc_array expected
echo ""

array_keys_to_linux_paths_without_trailing_slashes actual

assert_assoc_array_equals actual expected


#########################################
echo ""
echo "2.3. Test array_keys_to_linux_paths_without_trailing_slashes, Mixed paths"
declare -A actual=(
    ['code\']="DEV"
    ['code/tests/']="QA"
    ['code\autotests']="QA"
)

declare -A expected=(
    ['code']="DEV"
    ['code/tests']="QA"
    ['code/autotests']="QA"
)

echo "actual:"
echo_assoc_array actual
echo ""
echo "expected:"
echo_assoc_array expected
echo ""

array_keys_to_linux_paths_without_trailing_slashes actual

assert_assoc_array_equals actual expected


#########################################
echo ""
echo "2.4. Test array_keys_to_linux_paths_without_trailing_slashes, empty arrays"
declare -A actual=()

declare -A expected=()

echo "actual:"
echo_assoc_array actual
echo ""
echo "expected:"
echo_assoc_array expected
echo ""

array_keys_to_linux_paths_without_trailing_slashes actual

assert_assoc_array_equals actual expected


#########################################
echo ""
echo "2.5. Test array_keys_to_linux_paths_without_trailing_slashes, Mixed paths + Cyrrilic"
declare -A actual=(
    ['код\']="КОД"
    ['код/тесты/']="КУА"
    ['код\автотесты']="КУА"
)

declare -A expected=(
    ['код']="КОД"
    ['код/тесты']="КУА"
    ['код/автотесты']="КУА"
)

echo "actual:"
echo_assoc_array actual
echo ""
echo "expected:"
echo_assoc_array expected
echo ""

array_keys_to_linux_paths_without_trailing_slashes actual

assert_assoc_array_equals actual expected