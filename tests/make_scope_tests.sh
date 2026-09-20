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
    ['code']="dev"
    ['code/Module1']="mod1"
    ['code/Module2']="mod2"
    ['code/Module3']="mod3"
)
no_label_path_depth=1

echo ""
echo "3.1. Test make_scope: One main label"

files=("code/Dir1/text1.java" "code/Dir2/SubDir2/text2.java" "code/Dir3/SubDir3/text3.java")
expected_remaining_files=()

echo "rules:"
echo_assoc_array rules

echo ""
echo "files: '${files[@]}'"
echo "expected_remaining_files: '${expected_remaining_files[@]}'"

echo ""
res=
make_scope files $no_label_path_depth res rules
expect="dev"
echo "make_scope files $no_label_path_depth res rules"
assert "$res" "$expect"
echo "assert arrays: files expected_remaining_files"
assert_array_equals files expected_remaining_files


#########################################
echo ""
echo "3.2. Test make_scope: Boundary check, one main label + common_path of not labeled one, no_label_path_depth = 1"

files=("code/Dir1/SubDir1/SubSubDir1/text1.java")
expected_remaining_files=()

echo "rules:"
echo_assoc_array rules

echo ""
echo "files: '${files[@]}'"
echo "expected_remaining_files: '${expected_remaining_files[@]}'"

echo ""
res=
make_scope files $no_label_path_depth res rules
expect="dev Dir1"
echo "make_scope files $no_label_path_depth res rules"
assert "$res" "$expect"
echo "assert arrays: files expected_remaining_files"
assert_array_equals files expected_remaining_files


#########################################
echo ""
echo "3.3. Test make_scope: One main label + common_path of not labeled ones, no_label_path_depth = 1"

files=("code/Dir1/SubDir1/SubSubDir1/text1.java" "code/Dir1/SubDir1/SubSubDir1/text2.java" "code/Dir1/SubDir1/SubSubDir1/text3.java")
expected_remaining_files=()

echo "rules:"
echo_assoc_array rules

echo ""
echo "files: '${files[@]}'"
echo "expected_remaining_files: '${expected_remaining_files[@]}'"

echo ""
res=
make_scope files $no_label_path_depth res rules
expect="dev Dir1"
echo "make_scope files $no_label_path_depth res rules"
assert "$res" "$expect"
echo "assert arrays: files expected_remaining_files"
assert_array_equals files expected_remaining_files
no_label_path_depth=1


#########################################
echo ""
echo "3.4. Test make_scope: One main label + common_path of not labeled ones, no_label_path_depth = 2"
no_label_path_depth=2

files=("code/Dir1/SubDir1/SubSubDir1/text1.java" "code/Dir1/SubDir1/SubSubDir1/text2.java" "code/Dir1/SubDir1/SubSubDir1/text3.java")
expected_remaining_files=()

echo "rules:"
echo_assoc_array rules

echo ""
echo "files: '${files[@]}'"
echo "expected_remaining_files: '${expected_remaining_files[@]}'"

echo ""
res=
make_scope files $no_label_path_depth res rules
expect="dev Dir1/SubDir1"
echo "make_scope files $no_label_path_depth res rules"
assert "$res" "$expect"
echo "assert arrays: files expected_remaining_files"
assert_array_equals files expected_remaining_files
no_label_path_depth=1


#########################################
echo ""
echo "3.5. Test make_scope: One main label + common_path of not labeled ones, no_label_path_depth = 100"
no_label_path_depth=100

files=("code/Dir1/SubDir1/SubSubDir1/text1.java" "code/Dir1/SubDir1/SubSubDir1/text2.java" "code/Dir1/SubDir1/SubSubDir1/text3.java")
expected_remaining_files=()

echo "rules:"
echo_assoc_array rules

echo ""
echo "files: '${files[@]}'"
echo "expected_remaining_files: '${expected_remaining_files[@]}'"

echo ""
res=
make_scope files $no_label_path_depth res rules
expect="dev Dir1/SubDir1/SubSubDir1"
echo "make_scope files $no_label_path_depth res rules"
assert "$res" "$expect"
echo "assert arrays: files expected_remaining_files"
assert_array_equals files expected_remaining_files
no_label_path_depth=1


