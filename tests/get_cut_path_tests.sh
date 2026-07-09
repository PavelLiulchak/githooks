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
echo "5. get_cut_path"

echo ""
echo "5.1. Test get_cut_path"
path="source_dir/dir/sub dir"
depth=0
expect=""
res=$(get_cut_path "$path" "$depth")
echo "get_cut_path \"$path\" \"$depth\""
assert "$res" "$expect"

echo ""
echo "5.2. Test get_cut_path"
path="source_dir/dir/sub dir"
depth=1
expect="source_dir"
res=$(get_cut_path "$path" "$depth")
echo "get_cut_path \"$path\" \"$depth\""
assert "$res" "$expect"

echo ""
echo "5.3. Test get_cut_path"
path="source_dir/dir/sub dir"
depth=3
res=$(get_cut_path "$path" "$depth")
echo "get_cut_path \"$path\" \"$depth\""
assert "$res" "$path"

echo ""
echo "5.4. Test get_cut_path"
path="source_dir/dir/sub dir"
depth=10
res=$(get_cut_path "$path" "$depth")
echo "get_cut_path \"$path\" \"$depth\""
assert "$res" "$path"