#!/bin/bash

pushd "$(dirname "$(which "$0")")" >/dev/null
script_dir="$(pwd -P)"
popd >/dev/null

helper_functions_script="$script_dir/hooks-helper-functions.sh"

if [[ ! -f "$helper_functions_script" ]]; then
echo "$helper_functions_script is not found, nothing to source, exiting..."
exit 1
fi

source $helper_functions_script

assert() {
  res=$1
  expect=$2

  echo "res = $res"
  echo "expect = $expect"

  if [[ $res == $expect ]]; then
    GREEN=$(tput setaf 2)
    RESET=$(tput sgr0)

    echo "${GREEN}Success${RESET}"
  else
    RED=$(tput setaf 1)
    RESET=$(tput sgr0)

    echo "${RED}Failed${RESET}"
  fi
}

## tests
echo ""
echo "1. common_path"

echo ""
echo "1.1. Test common_path"
arg1="source_dir/dir/subdir"
arg2="source_dir/dir"
expect="source_dir/dir"
res=$(common_path $arg1 $arg2)
echo "common_path \"$arg1\" \"$arg2\""
assert $res $expect

echo ""
echo "1.2 Test common_path: returns root dir"
arg1="source_dir/dir/subdir"
arg2="source_dir"
expect=$arg2
res=$(common_path $arg1 $arg2)
echo "common_path \"$arg1\" \"$arg2\""
assert $res $expect

echo ""
echo "1.3. Test common_path: path contains \"/\" in the end"
arg1="source_dir/dir/subdir"
arg2="source_dir/"
expect="source_dir"
res=$(common_path $arg1 $arg2)
echo "common_path \"$arg1\" \"$arg2\""
assert $res $expect


echo ""
echo "1.4. Test common_path: returns root dir (different args order)"
arg1="source_dir"
arg2="source_dir/dir/subdir"
expect=$arg1
res=$(common_path $arg1 $arg2)
echo "common_path \"$arg1\" \"$arg2\""
assert $res $expect


echo ""
echo "1.5. Test common_path: same paths"
arg1="source_dir/dir/subdir"
expect=$arg1
res=$(common_path $arg1 $arg1)
echo "common_path \"$arg1\" \"$arg1\""
assert $res $expect


echo ""
echo "1.6. Test common_path: returns emptiness (no paths intersection)"
arg1="SOURCE_DIR/dir/subdir"
arg2="source_dir/dir/subdir"
expect=""
res=$(common_path $arg1 $arg2)
echo "common_path \"$arg1\" \"$arg2\""
assert $res $expect


echo ""
echo "1.7. Test common_path: returns non empty path"
arg1=""
arg2="source_dir/dir/subdir"
expect="$arg2"
res=$(common_path $arg1 $arg2)
echo "common_path \"$arg1\" \"$arg2\""
assert $res $expect


echo ""
echo "1.8. Test common_path: returns non empty path (different args order)"
arg1="source_dir/dir/subdir"
arg2=""
expect="$arg1"
res=$(common_path $arg1 $arg2)
echo "common_path \"$arg1\" \"$arg2\""
assert $res $expect