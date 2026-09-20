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
    local -n rules_ref_ref_ref=$1
    local -A normalized
    local original_key normalized_key

    for original_key in "${!rules_ref_ref_ref[@]}"; do
      normalized_key=$(path_into_linux_path "$original_key")

      while [[ "$normalized_key" == */ ]]; do
        normalized_key="${normalized_key%/}"
      done

      normalized["$normalized_key"]="${rules_ref_ref_ref[$original_key]}"
    done

    rules_ref_ref_ref=()

    for key in "${!normalized[@]}"; do
        rules_ref_ref_ref["$key"]="${normalized[$key]}"
    done
}

# check me and test
strip_scope_and_path() {
    local msg=$1
    local scope=$2

    if [[ -z "$scope" ]]; then
        echo "$msg"
        return
    fi

    case "$msg" in
        "$scope "*)
            echo "${msg#"$scope "}"
            ;;
        "$scope"*)
            echo "${msg#"$scope"}"
            ;;
        *)
            echo "$msg"
            ;;
    esac
}

replace_scope() {
    local text="$1"
    local replacement="$2"

    text="${text/\(*\):/$replacement}"

    text="${text#"${text%%[![:space:]]*}"}"

    echo "$text"
}

# test me, delete me?
deduplicate_specific_label() {
    local -n arr=$1
    local label=$2

    local found=false
    local -a result=()

    for item in "${arr[@]}"; do
        if [[ "$item" == "$label" ]]; then
            if ! $found; then
                result+=("$item")
                found=true
            fi
        else
            result+=("$item")
        fi
    done

    arr=("${result[@]}")
}


get_entry_with_shortest_key() {
    local -n map=$1
    local -n key_ref=$2
    local -n value_ref=$3

    key_ref=
    value_ref=

    local key

    for key in "${!map[@]}"; do
        if [[ -z $key_ref || ${#key} -lt ${#key_ref} ]]; then
            key_ref=$key
            value_ref=${map[$key]}
        fi
    done
}


make_scope() {
  local -n changed_files_ref_ref=$1
  local no_label_path_depth=$2
  # be careful with the referenced variable name (see below)
  local -n scope_ref=$3
  local -n rules_ref_ref=$4

  local root_dir_path_sign="."

  array_keys_to_linux_paths_without_trailing_slashes rules_ref_ref

  local main_path=
  local main_label=
  get_entry_with_shortest_key rules_ref_ref main_path main_label

  local -a files_under_rules=()
  local -a remaining_files=()

  for file in "${changed_files_ref_ref[@]}"; do
    if [[ "$file" == "$main_path" ]] || [[ "$file" == "$main_path/"* ]] || [[ "$main_path" == "$root_dir_path_sign" ]]; then
      files_under_rules+=("$file")
    else
      remaining_files+=("$file")
    fi
  done

  local common_path=$(common_path "${files_under_rules[@]}")

  local label=""
  local max_path_len=0

  for path in "${!rules_ref_ref[@]}"; do

    if [[ "$main_path" == "$path" ]]; then
      continue
    fi

    # to account for nested label cases (dir1 and dir1/subdir1), we take the longest one with it label
    if [[ "$common_path" == "$path" ]] || [[ "$common_path" == "$path/"* ]]; then

      len=${#path}

      if (( len > max_path_len )); then
        label="${rules_ref_ref[$path]}"
        max_path_len=$len
      fi

    fi
  done

  # be careful with the referenced variable name
  local scope_local=

  if [[ -n "$common_path" ]]; then
    scope_local="$main_label"

    if [[ -n "$label" ]]; then
      scope_local="$scope_local $label"
    else
      common_stripped=$(strip_path_before "$common_path" "$main_path")
      common_normalized=$(get_cut_path "$common_stripped" "$no_label_path_depth")
      scope_local="$scope_local $common_normalized"
    fi
  fi

  scope_local="${scope_local# }"
  scope_local="${scope_local% }"

  changed_files_ref_ref=("${remaining_files[@]}")
  scope_ref="$scope_local"
}

make_general_scope() {
  local -n changed_files_ref=$1
  local no_label_path_depth=$2
  local -n general_scope_ref=$3
  shift 3

  local general_scope_local=
  local group_scope=

  for rules_ref in "$@"; do
    make_scope changed_files_ref $no_label_path_depth group_scope $rules_ref

    general_scope_local="$general_scope_local, $group_scope"

    general_scope_local="${general_scope_local#, }"
    general_scope_local="${general_scope_local%, }"
  done

  if [[ -n "$general_scope_local" ]]; then

    if [[ ${#changed_files_ref[@]} -gt 0 ]]; then
      general_scope_local="${general_scope_local}, etc"
    fi

    general_scope_local="($general_scope_local):"
  else

    local common_path=$(common_path "${changed_files_ref[@]}")
    common_normalized=$(get_cut_path "$common_path" "$no_label_path_depth")

     if [[ -n "$common_normalized" ]]; then
      general_scope_local="($common_normalized):"
     fi
  fi

  general_scope_ref="$general_scope_local"
}