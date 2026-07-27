#!/bin/bash

# Tweak with caution, use numbers only!
path_depth=1

# Set us!
jira_project_key="PROJ"
# The rules paths are case sensitive

declare team1_main_label="qa"
declare -A team1_rules=(
    ['code/autotests']="$qa_main_label"
    ['code/tests']="$qa_main_label"
    ['code/tests/Module1']="mod1"
    ['code/tests/Module2']="mod2"
    ['code/tests/Module3']="mod3"
    ['code/tests/Module4']="mod4"
    ['code/tests/Module5']="mod5"
    ['code/tests/Module6']="mod6"
    ['code/tests/Module7']="mod7"
    ['code/autotests/ModuleUI1']="mod1 ui"
    ['code/autotests/ModuleUI2']="mod2 ui"
)

declare team2_main_label="dev"
declare -A team2_rules=(
    ['code']="$dev_main_label"
    ['code/Module1']="mod1"
    ['code/Module2']="mod2"
    ['code/Module3']="mod3"
    ['code/Module4']="mod4"
    ['code/Module5']="mod5"
    ['code/Module6']="mod6"
    ['code/Module7']="mod7"
)