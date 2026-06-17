#!/bin/bash

common_path() {
  local paths=("$@")
  local IFS='/'

  read -ra firstPathBySegs <<< "${paths[0]}"
  local result=()

  for ((i=0; i<${#firstPathBySegs[@]}; i++)); do
    local segment="${firstPathBySegs[i]}"

    for path in "${paths[@]}"; do
      read -ra parts <<< "$path"

      [[ "${parts[i]}" != "$segment" ]] && {
        echo "${result[*]}" | tr ' ' '/'
        return
      }
    done

    result+=("$segment")
  done

  echo "${result[*]}" | tr ' ' '/'
}

# strips subpath to $2
strip_path_before() {
  local path="$1"
  local dir="$2"

  IFS='/' read -ra parts <<< "$path"

  for i in "${!parts[@]}"; do
    if [[ "${parts[i]}" == "$dir" ]]; then
      echo "${parts[@]:i}" | tr ' ' '/'
      return
    fi
  done

  echo "$path"
}

# Normalize to two dirs in the path
normalize_path() {
  IFS='/' read -r a b c <<< "$1"
  if [ -z "$b" ]; then
    echo "$a"
  else
    echo "$a/$b"
  fi
}

make_scope() {
  local path="$1"
  local dev_dir="$2"
  local qa_dir="$3"

  IFS='/' read -r root module <<< "$path"

  case "$root" in
    "$dev_dir")
      if [ -n "$module" ]; then
        echo "[DEV] $module"
      else
        echo "[DEV]"
      fi
      ;;
    "$qa_dir")
      if [ -n "$module" ]; then
        echo "[QA] $module"
      else
        echo "[QA]"
      fi
      ;;
    *)
      echo ""
      ;;
  esac
}

get_jira_id_from_branch_name() {
    BRANCH=$1
    JIRA_PROJECT_KEY=$2

    JIRAID=$(echo "$BRANCH" \
  | grep -oiE "$JIRA_PROJECT_KEY[-_]?[0-9]+" \
  | head -n1 \
  | tr '[:lower:]' '[:upper:]')

[ -n "$JIRAID" ] && JIRAID=$(echo "$JIRAID" | sed -E "s/${JIRA_PROJECT_KEY}[-_]?([0-9]+)/${JIRA_PROJECT_KEY}-\1/")

echo "$JIRAID"
}

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