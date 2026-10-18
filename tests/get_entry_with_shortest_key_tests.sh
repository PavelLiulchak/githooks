#!/bin/bash

# Copyright 2026 Pavel Liulchak
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
echo "9. get_entry_with_shortest_key"

declare -A rules=(
    ['code']="dev"
    ['code/Module1']="mod1"
    ['code/Module2']="mod2"
    ['code/Module3']="mod3"
)

#########################################
echo ""
echo "9.1. Test get_entry_with_shortest_key"
echo "rules:"
echo_assoc_array rules

main_path=
main_label=
get_entry_with_shortest_key rules main_path main_label

echo "main_path:"
assert "$main_path" "code"
echo "main_label:"
assert "$main_label" "dev"


#########################################
echo ""
echo "9.2. Test get_entry_with_shortest_key, rules contain one element"
declare -A rules=(
    ['code']="dev"
)

echo "rules:"
echo_assoc_array rules

main_path=""
main_label=""
get_entry_with_shortest_key rules main_path main_label

echo "main_path:"
assert "$main_path" "code"
echo "main_label:"
assert "$main_label" "dev"


#########################################
echo ""
echo "9.3. Test get_entry_with_shortest_key, rules are empty"
declare -A rules=()

echo "rules:"
echo_assoc_array rules

main_path=""
main_label=""
get_entry_with_shortest_key rules main_path main_label

echo "main_path:"
assert "$main_path" ""
echo "main_label:"
assert "$main_label" ""


#########################################
declare -A rules=(
    ['код']="код"
    ['код/Модуль и компоненты']="мод1"
    ['код/Модуль2']="мод2"
    ['код/Модуль3']="мод3"
)

echo ""
echo "9.4. Test get_entry_with_shortest_key, cyrillic rules"
echo "rules:"
echo_assoc_array rules

main_path=
main_label=
get_entry_with_shortest_key rules main_path main_label

echo "main_path:"
assert "$main_path" "код"
echo "main_label:"
assert "$main_label" "код"