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
echo "6. get_jira_id_from_branch_name"

echo ""
echo "6.1. Test get_jira_id_from_branch_name, branch name with dash"
branch="branch-proj-123-branch"
jira_project_key="PROJ"
expect="PROJ-123"
res=$(get_jira_id_from_branch_name "$branch" "$jira_project_key")
echo "get_jira_id_from_branch_name \"$branch\" \"$jira_project_key\""
assert "$res" "$expect"

echo ""
echo "6.2. Test get_jira_id_from_branch_name, branch name with several dashes"
branch="branch-proj---123-branch"
jira_project_key="PROJ"
expect="PROJ-123"
res=$(get_jira_id_from_branch_name "$branch" "$jira_project_key")
echo "get_jira_id_from_branch_name \"$branch\" \"$jira_project_key\""
assert "$res" "$expect"

echo ""
echo "6.3. Test get_jira_id_from_branch_name, branch name with underscore"
branch="branch-proj_123-branch"
jira_project_key="PROJ"
expect="PROJ-123"
res=$(get_jira_id_from_branch_name "$branch" "$jira_project_key")
echo "get_jira_id_from_branch_name \"$branch\" \"$jira_project_key\""
assert "$res" "$expect"

echo ""
echo "6.4. Test get_jira_id_from_branch_name, branch name with several underscores"
branch="branch-proj___123-branch"
jira_project_key="PROJ"
expect="PROJ-123"
res=$(get_jira_id_from_branch_name "$branch" "$jira_project_key")
echo "get_jira_id_from_branch_name \"$branch\" \"$jira_project_key\""
assert "$res" "$expect"

echo ""
echo "6.5. Test get_jira_id_from_branch_name"
branch="branch-proj123-branch"
jira_project_key="PROJ"
expect="PROJ-123"
res=$(get_jira_id_from_branch_name "$branch" "$jira_project_key")
echo "get_jira_id_from_branch_name \"$branch\" \"$jira_project_key\""
assert "$res" "$expect"

echo ""
echo "6.6. Test get_jira_id_from_branch_name, pattern in the beginning"
branch="proj-123-branch"
jira_project_key="PROJ"
expect="PROJ-123"
res=$(get_jira_id_from_branch_name "$branch" "$jira_project_key")
echo "get_jira_id_from_branch_name \"$branch\" \"$jira_project_key\""
assert "$res" "$expect"

echo ""
echo "6.7. Test get_jira_id_from_branch_name, pattern in the end"
branch="branch-proj-123"
jira_project_key="PROJ"
expect="PROJ-123"
res=$(get_jira_id_from_branch_name "$branch" "$jira_project_key")
echo "get_jira_id_from_branch_name \"$branch\" \"$jira_project_key\""
assert "$res" "$expect"

echo ""
echo "6.8. Test get_jira_id_from_branch_name, different cases"
branch="branch-PrOj-123"
jira_project_key="PROJ"
expect="PROJ-123"
res=$(get_jira_id_from_branch_name "$branch" "$jira_project_key")
echo "get_jira_id_from_branch_name \"$branch\" \"$jira_project_key\""
assert "$res" "$expect"