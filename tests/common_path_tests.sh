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
echo "1. common_path"

echo ""
echo "1.1. Test common_path"
arg1="source_dir/dir/subdir"
arg2="source_dir/dir"
expect="source_dir/dir"
res=$(common_path "$arg1" "$arg2")
echo "common_path \"$arg1\" \"$arg2\""
assert "$res" "$expect"


#########################################
echo ""
echo "1.2 Test common_path: returns root dir"
arg1="source_dir/dir/subdir"
arg2="source_dir"
expect=$arg2
res=$(common_path "$arg1" "$arg2")
echo "common_path \"$arg1\" \"$arg2\""
assert "$res" "$expect"


#########################################
echo ""
echo "1.3. Test common_path: path contains \"/\" in the end"
arg1="source_dir/dir/subdir"
arg2="source_dir/"
expect="source_dir"
res=$(common_path "$arg1" "$arg2")
echo "common_path \"$arg1\" \"$arg2\""
assert "$res" "$expect"


#########################################
echo ""
echo "1.4. Test common_path: returns root dir (different args order)"
arg1="source_dir"
arg2="source_dir/dir/subdir"
expect=$arg1
res=$(common_path "$arg1" "$arg2")
echo "common_path \"$arg1\" \"$arg2\""
assert "$res" "$expect"


#########################################
echo ""
echo "1.5. Test common_path: same paths"
arg1="source_dir/dir/subdir"
expect=$arg1
res=$(common_path "$arg1" "$arg1")
echo "common_path \"$arg1\" \"$arg1\""
assert "$res" "$expect"


#########################################
echo ""
echo "1.6. Test common_path: returns emptiness (no paths intersection)"
arg1="SOURCE_DIR/dir/subdir"
arg2="source_dir/dir/subdir"
expect=""
res=$(common_path "$arg1" "$arg2")
echo "common_path \"$arg1\" \"$arg2\""
assert "$res" "$expect"


#########################################
echo ""
echo "1.7. Test common_path: returns paths with space"
arg1="source dir/dir/subdir"
arg2="source dir/dir/subdir"
expect="$arg1"
res=$(common_path "$arg1" "$arg2")
echo "common_path \"$arg1\" \"$arg2\""
assert "$res" "$expect"


#########################################
echo ""
echo "1.8. Test common_path: returns empty path"
arg1=""
arg2="source_dir/dir/subdir"
expect="$arg1"
res=$(common_path "$arg1" "$arg2")
echo "common_path \"$arg1\" \"$arg2\""
assert "$res" "$expect"


#########################################
echo ""
echo "1.9. Test common_path: returns empty path (different args order)"
arg1="source_dir/dir/subdir"
arg2=""
expect="$arg2"
res=$(common_path "$arg1" "$arg2")
echo "common_path \"$arg1\" \"$arg2\""
assert "$res" "$expect"


#########################################
echo ""
echo "1.10. Test common_path: returns empty path, several paths"
arg1="source_dir/dir/subdir1"
arg2=""
arg3="source_dir/dir/subdir2"
expect="$arg2"
res=$(common_path "$arg1" "$arg2" "$arg3")
echo "common_path \"$arg1\" \"$arg2\" \"$arg3\""
assert "$res" "$expect"


#########################################
echo ""
echo "1.11. Test common_path: returns empty path, several paths (different args order)"
arg1=""
arg2="source_dir/dir/subdir1"
arg3="source_dir/dir/subdir2"
expect="$arg1"
res=$(common_path "$arg1" "$arg2" "$arg3")
echo "common_path \"$arg1\" \"$arg2\" \"$arg3\""
assert "$res" "$expect"


#########################################
echo ""
echo "1.12. Test common_path: single argument"
arg1="source_dir/dir/subdir"
expect="$arg1"
res=$(common_path "$arg1")
echo "common_path \"$arg1\""
assert "$res" "$expect"


#########################################
echo ""
echo "1.13. Test common_path: returns linux path in case windows path"
arg1="source dir\dir\subdir1"
arg2="source dir\dir\subdir2"
expect="source dir/dir"
res=$(common_path "$arg1" "$arg2")
echo "common_path \"$arg1\" \"$arg2\""
assert "$res" "$expect"


#########################################
echo ""
echo "1.14. Test common_path: cyrillic paths"
arg1="Исходная Директория/Директория/Поддиректория1"
arg2="Исходная Директория/Директория/Поддиректория2"
expect="Исходная Директория/Директория"
res=$(common_path "$arg1" "$arg2")
echo "common_path \"$arg1\" \"$arg2\""
assert "$res" "$expect"