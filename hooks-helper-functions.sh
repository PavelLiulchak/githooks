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

get_cut_path() {
    local path="$1"
    local depth="$2"

    if [[ ! "$depth" =~ ^[0-9]+$ ]]; then
        echo "Error: depth must be a non-negative integer" >&2
        return 1
    fi

    while [[ "$path" == */ ]]; do
        path="${path%/}"
    done

    local IFS='/'
    local -a parts
    read -ra parts <<< "$path"

    local limit=$depth
    (( limit > ${#parts[@]} )) && limit=${#parts[@]}

    local result=""
    local i

    for ((i = 0; i < limit; i++)); do
        [[ -n "$result" ]] && result+="/"
        result+="${parts[i]}"
    done

    echo "$result"
}

get_jira_id_from_branch_name() {
    local branch=$1
    local jira_project_key=$2
    local jiraid

    jiraid=$(echo "$branch" \
        | grep -oiE "${jira_project_key}[-_]*[0-9]+" \
        | head -n1 \
        | tr '[:lower:]' '[:upper:]')

    if [[ -n "$jiraid" ]]; then
        jiraid=$(echo "$jiraid" | sed -E "s/${jira_project_key}[-_]*([0-9]+)/${jira_project_key}-\1/")
    fi

    echo "$jiraid"
}

path_into_linux_path() {
  local path="$1"
  path="${path//\\//}"

  echo "$path"
}

array_keys_to_linux_paths_without_trailing_slashes() {
    local -n rules_ref_ref=$1
    local -A normalized
    local original_key normalized_key

    for original_key in "${!rules_ref_ref[@]}"; do
      normalized_key=$(path_into_linux_path "$original_key")

      while [[ "$normalized_key" == */ ]]; do
        normalized_key="${normalized_key%/}"
      done

      normalized["$normalized_key"]="${rules_ref_ref[$original_key]}"
    done

    rules_ref_ref=()

    for key in "${!normalized[@]}"; do
        rules_ref_ref["$key"]="${normalized[$key]}"
    done
}

make_scope() {
  local -n rules_ref=$1
  local -n changed_files_ref=$2
  local after_label_path_depth=$3
  local key_path=
  local common_path=
  local common_stripped=
  local common_normalized=
  local scope=

  array_keys_to_linux_paths_without_trailing_slashes rules_ref

  declare -A labels

  for file in "${changed_files_ref[@]}"; do
    best_label=""
    best_path=""
    best_len=0

    for path in "${!rules_ref[@]}"; do
        # to account for nested label cases (dir1 and dir1/subdir1), we take the longest one
        if [[ "$file" == "$path" ]] || [[ "$file" == "$path/"* ]]; then
            len=${#path}

            if (( len > best_len )); then
                best_len=$len
                best_label="${rules_ref[$path]}"
                best_path="$path"
            fi
        fi
    done

    if [[ -n "$best_label" ]]; then
        labels["$best_label"]=$best_path
    fi

  done

  labels_string=$(echo "${!labels[@]}" | tr ' ' '\n' | sort | tr '\n' ' ')
  # remove trailing spaces in the end
  labels_string="${labels_string%"${labels_string##*[! ]}"}"

  if [[ -n "$labels_string" ]]; then
    scope="[$labels_string]"
  fi

  if [[ ${#labels[@]} -eq 0 ]]; then

    common_path=$(common_path "${changed_files_ref[@]}")
    common_normalized=$(get_cut_path "$common_path" "$after_label_path_depth")

    if [[ -n "$common_normalized" ]]; then
      common_normalized="$common_normalized:"
    fi

    scope="$common_normalized"
  fi

  if [[ ${#labels[@]} -eq 1 ]]; then

    key_path="${labels[@]}"
    common_path=$(common_path "${changed_files_ref[@]}")
    common_stripped=$(strip_path_before "$common_path" "$key_path")
    common_normalized=$(get_cut_path "$common_stripped" "$after_label_path_depth")

    if [[ -n "$common_normalized" ]]; then
      common_normalized=" $common_normalized:"
    fi

    scope="$scope$common_normalized"
  fi

  echo "$scope"
}