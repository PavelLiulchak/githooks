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
echo "4. strip_path_before"

echo ""
echo "4.1. Test strip_path_before, Linux paths"
path="code/Module1//"
dir="code/"
expect="Module1"
res=$(strip_path_before "$path" "$dir")
echo "strip_path_before \"$path\" \"$dir\""
assert "$res" "$expect"


#########################################
echo ""
echo "4.2. Test strip_path_before, Windows paths"
path="code\Module1\\\\"
dir="code\\"
expect="Module1"
res=$(strip_path_before "$path" "$dir")
echo "strip_path_before \"$path\" \"$dir\""
assert "$res" "$expect"


#########################################
echo ""
echo "4.3. Test strip_path_before, long paths"
path="code/Dir1/Dir2/Dir3/Dir4"
dir="code"
expect="Dir1/Dir2/Dir3/Dir4"
res=$(strip_path_before "$path" "$dir")
echo "strip_path_before \"$path\" \"$dir\""
assert "$res" "$expect"


#########################################
echo ""
echo "4.4. Test strip_path_before, cut from center"
path="code/Dir1/Dir2/Dir3/Dir4"
dir="code/Dir1/Dir2/"
expect="Dir3/Dir4"
res=$(strip_path_before "$path" "$dir")
echo "strip_path_before \"$path\" \"$dir\""
assert "$res" "$expect"


#########################################
echo ""
echo "4.5. Test strip_path_before, subdir with the same name as dir"
path="code/Dir/Dir/Dir1/Dir2"
dir="code/Dir/"
expect="Dir/Dir1/Dir2"
res=$(strip_path_before "$path" "$dir")
echo "strip_path_before \"$path\" \"$dir\""
assert "$res" "$expect"


#########################################
echo ""
echo "4.6. Test strip_path_before, space in the path"
path="code/Dir 1/Dir2/Dir3/Dir4"
dir="code/Dir 1/Dir2/"
expect="Dir3/Dir4"
res=$(strip_path_before "$path" "$dir")
echo "strip_path_before \"$path\" \"$dir\""
assert "$res" "$expect"