#!/bin/bash

assert() {
  res=$1
  expect=$2

  echo "res = $res"
  echo "expect = $expect"

  if [[ $res == $expect ]]; then
    GREEN=$(tput setaf 2)
    RESET=$(tput sgr0)

    echo "${GREEN}Success${RESET}"
  else
    RED=$(tput setaf 1)
    RESET=$(tput sgr0)

    echo "${RED}Failed${RESET}"
  fi
}