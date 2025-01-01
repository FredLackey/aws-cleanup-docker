#! /bin/bash

is_outside_hours() {
  local account="$1"
  local workdays=$(echo "$account" | jq -r '.workdays // empty')
  local workhours=$(echo "$account" | jq -r '.workhours // empty')

  # If neither workdays nor workhours are present, return false
  if [ -z "$workdays" ] && [ -z "$workhours" ]; then
    echo "false"
    return
  fi

  # If both workdays and workhours are present
  if [ ! -z "$workdays" ] && [ ! -z "$workhours" ]; then
    if ! is_workday "$workdays" || ! is_workhours "$workhours"; then
      >&2 echo "  Outside of work days and hours"
      echo "true"
      return
    fi
    echo "false"
    return
  fi

  # If only workdays is present
  if [ ! -z "$workdays" ]; then
    if ! is_workday "$workdays"; then
      >&2 echo "  Outside of work days"
      echo "true"
      return
    fi
    echo "false"
    return
  fi

  # If only workhours is present
  if [ ! -z "$workhours" ]; then
    if ! is_workhours "$workhours"; then
      >&2 echo "  Outside of work hours"
      echo "true"
      return
    fi
    echo "false"
    return
  fi
}
