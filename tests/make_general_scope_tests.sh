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
echo "10. make_general_scope"

declare -A rules_group1=(
    ['code/IntegrationTests']="qa"
    ['code/IntegrationTests/Module1']="mod1"
    ['code/IntegrationTests/Module2']="mod2"
    ['code/IntegrationTests/Module3']="mod3"
)

declare -A rules_group2=(
    ['code/UIAutotests']="qa_ui"
    ['code/UIAutotests/Module1']="mod1"
    ['code/UIAutotests/Module2']="mod2"
    ['code/UIAutotests/Module3']="mod3"
)

declare -A rules_group3=(
    ['code']="dev"
    ['code/Module1']="mod1"
    ['code/Module2']="mod2"
    ['code/Module3']="mod3"
)

no_label_path_depth=1

echo "rules:"
echo "group1:"
echo_assoc_array rules_group1
echo "group2:"
echo_assoc_array rules_group2
echo "group3:"
echo_assoc_array rules_group3

echo ""
echo "10.1. Test make_scope: (dev mod1), one rules array is passed as argument"

files=("code/Module1/text1.java")
general_scope=

echo ""
echo "files: '${files[@]}'"

echo ""
make_general_scope files $no_label_path_depth general_scope rules_group3
expect="(dev mod1):"

assert "$general_scope" "$expect"


echo ""
echo "10.2. Test make_scope: (qa mod1), all rules arrays are passed as arguments"

files=("code/IntegrationTests/Module1/text1.java")
general_scope=

echo ""
echo "files: '${files[@]}'"

echo ""
make_general_scope files $no_label_path_depth general_scope rules_group1 rules_group2 rules_group3
expect="(qa mod1):"

assert "$general_scope" "$expect"


echo ""
echo "10.3. Test make_scope: (qa, qa_ui, dev)"

files=("code/text1.java" "code/text2.java" "code/IntegrationTests/text3.java" "code/IntegrationTests/text4.java")
files+=("code/UIAutotests/text5.java" "code/UIAutotests/text6.java")
general_scope=

echo ""
echo "files: '${files[@]}'"

echo ""
make_general_scope files $no_label_path_depth general_scope rules_group1 rules_group2 rules_group3
expect="(qa, qa_ui, dev):"

assert "$general_scope" "$expect"


echo ""
echo "10.4. Test make_scope: (qa mod1, qa_ui mod1, dev mod1)"

files=("code/Module1/text1.java" "code/IntegrationTests/Module1/text1.java" "code/UIAutotests/Module1/text1.java")
general_scope=

echo ""
echo "files: '${files[@]}'"

echo ""
make_general_scope files $no_label_path_depth general_scope rules_group1 rules_group2 rules_group3
expect="(qa mod1, qa_ui mod1, dev mod1):"

assert "$general_scope" "$expect"


echo ""
echo "10.5. Test make_scope: unlabled dir appears in scope"

files=("code/dir1/text1.java" "code/IntegrationTests/text2.java")
general_scope=

echo ""
echo "files: '${files[@]}'"

echo ""
make_general_scope files $no_label_path_depth general_scope rules_group1 rules_group2 rules_group3
# file text2.java appears in the scope due to the same logic, it is an appropriate side effect
expect="(qa text2.java, dev dir1):"

assert "$general_scope" "$expect"


echo ""
echo "10.6. Test make_scope: etc appears in the scope when unlabled change appears"

files=("code/Dir1/text1.java" "code/Dir2/text2.java" "code/IntegrationTests/Module1/text2.java")
files+=("code/UIAutotests/Dir1/text1.java" "python-src/Dir1/script.py")
general_scope=

echo ""
echo "files: '${files[@]}'"

echo ""
make_general_scope files $no_label_path_depth general_scope rules_group1 rules_group2 rules_group3
expect="(qa mod1, qa_ui Dir1, dev, etc):"

assert "$general_scope" "$expect"


echo ""
echo "10.7. Test make_scope: common path of unlabled changes appears"

files=("python-src/Dir1/script1.py" "python-src/Dir1/script2.py")
general_scope=

echo ""
echo "files: '${files[@]}'"

echo ""
make_general_scope files $no_label_path_depth general_scope rules_group1 rules_group2 rules_group3
expect="(python-src):"

assert "$general_scope" "$expect"


echo ""
echo "10.8. Test make_scope: no common changes, scope is empty"

files=("python-src/Dir1/script1.py" "ansible/Dir1/env.j2")
general_scope=

echo ""
echo "files: '${files[@]}'"

echo ""
make_general_scope files $no_label_path_depth general_scope rules_group1 rules_group2 rules_group3
expect=""

assert "$general_scope" "$expect"


echo ""
echo "10.9. Test make_scope: files are empty, scope is empty"

files=()
general_scope=

echo ""
echo "files: '${files[@]}'"

echo ""
make_general_scope files $no_label_path_depth general_scope rules_group1 rules_group2 rules_group3
expect=""

assert "$general_scope" "$expect"


echo ""
echo "10.10. Test make_scope: there is no rules, scope is built as common path"

files=("python-src/Dir1/script1.py" "python-src/Dir1/script2.py")
general_scope=

echo ""
echo "files: '${files[@]}'"

echo ""
make_general_scope files $no_label_path_depth general_scope
expect="(python-src):"

assert "$general_scope" "$expect"


echo ""
echo "10.11. Test make_scope: scope is built as common path, no_label_path_depth = 2"
no_label_path_depth=2

files=("python-src/Dir1/script1.py" "python-src/Dir1/script2.py")
general_scope=

echo ""
echo "files: '${files[@]}'"

echo ""
make_general_scope files $no_label_path_depth general_scope rules_group1 rules_group2 rules_group3
expect="(python-src/Dir1):"

assert "$general_scope" "$expect"
no_label_path_depth=1


echo ""
echo "10.12. Test make_scope: scope is built as common path, no_label_path_depth = 2"
no_label_path_depth=2

files=("code/UIAutotests/Dir1/SubDir1/text1.java" "python-src/Dir1/script.py")
general_scope=

echo ""
echo "files: '${files[@]}'"

echo ""
make_general_scope files $no_label_path_depth general_scope rules_group1 rules_group2 rules_group3
expect="(qa_ui Dir1/SubDir1, etc):"

assert "$general_scope" "$expect"
no_label_path_depth=1