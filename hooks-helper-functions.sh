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
    
    path="$(path_into_linux_path "$1")"
    prefix="$(path_into_linux_path "$2")"
    
    # delete arbitrary amount of trailing slashes
    while [[ "$path" == */ ]]; do
        path="${path%/}"
    done

    while [[ "$prefix" == */ ]]; do
        prefix="${prefix%/}"
    done

    case $path in
        "$prefix")
            echo
            ;;
        "$prefix"/*)
            echo "${path#"$prefix"/}"
            ;;
        *)
            echo "$path"
            ;;
    esac
}

# Normalize to two dirs in the path
get_root_path() {
  IFS='/' read -r a b <<< "$1"
  echo "$a"
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

array_keys_to_linux_paths_without_trailing_slashes() {
    local -n rules_local=$1
    local -A normalized_local
    local original_key normalized_key

    for original_key in "${!rules_local[@]}"; do
      normalized_key=$(path_into_linux_path "$original_key")

      while [[ "$normalized_key" == */ ]]; do
        normalized_key="${normalized_key%/}"
      done

      normalized_local["$normalized_key"]="${rules_local[$original_key]}"
    done

    rules_local=()

    for key in "${!normalized_local[@]}"; do
        rules_local["$key"]="${normalized_local[$key]}"
    done
}

get_labels() {
  local -n rules_local=$1
  local -n changed_files=$2

  declare -A labels

  for file in "${changed_files[@]}"; do
    best_label=""
    best_len=0

    for rule in "${!rules_local[@]}"; do
        # to account for nested label cases (dir1 and dir1/subdir1), we take the longest one
        if [[ "$file" == "$rule" ]] || [[ "$file" == "$rule/"* ]]; then
            len=${#rule}

            if (( len > best_len )); then
                best_len=$len
                best_label="${rules_local[$rule]}"
            fi
        fi
    done

    if [[ -n "$best_label" ]]; then
        labels["$best_label"]=1
    fi
        
  done

  echo "${!labels[@]}" | tr ' ' '\n' | sort | tr '\n' ' '
}

make_scope() {
  local -n RULES=$1
  local -n changed_files=$2

  array_keys_to_linux_paths_without_trailing_slashes RULES

  declare -A labels

  for file in "${changed_files[@]}"; do
    best_label=""
    best_len=0

    for rule in "${!RULES[@]}"; do
        # to account for nested label cases (dir1 and dir1/subdir1), we take the longest one
        if [[ "$file" == "$rule" ]] || [[ "$file" == "$rule/"* ]]; then
            len=${#rule}

            if (( len > best_len )); then
                best_len=$len
                best_label="${RULES[$rule]}"
            fi
        fi
    done

    if [[ -n "$best_label" ]]; then
        labels["$best_label"]=1
    fi

  done

  labels_string=$(echo "${!labels[@]}" | tr ' ' '\n' | sort | tr '\n' ' ')

  echo "$labels_string"
}