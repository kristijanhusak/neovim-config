#!/usr/bin/env bash

is_dirty() {
  local dirty=$(git status --porcelain 2> /dev/null)

  if [[ $dirty != "" ]]; then
    printf "*"
  fi
}

git_changes() {
  local changes=$(git diff --shortstat | sed 's/^[^0-9]*\([0-9]*\)[^0-9]*\([0-9]*\)[^0-9]*\([0-9]*\)[^0-9]*/\1;\2;\3/')
  local changes_array=(${changes//;/ })
  local result=()

  if [[ -n ${changes_array[0]} ]]; then
    result+=("~${changes_array[0]}")
  fi

  if [[ -n ${changes_array[1]} ]]; then
    result+=("+${changes_array[1]}")
  fi

  if [[ -n ${changes_array[2]} ]]; then
    result+=("-${changes_array[2]}")
  fi

  local joined=$(printf " %s" "${result[@]}")
  local joined=${joined:1}

  if [[ -n $joined ]]; then
    echo "$joined "
  fi
}

main() {
  local status=$(git rev-parse --abbrev-ref HEAD)
  local changes=$(git_changes)

  if [[ -n $status ]]; then
    printf " $status $changes"
  fi
}

main
