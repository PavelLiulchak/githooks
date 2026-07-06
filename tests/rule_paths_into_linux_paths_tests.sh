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
echo "2. rule_paths_into_linux_paths"

echo ""
echo "2.1. Test rule_paths_into_linux_paths, Windows paths"
declare -A actual=(
    ["code"]="DEV"
    ["code\tests"]="QA"
    ["code\autotests"]="QA"
)

declare -A expected=(
    ["code"]="DEV"
    ["code/tests"]="QA"
    ["code/autotests"]="QA"
)

echo "actual:"
echo_assoc_array actual
echo ""
echo "expected:"
echo_assoc_array expected
echo ""

rule_paths_into_linux_paths actual

assert_assoc_array_equals actual expected

echo ""
echo "2.2. Test rule_paths_into_linux_paths, Linux paths"
declare -A actual=(
    ["code"]="DEV"
    ["code/tests"]="QA"
    ["code/autotests"]="QA"
)

declare -A expected=(
    ["code"]="DEV"
    ["code/tests"]="QA"
    ["code/autotests"]="QA"
)

echo "actual:"
echo_assoc_array actual
echo ""
echo "expected:"
echo_assoc_array expected
echo ""

rule_paths_into_linux_paths actual

assert_assoc_array_equals actual expected


echo ""
echo "2.3. Test rule_paths_into_linux_paths, Mixed paths"
declare -A actual=(
    ["code"]="DEV"
    ["code/tests"]="QA"
    ["code\autotests"]="QA"
)

declare -A expected=(
    ["code"]="DEV"
    ["code/tests"]="QA"
    ["code/autotests"]="QA"
)

echo "actual:"
echo_assoc_array actual
echo ""
echo "expected:"
echo_assoc_array expected
echo ""

rule_paths_into_linux_paths actual

assert_assoc_array_equals actual expected