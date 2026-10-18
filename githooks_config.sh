#!/bin/bash

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