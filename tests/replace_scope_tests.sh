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
echo "8. replace_scope"

declare -A rules=(
    ['code']="DEV"
    ['ansible/']="OPS"
    ['code/tests']="QA"
    ['code/autotests']="QA"
)
after_label_path_depth=1

echo ""
echo "8.1. Test replace_scope, replacement in the beginning"

files1=("code/Module1/text1.java" "code/Module1/text2.java")
scope1=$(make_scope rules files1 $after_label_path_depth)

files2=("code/Module1/text1.java" "code/Module1/text2.java" "code/tests/text2.java")
scope2=$(make_scope rules files2 $after_label_path_depth)

msg=$(echo "${scope1} test summary

test body")

expect=$(echo "${scope2} test summary

test body")

echo ""
echo "replace_scope \"$msg\" \"$scope2\""
echo ""

res=$(replace_scope "$msg" "$scope2")
assert "$res" "$expect"


echo ""
echo "8.2. Test replace_scope, replacement in the beginning, replace on empty"

files1=("code/Module1/text1.java" "code/Module1/text2.java")
scope1=$(make_scope rules files1 $after_label_path_depth)

scope2=""

msg=$(echo "${scope1} test summary

test body")

expect=$(echo "test summary

test body")

echo ""
echo "replace_scope \"$msg\" \"$scope2\""
echo ""

res=$(replace_scope "$msg" "$scope2")
assert "$res" "$expect"


echo ""
echo "8.3. Test replace_scope, replacement in the midle"

files1=("code/Module1/text1.java" "code/Module1/text2.java")
scope1=$(make_scope rules files1 $after_label_path_depth)

files2=("code/Module1/text1.java" "code/Module1/text2.java" "code/tests/text2.java")
scope2=$(make_scope rules files2 $after_label_path_depth)

msg=$(echo "feat!${scope1} test summary

test body")

expect=$(echo "feat!${scope2} test summary

test body")

echo ""
echo "replace_scope \"$msg\" \"$scope2\""
echo ""

res=$(replace_scope "$msg" "$scope2")
assert "$res" "$expect"


echo ""
echo "8.4. Test replace_scope, replacement in the midle, replace on empty"

files1=("code/Module1/text1.java" "code/Module1/text2.java")
scope1=$(make_scope rules files1 $after_label_path_depth)

scope2=""

msg=$(echo "feat!${scope1} test summary

test body")

expect=$(echo "feat! test summary

test body")

echo ""
echo "replace_scope \"$msg\" \"$scope2\""
echo ""

res=$(replace_scope "$msg" "$scope2")
assert "$res" "$expect"
