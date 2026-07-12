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
after_label_path_depth=1

echo ""
echo "3.1. Test make_scope: One label"

files=("code/Module1/text1.java" "code/Module1/SubModule1/text2.java")

echo "rules:"
echo_assoc_array rules

echo ""
echo "files:"
echo "${files[@]}"

echo ""
res=$(make_scope rules files $after_label_path_depth)
expect="[DEV] Module1:"
echo "make_scope rules files"
assert "$res" "$expect"

echo ""
echo "3.2. Test make_scope: One label, depth=1"

files=("code/Module1/SubModule1/SubSubModule1/text1.java" "code/Module1/SubModule1/SubSubModule1/text2.java")

echo "rules:"
echo_assoc_array rules

echo ""
echo "files:"
echo "${files[@]}"

echo ""
res=$(make_scope rules files $after_label_path_depth)
expect="[DEV] Module1:"
echo "make_scope rules files"
assert "$res" "$expect"

echo ""
echo "3.3. Test make_scope: One label, depth=2"

files=("code/Module1/SubModule1/SubSubModule1/text1.java" "code/Module1/SubModule1/SubSubModule1/text2.java")

echo "rules:"
echo_assoc_array rules

echo ""
echo "files:"
echo "${files[@]}"

echo ""
res=$(make_scope rules files 2)
expect="[DEV] Module1/SubModule1:"
echo "make_scope rules files"
assert "$res" "$expect"

echo ""
echo "3.4. Test make_scope: One label, depth=100"

files=("code/Module1/SubModule1/SubSubModule1/text1.java" "code/Module1/SubModule1/SubSubModule1/text2.java")

echo "rules:"
echo_assoc_array rules

echo ""
echo "files:"
echo "${files[@]}"

echo ""
res=$(make_scope rules files 100)
expect="[DEV] Module1/SubModule1/SubSubModule1:"
echo "make_scope rules files"
assert "$res" "$expect"

echo ""
echo "3.5. Test make_scope: all labels"

files=("code/Module1/text1.java" "code/Module1/SubModule1/text2.java" "ansible/python-src/script.py" "code/tests/test.cs")

echo "rules:"
echo_assoc_array rules

echo ""
echo "files:"
echo "${files[@]}"

echo ""
res=$(make_scope rules files $after_label_path_depth)
expect="[DEV OPS QA]"
echo "make_scope rules files"
assert "$res" "$expect"

echo ""
echo "3.6. Test make_scope: empty scope due to no changes under labels"

files=("dir/subdir/text1.java" "dir/subdir/subsubdir/text2.java" "dir2/python-src/script.py" "dir3/tests/test.cs")

echo "rules:"
echo_assoc_array rules

echo ""
echo "files:"
echo "${files[@]}"

echo ""
res=$(make_scope rules files $after_label_path_depth)
expect=""
echo "make_scope rules files"
assert "$res" "$expect"

echo ""
echo "3.7. Test make_scope: QA label occurs once"

files=("code/autotests/ModuleUI1/yyyy" "code/autotests/ModuleUI1/yyyy" "code/autotests/ModuleUI1/yyyy" "dir/subdir/text4.cs")

echo "rules:"
echo_assoc_array rules

echo ""
echo "files:"
echo "${files[@]}"

echo ""
res=$(make_scope rules files $after_label_path_depth)
expect="[QA]"
echo "make_scope rules files"
assert "$res" "$expect"

echo ""
echo "3.8. Test make_scope: scope is common path with depth 2 due to no changes under labels"

files=("dir/subdir/text1.java" "dir/subdir/text2.java" "dir/subdir/text3.cs" "dir/subdir/text4.cs")

echo "rules:"
echo_assoc_array rules

echo ""
echo "files:"
echo "${files[@]}"

echo ""
res=$(make_scope rules files 2)
expect="dir/subdir:"
echo "make_scope rules files"
assert "$res" "$expect"

echo ""
echo "3.9. Test make_scope: One label, depth=1, Windows paths in rules"
declare -A rules=(
    ['code']="DEV"
    ['ansible\']="OPS"
    ['code\tests']="QA"
    ['code\autotests']="QA"
)

files=("code/Module1/text1.java" "code/Module1/SubModule1/text2.java" "ansible/python-src/script.py" "code/tests/test.cs")

echo "rules:"
echo_assoc_array rules

echo ""
echo "files:"
echo "${files[@]}"

echo ""
res=$(make_scope rules files $after_label_path_depth)
expect="[DEV OPS QA]"
echo "make_scope rules files"
assert "$res" "$expect"


echo ""
echo "3.10. Test make_scope: empty scope due to empty rules"
declare -A rules=()

files=("code/Module1/text1.java" "code/Module1/SubModule1/text2.java" "ansible/python-src/script.py" "code/tests/test.cs")

echo "rules:"
echo_assoc_array rules

echo ""
echo "files:"
echo "${files[@]}"

echo ""
res=$(make_scope rules files $after_label_path_depth)
expect=""
echo "make_scope rules files"
assert "$res" "$expect"