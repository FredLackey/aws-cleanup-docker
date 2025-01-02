#! /bin/bash

is_govcloud() {
  local accountJson="$1"
  local isGovCloud=$(echo "$accountJson" | jq -r '.govcloud // false')
  
  # Log the account type for debugging
  if [ "$isGovCloud" = "true" ]; then
    >&2 echo "  Account is GovCloud"
  else
    >&2 echo "  Account is commercial"
  fi
  
  # Only return the boolean value
  echo "$isGovCloud"
}