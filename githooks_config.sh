#!/bin/bash

# Set us!
jira_project_key="PROJ"
# The rules paths are case sensitive
declare -A rules=(
    ['code']="DEV"
    ['code/tests']="QA"
    ['code/autotests']="QA"
)

# Tweak with caution, use numbers only!
after_label_path_depth=1