#########################################
echo ""
echo "3.6. Test make_scope: changes are under all labels"

files=("code/text.java" "code/Module1/text1.java" "code/Module2/SubModule2/text2.java" "code/Module3/SubModule3/text3.java")
expected_remaining_files=()

echo "rules:"
echo_assoc_array rules

echo ""
echo "files: '${files[@]}'"
echo "expected_remaining_files: '${expected_remaining_files[@]}'"

echo ""
res=
make_scope files $no_label_path_depth res rules
expect="dev"
echo "make_scope files $no_label_path_depth res rules"
assert "$res" "$expect"
echo "assert arrays: files expected_remaining_files"
assert_array_equals files expected_remaining_files


#########################################
echo ""
echo "3.7. Test make_scope: Boundary check, one change is under main label"

files=("code/text.java")
expected_remaining_files=()

echo "rules:"
echo_assoc_array rules

echo ""
echo "files: '${files[@]}'"
echo "expected_remaining_files: '${expected_remaining_files[@]}'"

echo ""
res=
make_scope files $no_label_path_depth res rules
expect="dev text.java"
echo "make_scope files $no_label_path_depth res rules"
assert "$res" "$expect"
echo "assert arrays: files expected_remaining_files"
assert_array_equals files expected_remaining_files


#########################################
echo ""
echo "3.8. Test make_scope: all changes are under one label"

files=("code/Module1/text1.java" "code/Module1/SubModule1/text2.java" "code/Module1/SubModule1/SubSubModule1/text3.java")
expected_remaining_files=()

echo "rules:"
echo_assoc_array rules

echo ""
echo "files: '${files[@]}'"
echo "expected_remaining_files: '${expected_remaining_files[@]}'"

echo ""
res=
make_scope files $no_label_path_depth res rules
expect="dev mod1"
echo "make_scope files $no_label_path_depth res rules"
assert "$res" "$expect"
echo "assert arrays: files expected_remaining_files"
assert_array_equals files expected_remaining_files


########################################
echo ""
echo "3.9. Test make_scope: Boundary check, one change is under one label"

files=("code/Module1/text1.java")
expected_remaining_files=()

echo "rules:"
echo_assoc_array rules

echo ""
echo "files: '${files[@]}'"
echo "expected_remaining_files: '${expected_remaining_files[@]}'"

echo ""
res=
make_scope files $no_label_path_depth res rules
expect="dev mod1"
echo "make_scope files $no_label_path_depth res rules"
assert "$res" "$expect"
echo "assert arrays: files expected_remaining_files"
assert_array_equals files expected_remaining_files


#########################################
echo ""
echo "3.10. Test make_scope: some changes are under main label, one is not"

files=("code/Module1/text1.java" "code/Module2/SubModule2/text2.java" "dir/subdir/text3.java")
expected_remaining_files=("dir/subdir/text3.java")

echo "rules:"
echo_assoc_array rules

echo ""
echo "files: '${files[@]}'"
echo "expected_remaining_files: '${expected_remaining_files[@]}'"

echo ""
res=
make_scope files $no_label_path_depth res rules
expect="dev"
echo "make_scope files $no_label_path_depth res rules"
assert "$res" "$expect"
echo "assert arrays: files expected_remaining_files"
assert_array_equals files expected_remaining_files


#########################################
echo ""
echo "3.11. Test make_scope: some changes are under one label, one is not"

files=("code/Module1/text1.java" "code/Module1/SubModule1/text2.java" "dir/subdir/text3.java")
expected_remaining_files=("dir/subdir/text3.java")

echo "rules:"
echo_assoc_array rules

echo ""
echo "files: '${files[@]}'"
echo "expected_remaining_files: '${expected_remaining_files[@]}'"

echo ""
res=
make_scope files $no_label_path_depth res rules
expect="dev mod1"
echo "make_scope files $no_label_path_depth res rules"
assert "$res" "$expect"
echo "assert arrays: files expected_remaining_files"
assert_array_equals files expected_remaining_files


