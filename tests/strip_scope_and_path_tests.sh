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
echo "7. strip_scope_and_path"

declare -A rules=(
    ['code']="DEV"
    ['ansible/']="OPS"
    ['code/tests']="QA"
    ['code/autotests']="QA"
)
after_label_path_depth=1

echo ""
echo "7.1. Test strip_scope_and_path, scope consists of [] only"

files=("code/Module1/text1.java" "code/tests/text2.java")
scope=$(make_scope rules files $after_label_path_depth)

msg=$(echo "$scope test summary

test body")

expect=$(echo "test summary

test body")

echo ""
echo "strip_scope_and_path \"$msg\" \"$scope\""
echo ""

res=$(strip_scope_and_path "$msg" "$scope")
assert "$res" "$expect"

echo ""
echo "7.2. Test strip_scope_and_path, scope consists of [] only but it is upsent in message"

files=("code/Module1/text1.java" "code/tests/text2.java")
scope=$(make_scope rules files $after_label_path_depth)

msg=$(echo "[OPS] test summary

test body")

expect=$(echo "[OPS] test summary

test body")

echo ""
echo "strip_scope_and_path \"$msg\" \"$scope\""
echo ""

res=$(strip_scope_and_path "$msg" "$scope")
assert "$res" "$expect"


echo ""
echo "7.3. Test strip_scope_and_path, scope consists of [] and path"

files=("code/Module1/text1.java" "code/Module1/text2.java")
scope=$(make_scope rules files $after_label_path_depth)

msg=$(echo "$scope test summary

test body")

expect=$(echo "test summary

test body")

echo ""
echo "strip_scope_and_path \"$msg\" \"$scope\""
echo ""

res=$(strip_scope_and_path "$msg" "$scope")
assert "$res" "$expect"

echo ""
echo "7.4. Test strip_scope_and_path, scope consists of [] and path and scope is glued with summary"

files=("code/Module1/text1.java" "code/Module1/text2.java")
scope=$(make_scope rules files $after_label_path_depth)

msg=$(echo "${scope}test summary

test body")

expect=$(echo "test summary

test body")

echo ""
echo "strip_scope_and_path \"$msg\" \"$scope\""
echo ""

res=$(strip_scope_and_path "$msg" "$scope")
assert "$res" "$expect"


echo ""
echo "7.5. Test strip_scope_and_path, scope is empty"

files=("Dir1/SubDir1.1/text1.java" "Dir2/SubDir2.1/text2.java")
scope=$(make_scope rules files $after_label_path_depth)

msg=$(echo "test summary

test body")

expect=$(echo "test summary

test body")

echo ""
echo "strip_scope_and_path \"$msg\" \"$scope\""
echo ""

res=$(strip_scope_and_path "$msg" "$scope")
assert "$res" "$expect"