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

# Tweak with caution, use numbers only!
path_depth=1

# Set us!
jira_project_key="PROJ"
# The rules paths are case sensitive

declare -A team1_rules=(
    ['code/tests']="qa"
    ['code/tests/Module1']="mod1"
    ['code/tests/Module2']="mod2"
)

declare -A team2_rules=(
    ['code']="dev"
    ['code/Module1']="mod1"
    ['code/Module2']="mod2"
)