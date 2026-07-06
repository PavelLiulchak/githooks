#!/bin/bash

common_path() {
  local paths=()

  for path in "$@"; do
    path="$(path_into_linux_path "$path")"
    paths+=("$path")
  done

  local IFS='/'

  read -ra firstPathBySegs <<< "${paths[0]}"
  local result=()

  for ((i=0; i<${#firstPathBySegs[@]}; i++)); do
    local segment="${firstPathBySegs[i]}"

    for path in "${paths[@]}"; do
      read -ra parts <<< "$path"

      if [[ "${parts[i]}" != "$segment" ]]; then
        (IFS=/; echo "${result[*]}")
        return
      fi
    done

    result+=("$segment")
  done

  (IFS=/; echo "${result[*]}")
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

path_into_linux_path() {
  local path="$1"
  path="${path//\\//}"

  echo "$path"
}

rule_paths_into_linux_paths() {
    local -n rules_local=$1
    local -A normalized_local

    for key in "${!rules_local[@]}"; do
        normalized_local["$(path_into_linux_path "$key")"]="${rules_local[$key]}"
    done

    rules_local=()

    for key in "${!normalized_local[@]}"; do
        rules_local["$key"]="${normalized_local[$key]}"
    done
}

get_labels() {
  local -n rules=$1
  local -n changed_files=$2

  declare -A labels

  for file in "${changed_files[@]}"; do
    best_label=""
    best_len=0

    for rule in "${!rules[@]}"; do
        # to account for nested label cases (dir1 and dir1/subdir1), we take the longest one
        if [[ "$file" == "$rule" ]] || [[ "$file" == "$rule/"* ]]; then
            len=${#rule}

            if (( len > best_len )); then
                best_len=$len
                best_label="${rules[$rule]}"
            fi
        fi
    done

    if [[ -n "$best_label" ]]; then
        labels["$best_label"]=1
    fi
        
  done

  echo "${!labels[@]}" | tr ' ' '\n' | sort | tr '\n' ' '
}