#########################################
echo ""
echo "3.12. Test make_scope: empty scope due to no changes under labels"

files=("dir/subdir/text1.java" "dir/subdir/subsubdir/text2.java" "dir/subdir/text2.java")
expected_remaining_files=("${files[@]}")

echo "rules:"
echo_assoc_array rules

echo ""
echo "files: '${files[@]}'"
echo "expected_remaining_files: '${files[@]}'"

echo ""
res=
make_scope files $no_label_path_depth res rules
expect=""
echo "make_scope files $no_label_path_depth res rules"
assert "$res" "$expect"
echo "assert arrays: files expected_remaining_files"
assert_array_equals files expected_remaining_files


#########################################
echo ""
echo "3.13. Test make_scope: One label, depth=1, Windows paths in rules"
declare -A rules=(
    ['code']="dev"
    ['code\Module1']="mod1"
    ['code\Module2']="mod2"
    ['code\Module3']="mod3"
)

files=("code/Module1/text1.java" "code/Module1/SubModule1/text2.java" "code/Module1/SubModule1/SubSubModule1/text3.java")
expected_remaining_files=()

echo "rules:"
echo_assoc_array rules

echo ""
echo "files: '${files[@]}'"
echo "expected_remaining_files: '${expected_remaining_files[@]}'"

echo ""
res=
make_scope files $no_label_path_depth res rules
expect="dev mod1"
echo "make_scope files $no_label_path_depth res rules"
assert "$res" "$expect"
echo "assert arrays: files expected_remaining_files"
assert_array_equals files expected_remaining_files


#########################################
echo ""
echo "3.14. Test make_scope: one label rule"
declare -A rules=(
    ['code']="dev"
)

files=("code/Module1/text1.java" "code/Module1/SubModule1/text2.java" "code/tests/test.cs")
expected_remaining_files=()

echo "rules:"
echo_assoc_array rules

echo ""
echo "files: '${files[@]}'"
echo "expected_remaining_files: '${expected_remaining_files[@]}'"

echo ""
res=
make_scope files $no_label_path_depth res rules
expect="dev"
echo "make_scope files $no_label_path_depth res rules"
assert "$res" "$expect"
echo "assert arrays: files expected_remaining_files"
assert_array_equals files expected_remaining_files


#########################################
echo ""
echo "3.15. Test make_scope: one label rule, files are empty"
declare -A rules=(
    ['code']="dev"
)

files=()
expected_remaining_files=()

echo "rules:"
echo_assoc_array rules

echo ""
echo "files: '${files[@]}'"
echo "expected_remaining_files: '${expected_remaining_files[@]}'"

echo ""
res=
make_scope files $no_label_path_depth res rules
expect=""
echo "make_scope files $no_label_path_depth res rules"
assert "$res" "$expect"
echo "assert arrays: files expected_remaining_files"
assert_array_equals files expected_remaining_files



#########################################
echo ""
echo "3.16. Test make_scope: empty scope due to empty rules"
declare -A rules=()

files=("code/Module1/text1.java" "code/Module1/SubModule1/text2.java" "code/tests/test.cs")
expected_remaining_files=("${files[@]}")

echo "rules:"
echo_assoc_array rules

echo ""
echo "files: '${files[@]}'"
echo "expected_remaining_files: '${expected_remaining_files[@]}'"

echo ""
res=
make_scope files $no_label_path_depth res rules
expect=""
echo "make_scope files $no_label_path_depth res rules"
assert "$res" "$expect"
echo "assert arrays: files expected_remaining_files"
assert_array_equals files expected_remaining_files


#########################################
echo ""
echo "3.17. Test make_scope: main rule is empty, all changes are under one sublabel"
declare -A rules=(
    ['code']=""
    ['code/Module1']="mod1"
    ['code/Module2']="mod2"
)

files=("code/Module1/SubModule1/text1.java" "code/Module1/SubModule1/text2.java")
expected_remaining_files=()

echo "rules:"
echo_assoc_array rules

echo ""
echo "files: '${files[@]}'"
echo "expected_remaining_files: '${expected_remaining_files[@]}'"

