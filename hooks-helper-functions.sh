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