#! /bin/bash

is_disabled() {
  local accountJson="$1"
  local isDisabled=$(echo "$accountJson" | jq -r '.disabled // false')
  
  # Log the account type for debugging
  if [ "$isDisabled" = "true" ]; then
    >&2 echo "  Account is disabled"
  fi
  
  # Only return the boolean value
  echo "$isDisabled"
}