echo ""
res=
make_scope files $no_label_path_depth res rules
expect="mod1"
echo "make_scope files $no_label_path_depth res rules"
assert "$res" "$expect"
echo "assert arrays: files expected_remaining_files"
assert_array_equals files expected_remaining_files

#########################################
echo ""
echo "3.18. Test make_scope: main rule is empty, empty scope due to no submodules intersection"

files=("code/Module1/SubModule1/text1.java" "code/Module2/SubModule2/text2.java" "code/tests/test.cs")
expected_remaining_files=()

echo "rules:"
echo_assoc_array rules

echo ""
echo "files: '${files[@]}'"
echo "expected_remaining_files: '${expected_remaining_files[@]}'"

echo ""
res=
make_scope files $no_label_path_depth res rules
expect=""
echo "make_scope files $no_label_path_depth res rules"
assert "$res" "$expect"
echo "assert arrays: files expected_remaining_files"
assert_array_equals files expected_remaining_files


#########################################
echo ""
echo "3.19. Test make_scope: main rule is empty, empty scope due to no submodules intersection, one file is out of rules"

files=("code/Module1/SubModule1/text1.java" "code/Module2/SubModule2/text2.java" "dir/subdir/test.cs")
expected_remaining_files=("dir/subdir/test.cs")

echo "rules:"
echo_assoc_array rules

echo ""
echo "files: '${files[@]}'"
echo "expected_remaining_files: '${expected_remaining_files[@]}'"

echo ""
res=
make_scope files $no_label_path_depth res rules
expect=""
echo "make_scope files $no_label_path_depth res rules"
assert "$res" "$expect"
echo "assert arrays: files expected_remaining_files"
assert_array_equals files expected_remaining_files


#########################################
# When a team works within own single directory
echo ""
echo "3.20. Test make_scope: top level, main rule is empty"
declare -A rules=(
    ['.']=""
    ['Module1']="mod1"
    ['Module2']="mod2"
)

files=("Module1/SubModule1/text1.java" "Module1/SubModule1/text2.java")
expected_remaining_files=()

echo "rules:"
echo_assoc_array rules

echo ""
echo "files: '${files[@]}'"
echo "expected_remaining_files: '${expected_remaining_files[@]}'"

echo ""
res=
make_scope files $no_label_path_depth res rules
expect="mod1"
echo "make_scope files $no_label_path_depth res rules"
assert "$res" "$expect"
echo "assert arrays: files expected_remaining_files"
assert_array_equals files expected_remaining_files


#########################################
echo ""
echo "3.21. Test make_scope: top level, main rule is empty"

files=("dir/subdir/test.cs" "dir/subdir2/test2.cs")
expected_remaining_files=()

echo "rules:"
echo_assoc_array rules

echo ""
echo "files: '${files[@]}'"
echo "expected_remaining_files: '${expected_remaining_files[@]}'"

echo ""
res=
make_scope files $no_label_path_depth res rules
expect="dir"
echo "make_scope files $no_label_path_depth res rules"
assert "$res" "$expect"
echo "assert arrays: files expected_remaining_files"
assert_array_equals files expected_remaining_files


#########################################
echo ""
echo "3.22. Test make_scope: top level, main rule is empty, empty scope due to no submodules intersection"

files=("Module1/SubModule1/text1.java" "Module2/SubModule2/text2.java" "dir/subdir/test.cs")
expected_remaining_files=()

echo "rules:"
echo_assoc_array rules

echo ""
echo "files: '${files[@]}'"
echo "expected_remaining_files: '${expected_remaining_files[@]}'"

echo ""
res=
make_scope files $no_label_path_depth res rules
expect=""
echo "make_scope files $no_label_path_depth res rules"
assert "$res" "$expect"
echo "assert arrays: files expected_remaining_files"
assert_array_equals files expected_remaining_files


echo ""
echo "3.23. Test make_scope: top level, main rule is empty"
declare -A rules=(
    ['.']=""
    ['Module1']="mod1"
    ['Module1/SubModule1']="mod1-submod1"
    ['Module1/SubModule1.2']="mod1-submod1.2"
    ['Module2']="mod2"
)

