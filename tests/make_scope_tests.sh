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
echo "3. make_scope_tests"

declare -A rules=(
    ['code']="DEV"
    ['ansible/']="OPS"
    ['code/tests']="QA"
    ['code/autotests']="QA"
)

echo ""
echo "3.1. Test make_scope"

files=("code/tests" "code/autotests" "ansible")

echo "rules:"
echo_assoc_array rules

echo ""
make_scope rules files