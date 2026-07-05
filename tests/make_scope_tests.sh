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
echo "0. make_scope"

echo ""
echo "0.1. Test path_into_linux_path"
arg="C:\Users\Test\project"
expect="C:/Users/Test/project"
res=$(path_into_linux_path "$arg")
echo "path_into_linux_path \"$arg\""
assert "$res" "$expect"