files=("Module1/SubModule1/text1.java" "Module1/SubModule1.2/text2.java")
expected_remaining_files=()

echo "rules:"
echo_assoc_array rules

echo ""
echo "files: '${files[@]}'"
echo "expected_remaining_files: '${expected_remaining_files[@]}'"

echo ""
res=
make_scope files $no_label_path_depth res rules
expect="mod1"
echo "make_scope files $no_label_path_depth res rules"
assert "$res" "$expect"
echo "assert arrays: files expected_remaining_files"
assert_array_equals files expected_remaining_files


echo ""
echo "3.24. Test make_scope: top level, main rule is empty"
declare -A rules=(
    ['.']=""
    ['Module1']="mod1"
    ['Module1/SubModule1']="mod1-submod1"
    ['Module1/SubModule1.2']="mod1-submod1.2"
    ['Module2']="mod2"
)

files=("Module1/SubModule1/text1.java" "Module1/SubModule1/text2.java")
expected_remaining_files=()

echo "rules:"
echo_assoc_array rules

echo ""
echo "files: '${files[@]}'"
echo "expected_remaining_files: '${expected_remaining_files[@]}'"

echo ""
res=
make_scope files $no_label_path_depth res rules
expect="mod1-submod1"
echo "make_scope files $no_label_path_depth res rules"
assert "$res" "$expect"
echo "assert arrays: files expected_remaining_files"
assert_array_equals files expected_remaining_files


#########################################
echo ""
echo "3.25. Test make_scope: rule with not empty path but empty label"
declare -A rules_group1=(
    ['code']="dev"
    ['code/Module1']="" # if no label, common path should be found
    ['code/Module2']="mod2"
    ['code/Module3']="mod3"
)
no_label_path_depth=1

files=("code/Module1/text1.java")
expected_remaining_files=()

echo "rules_group1:"
echo_assoc_array rules_group1

echo ""
echo "files: '${files[@]}'"
echo "expected_remaining_files: '${expected_remaining_files[@]}'"

echo ""
res=
make_scope files $no_label_path_depth res rules_group1
expect="dev Module1"
echo "make_scope files $no_label_path_depth res rules_group1"
assert "$res" "$expect"
echo "assert arrays: files expected_remaining_files"
assert_array_equals files expected_remaining_files


#########################################
echo ""
echo "3.26. Test make_scope: spaces in key and path"
declare -A rules_group1=(
    ['code']="dev"
    ['code/Module and components']="mod&comp"
    ['code/Module2']="mod2"
    ['code/Module3']="mod3"
)
no_label_path_depth=1

files=("code/Module and components/text.java")
expected_remaining_files=()

echo "rules_group1:"
echo_assoc_array rules_group1

echo ""
echo "files: '${files[@]}'"
echo "expected_remaining_files: '${expected_remaining_files[@]}'"

echo ""
res=
make_scope files $no_label_path_depth res rules_group1
expect="dev mod&comp"
echo "make_scope files $no_label_path_depth res rules_group1"
assert "$res" "$expect"
echo "assert arrays: files expected_remaining_files"
assert_array_equals files expected_remaining_files


#########################################
echo ""
echo "3.27. Test make_scope: Cyrillic"
declare -A rules_group1=(
    ['код']="код"
    ['код/Модуль и компоненты']="Мод и Комп"
    ['код/Модуль2']="Мод2"
    ['код/Модуль3']="Мод3"
)
no_label_path_depth=1

files=("код/Модуль и компоненты/text.java")
expected_remaining_files=()

echo "rules_group1:"
echo_assoc_array rules_group1

echo ""
echo "files: '${files[@]}'"
echo "expected_remaining_files: '${expected_remaining_files[@]}'"

echo ""
res=
make_scope files $no_label_path_depth res rules_group1
expect="код Мод и Комп"
echo "make_scope files $no_label_path_depth res rules_group1"
assert "$res" "$expect"
echo "assert arrays: files expected_remaining_files"
assert_array_equals files expected_remaining_files