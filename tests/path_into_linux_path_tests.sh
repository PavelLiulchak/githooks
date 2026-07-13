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
echo "0. path_into_linux_path"

echo ""
echo "0.1. Test path_into_linux_path"
arg="C:\Users\Test\project"
expect="C:/Users/Test/project"
res=$(path_into_linux_path "$arg")
echo "path_into_linux_path \"$arg\""
assert "$res" "$expect"


#########################################
echo ""
echo "0.2. Test path_into_linux_path: path with space"
arg="C:\Users\Test User\My Project\src"
expect="C:/Users/Test User/My Project/src"
res=$(path_into_linux_path "$arg")
echo "path_into_linux_path \"$arg\""
assert "$res" "$expect"


#########################################
echo ""
echo "0.3. Test path_into_linux_path: linux path"
arg="/home/user/project/src"
expect="$arg"
res=$(path_into_linux_path "$arg")
echo "path_into_linux_path \"$arg\""
assert "$res" "$expect"


#########################################
echo ""
echo "0.4. Test path_into_linux_path: mixed path"
arg="C:\Users/Test\project/src"
expect="C:/Users/Test/project/src"
res=$(path_into_linux_path "$arg")
echo "path_into_linux_path \"$arg\""
assert "$res" "$expect"


#########################################
echo ""
echo "0.5. Test path_into_linux_path: Windows drive root"
arg="C:\\"
expect="C:/"
res=$(path_into_linux_path "$arg")
echo "path_into_linux_path \"$arg\""
assert "$res" "$expect"


#########################################
echo ""
echo "0.6. Test path_into_linux_path: single slash"
arg="\\"
expect="/"
res=$(path_into_linux_path "$arg")
echo "path_into_linux_path \"$arg\""
assert "$res" "$expect"


#########################################
echo ""
echo "0.7. Test path_into_linux_path: empty arg"
arg=""
expect=""
res=$(path_into_linux_path "$arg")
echo "path_into_linux_path \"$arg\""
assert "$res" "$expect"


#########################################
echo ""
echo "0.8. Test path_into_linux_path: spec symbols"
arg="C:\Users\Test\foo-bar_123.txt"
expect="C:/Users/Test/foo-bar_123.txt"
res=$(path_into_linux_path "$arg")
echo "path_into_linux_path \"$arg\""
assert "$res" "$expect"